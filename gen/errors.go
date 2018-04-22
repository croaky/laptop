package main

import "fmt"

func printError(err error) {
	if err != nil {
		fmt.Println("[gen] Error:", err)
	}
}
