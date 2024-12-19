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
	firebase.InitFirebase()

	// Create a new router
	router := gin.Default()
	router.Use(CORSMiddleware())
	router.POST("parentlink/register", firebase.RegisterHandler)
	router.POST("parentlink/login", firebase.LoginHandler)

	router.POST("parentlink/users/:staticID/children", firebase.AddChild)
	router.GET("parentlink/users/:staticID/children", firebase.GetChildren)
	router.GET("parentlink/users/:staticID/childrenlist", firebase.GetChildrenList)
	router.GET("parentlink/users/:staticID/children-location/:childID", firebase.GetChildrenLocation)

	router.GET("parentlink/users/:staticID/children-avatar/:childID", firebase.GetChildAvatar)
	router.GET("parentlink/users/:staticID/children-status/:childID", firebase.GetChildrenStatus)
	router.POST("parentlink/users/children-location/:childID", firebase.UpdateChildrenLog)
	router.GET("parentlink/users/children-location/:childID", firebase.GetChildrenLog)

	router.GET("parentlink/users/:staticID/children/:childID", firebase.CheckIfChildExists)
	router.PUT("parentlink/users/:staticID/children/:childID", firebase.UpdateChildLocation)

	router.DELETE("parentlink/users/:staticID/children/:childID", firebase.DeleteChild)

	router.DELETE("parentlink/users/:staticID", firebase.DeleteUser)
	router.GET("parentlink/users/:staticID", firebase.CheckAccount)
	router.POST("parentlink/changePassword/", firebase.ChangePassword)
	router.GET("parentlink/hello-world", myGetFunction)
	router.GET("parentlink/register/:otp", firebase.ValidateOTP)
	router.GET("parentlink/send", func(c *gin.Context) {
		email := "iloveTokuda@gmail.com"
		code := "696969"
		firebase.Send(c, email, code)
	})

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
