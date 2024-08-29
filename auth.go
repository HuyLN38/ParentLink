package main

import (
	"bytes"
	"context"
	"encoding/json"
	"firebase.google.com/go/auth"
	"fmt"
	"github.com/gin-gonic/gin"
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

func registerHandler(c *gin.Context) {
	var req RegisterRequest
	if err := json.NewDecoder(c.Request.Body).Decode(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request"})
		return
	}

	params := (&auth.UserToCreate{}).
		Email(req.Email).
		Password(req.Password)

	u, err := authClient.CreateUser(context.Background(), params)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create user"})
		fmt.Println(err)
		return
	}

	response := map[string]string{
		"uid": u.UID,
	}
	c.Writer.Header().Set("Content-Type", "application/json")
	c.JSON(http.StatusOK, response)
}

func loginHandler(c *gin.Context) {
	var req LoginRequest
	if err := json.NewDecoder(c.Request.Body).Decode(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request"})
		return
	}

	authData := map[string]string{
		"email":             req.Email,
		"password":          req.Password,
		"returnSecureToken": "true",
	}
	authDataBytes, err := json.Marshal(authData)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to marshal auth data"})
		return
	}

	authResponse, err := http.Post("https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyBiMYp6mh6ITGKHKQX6ebyx4h0p6tj-j5E", "application/json", bytes.NewBuffer(authDataBytes))

	if err != nil || authResponse.StatusCode != http.StatusOK {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid email or password"})
		return
	}

	var authResult map[string]interface{}
	if err := json.NewDecoder(authResponse.Body).Decode(&authResult); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to decode auth response"})
		return
	}

	response := authResult
	c.Writer.Header().Set("Content-Type", "application/json")
	c.JSON(http.StatusOK, response)
}

func changePassword(c *gin.Context) {
	var req AuthPassword
	if err := json.NewDecoder(c.Request.Body).Decode(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request"})
		return
	}

	fmt.Println("Changing password")
	token, err := authClient.VerifyIDToken(c.Request.Context(), req.IDToken)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid ID token"})
		return
	}

	user, err := authClient.GetUser(c.Request.Context(), token.UID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}

	authData := map[string]string{
		"email":             user.Email,
		"password":          req.OldPassword,
		"returnSecureToken": "true",
	}
	authDataBytes, err := json.Marshal(authData)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to marshal auth data"})
		return
	}
	authResponse, err := http.Post("https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyBiMYp6mh6ITGKHKQX6ebyx4h0p6tj-j5E", "application/json", bytes.NewBuffer(authDataBytes))
	if err != nil || authResponse.StatusCode != http.StatusOK {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Old password is incorrect"})
		return
	}

	params := (&auth.UserToUpdate{}).Password(req.NewPassword)
	u, err := authClient.UpdateUser(context.Background(), token.UID, params)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update password"})
		return
	}

	log.Printf("Successfully updated user: %v\n", u)

	response := map[string]string{
		"message": "Password changed successfully",
	}
	c.Writer.Header().Set("Content-Type", "application/json")
	c.JSON(http.StatusOK, response)
}

func deleteUser(c *gin.Context) {
	staticID := c.Param("staticID")

	fmt.Println("Deleting user")
	_, err := firestoreClient.Collection("users").Doc(staticID).Get(c.Request.Context())
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		fmt.Println(err)
		return
	}

	_, err = firestoreClient.Collection(`users`).Doc(staticID).Delete(c.Request.Context())
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete user"})
		fmt.Println(err)
		return
	}

	err = authClient.DeleteUser(c.Request.Context(), staticID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete user from authentication"})
		fmt.Println(err)
		return
	}

	response := map[string]string{
		"message": "User deleted successfully",
	}
	c.Writer.Header().Set("Content-Type", "application/json")
	c.JSON(http.StatusOK, response)
}
