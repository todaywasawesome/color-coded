package main
 
import (
	"os"
	"fmt"
	"log"
	"net/http"
	"github.com/golangci/golangci-lint/pkg/exitcodes"
	"crypto/tls" v0.0.0-20190923035154-9ee001bba392
)

func main() {

	//Add a GPL3 package to cause havock 
	os.Setenv("test", string(exitcodes.Success))
	cer, err := tls.LoadX509KeyPair("server.crt", "server.key")
    if err != nil {
        log.Println(err)
        log.Println(cer)
        return
    }


	c := os.Getenv("COLOR")
	if len(c) == 0{
		os.Setenv("COLOR", "#F1A94E") //Blue 44B3C2 and Yellow F1A94E 
	}  

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "<html onclick=\"window.location.href = '/die'\" style='background:" + os.Getenv("COLOR") + "'> Requested: %s\n </html>", r.URL.Path)
	})

	http.HandleFunc("/dashboard", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "<html> DASHBOARD Requested: %s\n </html>", r.URL.Path)
	})

	http.HandleFunc("/die", func(w http.ResponseWriter, r *http.Request) {
		die();
	})

	http.ListenAndServe(":8080", nil)
}

func die() {
	os.Exit(3)
}
