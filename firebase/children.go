package firebase

import (
	"github.com/gin-gonic/gin"
	"net/http"
	"time"
)

type Child struct {
	ChildID      string    `json:"childId"`
	Name         string    `json:"name"`
	Birthday     string    `json:"birthday"`
	Longitude    float64   `json:"longitude"`
	Latitude     float64   `json:"latitude"`
	LastModified time.Time `json:"lastModified"`
	LastSeen     time.Time `json:"lastSeen"`
	Speed        float64   `json:"speed"`
	PhoneNumber  string    `json:"phone"`
}

type ChildRequest struct {
	ChildID      string    `json:"childId"`
	Name         string    `json:"name"`
	Birthday     string    `json:"birthday"`
	Phone        string    `json:"phone"`
	LastModified time.Time `json:"lastModified"`
	LastSeen     time.Time `json:"lastSeen"`
	Avatar       string    `json:"avatar"`
}

func AddChild(c *gin.Context) {
	staticID := c.Param("staticID")

	// Define request structure
	type ChildRequest struct {
		ChildID     string `json:"childId" binding:"required,uuid"`
		Name        string `json:"name" binding:"required"`
		Birthday    string `json:"birthday" binding:"required"`
		Avatar      string `json:"avatar" binding:"required"`
		PhoneNumber string `json:"phone" binding:"required"`
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

	// Check if child document already exists
	existingDoc := firestoreClient.Collection("users").Doc(staticID).Collection("children").Doc(req.ChildID)
	docSnap, err := existingDoc.Get(c.Request.Context())
	if err == nil && docSnap.Exists() {
		c.JSON(http.StatusConflict, gin.H{"error": "Child with this ID already exists"})
		return
	}

	// Create child document
	child := struct {
		ChildID      string    `firestore:"childId"`
		Name         string    `firestore:"name"`
		Birthday     time.Time `firestore:"birthday"`
		Avatar       string    `firestore:"avatar"`
		PhoneNumber  string    `firestore:"phone"`
		Created      time.Time `firestore:"created"`
		LastModified time.Time `firestore:"lastModified"`
		LastSeen     time.Time `firestore:"lastSeen"`
		Longitude    float64   `firestore:"longitude"`
		Latitude     float64   `firestore:"latitude"`
		Speed        float64   `json:"speed"`
	}{
		ChildID:      req.ChildID,
		Name:         req.Name,
		Birthday:     birthday,
		Avatar:       req.Avatar,
		Created:      time.Now(),
		LastModified: time.Now(),
		LastSeen:     time.Now(),
		PhoneNumber:  req.PhoneNumber,
		Longitude:    0,
		Latitude:     0,
		Speed:        0,
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

func GetChildrenList(c *gin.Context) {
	staticID := c.Param("staticID")

	children := []ChildRequest{}
	docs, err := firestoreClient.Collection("users").Doc(staticID).Collection("children").Documents(c.Request.Context()).GetAll()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch children"})
		return
	}

	for _, doc := range docs {
		var child ChildRequest
		doc.DataTo(&child)
		children = append(children, child)
	}

	c.JSON(http.StatusOK, children)
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
