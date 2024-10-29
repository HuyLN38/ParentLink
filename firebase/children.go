package firebase

import (
	"context"
	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v4"
	"log"
	"net/http"
	"time"
)

var db *pgx.Conn

func init() {
	// Establish PostgreSQL connection
	var err error
	db, err = pgx.Connect(context.Background(), "postgres://huyln38:huy382004@localhost:5432/parentlink")
	if err != nil {
		log.Fatal("Unable to connect to database:", err)
	}
}

type Child struct {
	ChildID      string    `json:"childId,omitempty"`
	Name         string    `json:"name,omitempty"`
	Birthday     time.Time `json:"birthday,omitempty"`
	LastModified time.Time `json:"lastModified,omitempty"`
	LastSeen     time.Time `json:"lastSeen,omitempty"`
	PhoneNumber  string    `json:"phone,omitempty"`
	Avatar       string    `json:"avatar,omitempty"`
	Longitude    float64   `json:"longitude"`
	Latitude     float64   `json:"latitude"`
	Speed        float64   `json:"speed"`
}

func AddChild(c *gin.Context) {
	staticID := c.Param("staticID")

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

	birthday, err := time.Parse("02/01/2006", req.Birthday)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid birthday format. Use DD/MM/YYYY"})
		return
	}

	if birthday.After(time.Now()) {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Birthday cannot be in the future"})
		return
	}

	// Insert child into PostgreSQL
	query := `INSERT INTO children (static_id, child_id, name, birthday, avatar, phone, created, last_modified, last_seen)
              VALUES ($1, $2, $3, $4, $5, $6, NOW(), NOW(), NOW())`
	_, err = db.Exec(context.Background(), query, staticID, req.ChildID, req.Name, birthday, req.Avatar, req.PhoneNumber)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err})
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": "Child added successfully", "childId": req.ChildID, "name": req.Name, "birthday": req.Birthday})
}

func CheckIfChildExists(c *gin.Context) {
	staticID := c.Param("staticID")
	childID := c.Param("childID")

	var child Child
	query := `SELECT child_id, name, birthday, last_modified, last_seen, phone
              FROM children WHERE static_id=$1 AND child_id=$2`
	err := db.QueryRow(context.Background(), query, staticID, childID).Scan(&child.ChildID, &child.Name, &child.Birthday, &child.LastModified, &child.LastSeen, &child.PhoneNumber)

	if err != nil {
		if err == pgx.ErrNoRows {
			c.JSON(http.StatusNotFound, gin.H{"error": "Child not found"})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to check child existence"})
		}
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": "Child exists", "child": child})
}

func GetChildren(c *gin.Context) {
	staticID := c.Param("staticID")
	var children []Child

	query := `SELECT child_id, name, birthday, last_modified, last_seen, phone, longitude, latitude, speed 
              FROM children WHERE static_id=$1`
	rows, err := db.Query(context.Background(), query, staticID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch children"})
		return
	}
	defer rows.Close()

	for rows.Next() {
		var child Child
		err := rows.Scan(&child.ChildID, &child.Name, &child.Birthday, &child.LastModified, &child.LastSeen, &child.PhoneNumber, &child.Longitude, &child.Latitude, &child.Speed)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to read child data"})
			return
		}
		children = append(children, child)
	}

	c.JSON(http.StatusOK, gin.H{"status": "Children fetched successfully", "children": children})
}

func GetChildrenList(c *gin.Context) {
	staticID := c.Param("staticID")
	var children []Child

	query := `SELECT child_id, name, birthday, last_modified, last_seen, phone, avatar 
              FROM children WHERE static_id=$1`
	rows, err := db.Query(context.Background(), query, staticID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch children"})
		return
	}
	defer rows.Close()

	for rows.Next() {
		var child Child
		err := rows.Scan(&child.ChildID, &child.Name, &child.Birthday, &child.LastModified, &child.LastSeen, &child.PhoneNumber, &child.Avatar)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to read child data"})
			return
		}
		children = append(children, child)
	}

	c.JSON(http.StatusOK, gin.H{"status": "Children fetched successfully", "children": children})
}
