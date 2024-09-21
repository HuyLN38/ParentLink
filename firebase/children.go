package firebase

import (
	"github.com/gin-gonic/gin"
	"net/http"
)

type Child struct {
	Name     string     `json:"name"`
	Location [2]float64 `json:"location"`
}

func AddChild(c *gin.Context) {
	staticID := c.Param("staticID")

	var child Child
	if err := c.ShouldBindJSON(&child); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	docRef := firestoreClient.Collection("users").Doc(staticID).Collection("children").NewDoc()
	_, err := docRef.Set(c.Request.Context(), child)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to add child"})
		return
	}
	c.JSON(http.StatusOK, map[string]string{"status": "Child added successfully"})
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
