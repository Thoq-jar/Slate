package main

import (
	"Slate/src"
	"flag"
)

/**
 * Function: main
 * Purpose: Main entry point for Slate
 * Use: main()
 */
func main() {
	version := flag.Bool("v", false, "Display version information")
	flag.BoolVar(version, "version", false, "Display version information")

	flag.Parse()

	if *version {
		slate.Info()
		return
	}

	slate.Begin()
}
