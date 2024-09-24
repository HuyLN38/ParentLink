package firebase

import (
	"bytes"
	"fmt"
	"github.com/gin-gonic/gin"
	"gopkg.in/gomail.v2"
	"html/template"
	"log"
	"net/http"
)

type info struct {
	OTP string
}

func Send(c *gin.Context, email string, code string) {
	input := info{
		OTP: code,
	}

	m := gomail.NewMessage()

	t := template.New("mail.html")

	var err error
	t, err = t.ParseFiles("mail.html")
	if err != nil {
		log.Println(err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to parse email template"})
		return
	}
	var tpl bytes.Buffer
	if err := t.Execute(&tpl, input); err != nil {
		log.Println(err)
	}

	result := tpl.String()

	// Set the sender's name and email
	m.SetHeader("From", m.FormatAddress("vanphucprince@gmail.com", "ParentLink"))

	// Set the recipient's email
	m.SetHeader("To", email)

	// Set the subject of the email
	m.SetHeader("Subject", "Hello!")

	// Set the body of the email
	m.SetBody("text/html", result)

	// Create a new dialer with the SMTP server details
	d := gomail.NewDialer("smtp.gmail.com", 587, "vanphucprince@gmail.com", "ojlw acez nxdz pngu")

	// Send the email
	if err := d.DialAndSend(m); err != nil {
		log.Printf("smtp error: %s", err)
		fmt.Println("Failed to send email: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, map[string]string{"status": fmt.Sprintf("Gmail sent to %s successfully", email)})
}
