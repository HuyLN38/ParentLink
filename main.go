package main

import (
	"TestAPI/firebase"
	"github.com/gin-gonic/gin"
	"log"
	"net/http"
	"os"
)

func CORSMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Writer.Header().Set("Access-Control-Allow-Origin", "*")
		c.Writer.Header().Set("Access-Control-Allow-Credentials", "true")
		c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, accept, origin, Cache-Control, X-Requested-With")
		c.Writer.Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS, GET, PUT, DELETE")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}

		c.Next()
	}
}

//func testsendEmail(c *gin.Context) {
//	err := sendEmail("lynhathuy38@gmail.com", "Test Subject", "This is the email body.")
//	if err != nil {
//		log.Fatalf("Failed to send email: %v", err)
//	}
//}

func main() {
	// Initialize Firebase
	firebase.initFirebase()

	// Create a new router
	router := gin.Default()
	router.Use(CORSMiddleware())
	router.POST("/register", firebase.registerHandler)
	router.POST("/login", firebase.loginHandler)
	router.POST("/users/:staticID/children", firebase.addChild)
	router.GET("/users/:staticID/children", firebase.getChildren)
	router.DELETE("/users/:staticID", firebase.deleteUser)
	router.POST("/changePassword", firebase.changePassword)
	router.GET("/hello-world", myGetFunction)
	//router.POST("/sendEmail", testsendEmail)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8000"
	}
	if err := router.Run(":" + port); err != nil {
		log.Panicf("error: %s", err)
	}

	log.Printf("Server is starting on port %s...", port)
	log.Fatal(router.Run(":" + port))
}

type simpleMessage struct {
	Hello   string `json:"hello"`
	Message string `json:"message"`
}

func myGetFunction(c *gin.Context) {
	simpleMessage := simpleMessage{
		Hello:   "World!",
		Message: "Subscribe to my channel!",
	}

	c.IndentedJSON(http.StatusOK, simpleMessage)
}
