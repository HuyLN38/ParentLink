package firebase

import (
	"github.com/gin-gonic/gin"
	"log"
	"net/http"
	"net/smtp"
)

func Send(c *gin.Context) {
	from := "vanphucprince@gmail.com"
	pass := "ojlw acez nxdz pngu"
	body := "Hello, I'm a fucking bot"
	to := "duynhu586@gmail.com"

	msg := "From: " + "ParentLink" + "\n" +
		"To: " + to + "\n" +
		"Subject: Register verification\n\n" +
		body

	err := smtp.SendMail("smtp.gmail.com:587",
		smtp.PlainAuth("", from, pass, "smtp.gmail.com"),
		from, []string{to}, []byte(msg))

	if err != nil {
		log.Printf("smtp error: %s", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, map[string]string{"status": "Gmail sent successfully"})
}
