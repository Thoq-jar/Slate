package slate

import "fmt"

// Purple //
// Reset //
/**
 * Variables: Purple, Reset
 * Purpose: Define global ansi escape codes
 */
var Purple = "\033[35m"
var Reset = "\033[0m"

// Logo //
// Name //
// Version //
// Information //
/**
 * Variables: Logo, Name, Version, Information
 * Purpose: Define global information about slate
 */
var Logo = Purple + "●" + Reset
var Name = "Slate"
var Version = 1.1
var Information = fmt.Sprintf("%s %.1f", Name, Version)
