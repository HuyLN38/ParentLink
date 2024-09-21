package firebase

import (
	"github.com/gin-gonic/gin"
	"gopkg.in/gomail.v2"
	"log"
	"net/http"
)

func Send(c *gin.Context) {
	m := gomail.NewMessage()

	// Set the sender's name and email
	m.SetHeader("From", m.FormatAddress("vanphucprince@gmail.com", "ParentLink"))

	// Set the recipient's email
	m.SetHeader("To", "lynhathuy38@gmail.com")

	// Set the subject of the email
	m.SetHeader("Subject", "Hello!")

	// Set the body of the email
	m.SetBody("text/html", "Hello <b>Kate</b> and <i>Noah</i>!")

	// Create a new dialer with the SMTP server details
	d := gomail.NewDialer("smtp.gmail.com", 587, "vanphucprince@gmail.com", "ojlw acez nxdz pngu")

	// Send the email
	if err := d.DialAndSend(m); err != nil {
		log.Printf("smtp error: %s", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, map[string]string{"status": "Gmail sent successfully"})
}
