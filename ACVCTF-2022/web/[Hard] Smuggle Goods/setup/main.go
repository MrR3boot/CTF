package main

import (
    "fmt"
    "golang.org/x/net/http2"
    "golang.org/x/net/http2/h2c"
    "net/http"
    "io/ioutil"
    "os"
)

func checkErr(err error, msg string) {
    if err == nil {
        return
    }
    fmt.Printf("ERROR: %s: %s\n", msg, err)
    os.Exit(1)
}

func main() {
    H2CServerUpgrade()
}

func H2CServerUpgrade() {
    h2s := &http2.Server{}

    handler := http.NewServeMux()
    handler.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	fmt.Fprintf(w, "{\"Message\":\"Welcome to Cell Controller API\"}")
    })

    handler.HandleFunc("/api/v2/credentials", func(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
        fmt.Fprintf(w, "{\"username\":\"tamayo\",\"password\":\"dCf3VkFt04Ds92S\",\"app\":\"/cell-dev\"}");
    })

    handler.HandleFunc("/api/v2/config", func(w http.ResponseWriter, r *http.Request) {
        w.Header().Set("Content-Type", "application/json")
	dat, err := ioutil.ReadFile("/root/nginx.conf")
        _ = err
	fmt.Fprintf(w,string(dat))
    })
    server := &http.Server{
        Addr:    "0.0.0.0:9999",
        Handler: h2c.NewHandler(handler, h2s),
    }

    checkErr(server.ListenAndServe(), "while listening")
}
