package firebase

import (
	"context"
	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v4"
	"github.com/jackc/pgx/v4/pgxpool"
	"log"
	"net/http"
	"sync"
	"time"
)

var (
	pool   *pgxpool.Pool
	poolMu sync.RWMutex
)

// Your existing Child struct
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
	Battery      int       `json:"battery"`
}

// Initialize connection pool
func init() {
	poolConfig, err := pgxpool.ParseConfig("postgres://huyln38:huy382004@localhost:5432/parentlink")
	if err != nil {
		log.Fatal("Unable to parse config:", err)
	}

	// Configure pool for real-time performance
	poolConfig.MaxConns = 50                        // Adjust based on your needs
	poolConfig.MinConns = 10                        // Keep minimum connections ready
	poolConfig.MaxConnLifetime = 10 * time.Minute   // Prevent stale connections
	poolConfig.MaxConnIdleTime = 1 * time.Minute    // Quick recycling for real-time
	poolConfig.HealthCheckPeriod = 30 * time.Second // Frequent health checks

	pool, err = pgxpool.ConnectConfig(context.Background(), poolConfig)
	if err != nil {
		log.Fatal("Unable to connect to database:", err)
	}
}

// Your existing functions modified to use the connection pool
func UpdateChildLocation(c *gin.Context) {
	staticID := c.Param("staticID")
	childID := c.Param("childID")

	type LocationRequest struct {
		Longitude float64 `json:"longitude" binding:"required"`
		Latitude  float64 `json:"latitude" binding:"required"`
		Speed     float64 `json:"speed" binding:"required"`
		Battery   int     `json:"battery" binding:"required"`
	}

	var req LocationRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	query := `UPDATE children SET longitude=$1, latitude=$2, speed=$3, battery=$4, last_seen=NOW() WHERE static_id=$5 AND child_id=$6`
	_, err := pool.Exec(ctx, query, req.Longitude, req.Latitude, req.Speed, req.Battery, staticID, childID)
	if err != nil {
		log.Printf("Error updating location: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update child location"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": "Location updated successfully"})
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

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	query := `INSERT INTO children (static_id, child_id, name, birthday, avatar, phone, created, last_modified, last_seen)
              VALUES ($1, $2, $3, $4, $5, $6, NOW(), NOW(), NOW())`
	_, err = pool.Exec(ctx, query, staticID, req.ChildID, req.Name, birthday, req.Avatar, req.PhoneNumber)
	if err != nil {
		log.Printf("Error adding child: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to add child"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": "Child added successfully", "childId": req.ChildID, "name": req.Name, "birthday": req.Birthday})
}

func GetChildren(c *gin.Context) {
	staticID := c.Param("staticID")
	var children []Child

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	query := `SELECT child_id, name, birthday, last_modified, last_seen, phone, longitude, latitude, speed 
              FROM children WHERE static_id=$1`
	rows, err := pool.Query(ctx, query, staticID)
	if err != nil {
		log.Printf("Error fetching children: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch children"})
		return
	}
	defer rows.Close()

	for rows.Next() {
		var child Child
		err := rows.Scan(&child.ChildID, &child.Name, &child.Birthday, &child.LastModified, &child.LastSeen, &child.PhoneNumber, &child.Longitude, &child.Latitude, &child.Speed)
		if err != nil {
			log.Printf("Error scanning child data: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to read child data"})
			return
		}
		children = append(children, child)
	}

	c.JSON(http.StatusOK, gin.H{"status": "Children fetched successfully", "children": children})
}

func CheckIfChildExists(c *gin.Context) {
	staticID := c.Param("staticID")
	childID := c.Param("childID")

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	var child Child
	query := `SELECT child_id, name, birthday, last_modified, last_seen, phone
              FROM children WHERE static_id=$1 AND child_id=$2`
	err := pool.QueryRow(ctx, query, staticID, childID).Scan(
		&child.ChildID, &child.Name, &child.Birthday,
		&child.LastModified, &child.LastSeen, &child.PhoneNumber,
	)

	if err != nil {
		if err == pgx.ErrNoRows {
			c.JSON(http.StatusNotFound, gin.H{"error": "Child not found"})
		} else {
			log.Printf("Error checking child existence: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to check child existence"})
		}
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": "Child exists", "child": child})
}

func GetChildAvatar(c *gin.Context) {
	staticID := c.Param("staticID")
	childID := c.Param("childID")

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	var avatar string
	query := `SELECT avatar FROM children WHERE static_id=$1 AND child_id=$2`
	err := pool.QueryRow(ctx, query, staticID, childID).Scan(&avatar)
	if err != nil {
		log.Printf("Error fetching avatar: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch child avatar"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"avatar": avatar})
}

func GetChildrenList(c *gin.Context) {
	staticID := c.Param("staticID")
	var children []Child

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	query := `SELECT child_id, name, birthday, last_modified, last_seen, phone, battery FROM children WHERE static_id=$1`
	rows, err := pool.Query(ctx, query, staticID)
	if err != nil {
		log.Printf("Error fetching children list: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch children"})
		return
	}
	defer rows.Close()

	for rows.Next() {
		var child Child
		err := rows.Scan(&child.ChildID, &child.Name, &child.Birthday, &child.LastModified, &child.LastSeen, &child.PhoneNumber, &child.Battery)
		if err != nil {
			log.Printf("Error scanning child list data: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to read child data"})
			return
		}
		children = append(children, child)
	}

	c.JSON(http.StatusOK, gin.H{"status": "Children fetched successfully", "children": children})
}

func DeleteChild(c *gin.Context) {
	staticID := c.Param("staticID")
	childID := c.Param("childID")

	docRef := firestoreClient.Collection("users").Doc(childID)
	_, err := docRef.Delete(context.Background())
	if err != nil {
		log.Printf("Failed to delete document: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete document"})
		return
	}

	//// Delete all child documents associated with the user
	//childrenCollection := docRef.Collection("children")
	//_, err = childrenCollection.Documents(c.Request.Context()).GetAll()
	//if err != nil {
	//	c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch children"})
	//	fmt.Println("Failed to fetch children:", err)
	//	return
	//}

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	query := `DELETE FROM children WHERE static_id=$1 AND child_id=$2`
	_, err = pool.Exec(ctx, query, staticID, childID)
	if err != nil {
		log.Printf("Error deleting child: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete child"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": "Child deleted successfully"})
}

func GetChildrenStatus(c *gin.Context) {
	staticID := c.Param("staticID")
	childID := c.Param("childID")

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	var child Child
	query := `SELECT name, last_seen, longitude, latitude, speed, battery
              FROM children WHERE static_id=$1 AND child_id=$2`
	err := pool.QueryRow(ctx, query, staticID, childID).Scan(
		&child.Name, &child.LastSeen, &child.Longitude,
		&child.Latitude, &child.Speed, &child.Battery,
	)

	if err != nil {
		if err == pgx.ErrNoRows {
			c.JSON(http.StatusNotFound, gin.H{"error": "Child not found"})
		} else {
			log.Printf("Error fetching child status: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch status"})
		}
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": "success", "child": child})
}
