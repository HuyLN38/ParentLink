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

type AuthPassword struct {
	IDToken     string `json:"idToken"`
	OldPassword string `json:"OldPassword"`
	NewPassword string `json:"NewPassword"`
}

type RegisterRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

type LoginRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

func registerHandler(w http.ResponseWriter, r *http.Request) {
	var req RegisterRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request", http.StatusBadRequest)
		return
	}

	params := (&auth.UserToCreate{}).
		Email(req.Email).
		Password(req.Password)

	u, err := authClient.CreateUser(context.Background(), params)
	if err != nil {
		http.Error(w, "Failed to create user", http.StatusInternalServerError)
		fmt.Println(err)
		return
	}

	response := map[string]string{
		"uid": u.UID,
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func loginHandler(w http.ResponseWriter, r *http.Request) {
	var req LoginRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request", http.StatusBadRequest)
		return
	}

	authData := map[string]string{
		"email":             req.Email,
		"password":          req.Password,
		"returnSecureToken": "true",
	}
	authDataBytes, err := json.Marshal(authData)
	if err != nil {
		http.Error(w, "Failed to marshal auth data", http.StatusInternalServerError)
		return
	}

	authResponse, err := http.Post("https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyBiMYp6mh6ITGKHKQX6ebyx4h0p6tj-j5E", "application/json", bytes.NewBuffer(authDataBytes))

	if err != nil || authResponse.StatusCode != http.StatusOK {
		http.Error(w, "Invalid email or password", http.StatusUnauthorized)
		return
	}

	var authResult map[string]interface{}
	if err := json.NewDecoder(authResponse.Body).Decode(&authResult); err != nil {
		http.Error(w, "Failed to decode auth response", http.StatusInternalServerError)
		return
	}

	response := authResult
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
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
