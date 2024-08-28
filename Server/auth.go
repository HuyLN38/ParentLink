package main

import (
	"encoding/json"
	"fmt"
	"github.com/gorilla/mux"
	"net/http"
)

type AuthRequest struct {
	IDToken string `json:"idToken"`
}

type User struct {
	UID      string `json:"uid"`
	StaticID string `json:"staticID"`
}

func registerUser(w http.ResponseWriter, r *http.Request) {
	var req AuthRequest
	fmt.Println("Registering user")
	json.NewDecoder(r.Body).Decode(&req)

	token, err := authClient.VerifyIDToken(r.Context(), req.IDToken)
	fmt.Println(token)
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
	json.NewDecoder(r.Body).Decode(&req)
	fmt.Println("Logging in user")

	token, err := authClient.VerifyIDToken(r.Context(), req.IDToken)
	if err != nil {
		http.Error(w, "Invalid ID token", http.StatusUnauthorized)
		return
	}

	// Retrieve the user by UID or static ID from Firestore
	doc, err := firestoreClient.Collection("users").Where("UID", "==", token.UID).Documents(r.Context()).Next()
	if err != nil {
		http.Error(w, "User not found", http.StatusNotFound)
		return
	}

	var user User
	doc.DataTo(&user)

	json.NewEncoder(w).Encode(map[string]string{"staticID": user.StaticID})

}

func deleteUser(w http.ResponseWriter, r *http.Request) {
	params := mux.Vars(r)
	staticID := params["staticID"]

	fmt.Println("Deleting user")

	// Retrieve the user by static ID from Firestore
	_, err := firestoreClient.Collection("users").Doc(staticID).Get(r.Context())
	if err != nil {
		http.Error(w, "User not found", http.StatusNotFound)
		fmt.Println(err)
		return
	}

	// Delete the user document from Firestore
	_, err = firestoreClient.Collection("users").Doc(staticID).Delete(r.Context())
	if err != nil {
		http.Error(w, "Failed to delete user", http.StatusInternalServerError)
		fmt.Println(err)
		return
	}

	// Delete the user from Firebase Authentication
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
