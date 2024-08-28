package main

import (
	"bytes"
	"context"
	"encoding/json"
	"firebase.google.com/go/auth"
	"fmt"
	"github.com/gorilla/mux"
	"log"
	"net/http"
)

type AuthRequest struct {
	IDToken string `json:"idToken"`
}

type AuthPassword struct {
	IDToken     string `json:"idToken"`
	OldPassword string `json:"OldPassword"`
	NewPassword string `json:"NewPassword"`
}

type User struct {
	UID      string `json:"uid"`
	StaticID string `json:"staticID"`
}

func registerUser(w http.ResponseWriter, r *http.Request) {
	var req AuthRequest
	fmt.Println("Registering user")
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request", http.StatusBadRequest)
		return
	}

	token, err := authClient.VerifyIDToken(r.Context(), req.IDToken)
	if err != nil {
		http.Error(w, "Invalid ID token", http.StatusUnauthorized)
		fmt.Println(err)
		return
	}

	staticID := token.UID

	_, err = firestoreClient.Collection("users").Doc(staticID).Set(r.Context(), User{
		UID:      token.UID,
		StaticID: staticID,
	})
	if err != nil {
		http.Error(w, "Failed to create user", http.StatusInternalServerError)
		fmt.Println(err)
		return
	}

	response := map[string]string{
		"staticID": staticID,
		"message":  "Registration successful",
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func loginUser(w http.ResponseWriter, r *http.Request) {
	var req AuthRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request", http.StatusBadRequest)
		return
	}

	fmt.Println("Logging in user")
	token, err := authClient.VerifyIDToken(r.Context(), req.IDToken)
	if err != nil {
		http.Error(w, "Invalid ID token", http.StatusUnauthorized)
		return
	}

	doc, err := firestoreClient.Collection("users").Where("UID", "==", token.UID).Documents(r.Context()).Next()
	if err != nil {
		http.Error(w, "User not found", http.StatusNotFound)
		return
	}

	var user User
	doc.DataTo(&user)

	json.NewEncoder(w).Encode(map[string]string{"staticID": user.StaticID})
}

func changePassword(w http.ResponseWriter, r *http.Request) {
	var req AuthPassword
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request", http.StatusBadRequest)
		return
	}

	fmt.Println("Changing password")
	token, err := authClient.VerifyIDToken(r.Context(), req.IDToken)
	if err != nil {
		http.Error(w, "Invalid ID token", http.StatusUnauthorized)
		return
	}

	user, err := authClient.GetUser(r.Context(), token.UID)
	if err != nil {
		http.Error(w, "User not found", http.StatusNotFound)
		return
	}

	// Re-authenticate user with old password
	authData := map[string]string{
		"email":             user.Email,
		"password":          req.OldPassword,
		"returnSecureToken": "true",
	}
	authDataBytes, err := json.Marshal(authData)
	if err != nil {
		http.Error(w, "Failed to marshal auth data", http.StatusInternalServerError)
		return
	}
	authResponse, err := http.Post("https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyBiMYp6mh6ITGKHKQX6ebyx4h0p6tj-j5E", "application/json", bytes.NewBuffer(authDataBytes))
	if err != nil || authResponse.StatusCode != http.StatusOK {
		http.Error(w, "Old password is incorrect", http.StatusUnauthorized)
		return
	}

	// Update password
	params := (&auth.UserToUpdate{}).Password(req.NewPassword)
	u, err := authClient.UpdateUser(context.Background(), token.UID, params)
	if err != nil {
		http.Error(w, "Failed to update password", http.StatusInternalServerError)
		return
	}

	log.Printf("Successfully updated user: %v\n", u)

	response := map[string]string{
		"message": "Password changed successfully",
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func deleteUser(w http.ResponseWriter, r *http.Request) {
	params := mux.Vars(r)
	staticID := params["staticID"]

	fmt.Println("Deleting user")
	_, err := firestoreClient.Collection("users").Doc(staticID).Get(r.Context())
	if err != nil {
		http.Error(w, "User not found", http.StatusNotFound)
		fmt.Println(err)
		return
	}

	_, err = firestoreClient.Collection("users").Doc(staticID).Delete(r.Context())
	if err != nil {
		http.Error(w, "Failed to delete user", http.StatusInternalServerError)
		fmt.Println(err)
		return
	}

	err = authClient.DeleteUser(r.Context(), staticID)
	if err != nil {
		http.Error(w, "Failed to delete user from authentication", http.StatusInternalServerError)
		fmt.Println(err)
		return
	}

	response := map[string]string{
		"message": "User deleted successfully",
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}
