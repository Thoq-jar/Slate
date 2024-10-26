package slate

import (
	"fmt"
	"gopkg.in/yaml.v2"
	"os"
	"path/filepath"
)

// Begin //
/**
 * Function: Begin
 * Purpose: Start Slate
 * Use: Begin()
 * @see main
 */
func Begin() {
	data, err := os.ReadFile("slate.yml")
	if err != nil {
		fmt.Printf("[%s] Error reading slate.yml: %s\n", Name, err)
		return
	}

	var slate Slate
	err = yaml.Unmarshal(data, &slate)
	if err != nil {
		fmt.Printf("[%s] Error parsing YAML: %s\n", Name, err)
		return
	}

	fmt.Printf("%s %s\n", Logo, Information)

	project := slate.Slate.Project
	packageManager := project.PackageManager
	rootDir := project.RootDir
	mainFile := project.Main
	host := project.Host
	port := project.Port

	mainFilePath := filepath.Join(rootDir, mainFile)
	if _, err := os.Stat(mainFilePath); os.IsNotExist(err) {
		fmt.Printf("[%s] Main file %s does not exist in the specified root directory %s.\n", Name, mainFile, rootDir)
		return
	}

	createLogFile()

	switch packageManager {
	case "npm", "pnpm", "yarn":
		checkNodeModules(rootDir, packageManager)
	case "slate":
		serveFile(rootDir, mainFile, host, port)
	case "deno":
		checkDeno(rootDir)
	default:
		fmt.Printf("[%s] Unknown package manager: %s\n", Name, packageManager)
	}
}
