package main

import (
	"fmt"
	"log"
	"net/http"
)

func HelloWorld(res http.ResponseWriter, req *http.Request) {
	fmt.Fprint(res, "Hello World")
}

func PingPong(res http.ResponseWriter, req *http.Request) {
	fmt.Fprint(res, "Pong")
}

func HealthCheck(res http.ResponseWriter, req *http.Request) {
	fmt.Fprint(res, "Healthy")
}

func main() {
	http.HandleFunc("/", HelloWorld)
	http.HandleFunc("/ping", PingPong)
	http.HandleFunc("/health", HealthCheck)
	log.Fatal(http.ListenAndServe("0.0.0.0:8081", nil))
}
