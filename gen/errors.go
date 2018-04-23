package main

import (
	"fmt"
	"os"
)

func must(err error) {
	if err != nil {
		fmt.Println("[error] " + err.Error())
		os.Exit(1)
	}
}
