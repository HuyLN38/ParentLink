package firebase

import (
	"encoding/base64"
	"github.com/gin-gonic/gin"
	"net/http"
	"strings"
	"time"
)

type Child struct {
	Name     string     `json:"name"`
	Location [2]float64 `json:"location"`
}

func AddChild(c *gin.Context) {
	staticID := c.Param("staticID")

	// Define request structure
	type ChildRequest struct {
		ChildID  string `json:"childId" binding:"required,uuid"`
		Name     string `json:"name" binding:"required"`
		Birthday string `json:"birthday" binding:"required"`
		Avatar   string `json:"avatar" binding:"required"`
	}

	var req ChildRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Parse and validate birthday format
	birthday, err := time.Parse("02/01/2006", req.Birthday)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid birthday format. Use DD/MM/YYYY"})
		return
	}

	// Check if the birthday is not in the future
	if birthday.After(time.Now()) {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Birthday cannot be in the future"})
		return
	}

	// Decode and validate base64 image
	avatarData, err := base64.StdEncoding.DecodeString(req.Avatar)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid avatar format"})
		return
	}

	// Validate image format and size
	contentType := http.DetectContentType(avatarData)
	if !strings.HasPrefix(contentType, "image/") {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid file type. Only images are allowed"})
		return
	}

	// Set maximum file size (e.g., 5MB)
	maxSize := 5 * 1024 * 1024 // 5MB in bytes
	if len(avatarData) > maxSize {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Avatar image too large. Maximum size is 5MB"})
		return
	}

	// Check if child document already exists
	existingDoc := firestoreClient.Collection("users").Doc(staticID).Collection("children").Doc(req.ChildID)
	docSnap, err := existingDoc.Get(c.Request.Context())
	if err == nil && docSnap.Exists() {
		c.JSON(http.StatusConflict, gin.H{"error": "Child with this ID already exists"})
		return
	}

	// Create child document
	child := struct {
		ChildID   string    `firestore:"childId"`
		Name      string    `firestore:"name"`
		Birthday  time.Time `firestore:"birthday"`
		Avatar    []byte    `firestore:"avatar"`
		Created   time.Time `firestore:"created"`
		Longitude float64   `firestore:"longitude"`
		Latitude  float64   `firestore:"latitude"`
	}{
		ChildID:   req.ChildID,
		Name:      req.Name,
		Birthday:  birthday,
		Avatar:    avatarData,
		Created:   time.Now(),
		Longitude: 0,
		Latitude:  0,
	}

	// Save to Firestore using the provided UUID as document ID
	_, err = firestoreClient.Collection("users").Doc(staticID).Collection("children").Doc(req.ChildID).Set(c.Request.Context(), child)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to add child"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":    "Child added successfully",
		"childId":   req.ChildID,
		"name":      child.Name,
		"birthday":  req.Birthday,
		"longitude": child.Longitude,
		"latitude":  child.Latitude,
	})
}

func CheckIfChildExists(c *gin.Context) {
	staticID := c.Param("staticID")
	childID := c.Param("childID")

	docSnap, err := firestoreClient.Collection("users").Doc(staticID).Collection("children").Doc(childID).Get(c.Request.Context())
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to check child existence"})
		return
	}

	if !docSnap.Exists() {
		c.JSON(http.StatusNotFound, gin.H{"error": "Child not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": "Child exists"})
}

func GetChildren(c *gin.Context) {
	staticID := c.Param("staticID")

	children := []Child{}
	docs, err := firestoreClient.Collection("users").Doc(staticID).Collection("children").Documents(c.Request.Context()).GetAll()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch children"})
		return
	}

	for _, doc := range docs {
		var child Child
		doc.DataTo(&child)
		children = append(children, child)
	}

	c.JSON(http.StatusOK, children)
}
