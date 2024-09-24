package firebase

import (
	"bytes"
	"context"
	"crypto/rand"
	"encoding/json"
	"firebase.google.com/go/auth"
	"fmt"
	"github.com/gin-gonic/gin"
	"log"
	"net/http"
	"time"
)

type AuthPassword struct {
	IDToken     string `json:"idToken"`
	OldPassword string `json:"OldPassword"`
	NewPassword string `json:"NewPassword"`
}

type AccountRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

type OTPValidationRequest struct {
	OTP string `json:"otp"`
}

func generateOTP() (string, error) {
	b := make([]byte, 3)
	_, err := rand.Read(b)
	if err != nil {
		return "", err
	}
	return fmt.Sprintf("%06d", b[0]<<16|b[1]<<8|b[2]), nil
}

func RegisterHandler(c *gin.Context) {
	var req AccountRequest
	if err := json.NewDecoder(c.Request.Body).Decode(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request"})
		return
	}

	otp, err := generateOTP()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate OTP"})
		return
	}

	docRef := firestoreClient.Collection("Registration").Doc(otp)
	_, err = docRef.Set(context.Background(), map[string]interface{}{
		"email":    req.Email,
		"password": req.Password,
		"created":  time.Now(),
	})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to store OTP"})
		return
	} else {
		Send(c, req.Email, otp)
	}

	// Set a timer to delete the document after 5 minutes
	go func() {
		time.Sleep(5 * time.Minute)
		docRef.Delete(context.Background())
	}()

	c.JSON(http.StatusOK, gin.H{"otp": otp})
}

func ValidateOTP(c *gin.Context) {
	OTP := c.Param("otp")

	docRef := firestoreClient.Collection("Registration").Doc(OTP)
	doc, err := docRef.Get(context.Background())
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid OTP"})
		return
	}

	data := doc.Data()
	email := data["email"].(string)
	password := data["password"].(string)

	params := (&auth.UserToCreate{}).
		Email(email).
		Password(password)

	u, err := authClient.CreateUser(context.Background(), params)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create user"})
		return
	}

	_, err = docRef.Delete(context.Background())
	if err != nil {
		return
	}

	c.JSON(http.StatusOK, gin.H{"uid": u.UID})
}

func LoginHandler(c *gin.Context) {
	var req AccountRequest
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

	// Extract LocalID from authResult
	localID, ok := authResult["localId"].(string)
	if !ok {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get user ID"})
		return
	}

	// Check if the user document exists
	docRef := firestoreClient.Collection("users").Doc(localID)
	doc, err := docRef.Get(c.Request.Context())

	// If the document does not exist, create a new one
	if !doc.Exists() {
		user := map[string]interface{}{
			"localId": localID,
			"email":   req.Email,
		}
		_, err := docRef.Set(c.Request.Context(), user)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create user document"})
			return
		}
	}

	response := authResult
	c.Writer.Header().Set("Content-Type", "application/json")
	c.JSON(http.StatusOK, response)
}

func ChangePassword(c *gin.Context) {
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

func DeleteUser(c *gin.Context) {
	id := c.Param("staticID")

	fmt.Println("Deleting user by ID:", id)
	// Check if the user document exists in Firestore
	docRef := firestoreClient.Collection("users").Doc(id)
	_, err := docRef.Get(c.Request.Context())
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		fmt.Println("User not found:", err)
		return
	}

	// Delete all child documents associated with the user
	childrenCollection := docRef.Collection("children")
	docs, err := childrenCollection.Documents(c.Request.Context()).GetAll()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch children"})
		fmt.Println("Failed to fetch children:", err)
		return
	}

	for _, doc := range docs {
		_, err := doc.Ref.Delete(c.Request.Context())
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete child"})
			fmt.Println("Failed to delete child:", err)
			return
		}
	}

	// Delete the user document from Firestore
	_, err = docRef.Delete(c.Request.Context())
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete user"})
		fmt.Println("Failed to delete user:", err)
		return
	}

	// Delete the user from Firebase Authentication
	err = authClient.DeleteUser(c.Request.Context(), id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete user from authentication"})
		fmt.Println("Failed to delete user from authentication:", err)
		return
	}

	response := map[string]string{
		"message": "User and all related data deleted successfully",
	}
	c.Writer.Header().Set("Content-Type", "application/json")
	c.JSON(http.StatusOK, response)
}

//func sendEmail(to string, subject string, body string) error {
//	msg := []byte("From: " + "\r\n" +
//		"To: " + to + "\r\n" +
//		"Subject: " + subject + "\r\n" +
//		"\r\n" + body)
//
//	message := &gmail.Message{
//		Raw: base64.URLEncoding.EncodeToString(msg),
//	}
//
//	// Send the message
//	_, err := gmailService.Users.Messages.Send("me", message).Do()
//	if err != nil {
//		return fmt.Errorf("unable to send email: %v", err)
//	}
//
//	return nil
//}

//err := sendEmail("recipient@example.com", "Test Subject", "This is the email body.")
//if err != nil {
//log.Fatalf("Failed to send email: %v", err)
//}
