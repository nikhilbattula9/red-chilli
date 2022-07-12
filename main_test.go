package main

import (
	"net/http"
	"testing"
	
)

// mock definition of http response writer
type testWriter struct {
}

func (*testWriter) Header() http.Header {
	return nil
}

func (*testWriter) Write([]byte) (int, error) {
	return 0, nil
}

func (*testWriter) WriteHeader(statusCode int) {
}

func TestHelloWorld(t *testing.T) {
	res := new(testWriter)
	HelloWorld(res, nil)
	t.Fail()
}
