package slate

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
)

/**
 * Function: checkNodeModules
 * Purpose: Check for node_modules
 * Use: checkNodeModules(rootDir, packageManager)
 * @see Begin
 */
func checkNodeModules(rootDir, packageManager string) {
	if _, err := os.Stat(filepath.Join(rootDir, "node_modules")); os.IsNotExist(err) {
		if _, err := os.Stat(filepath.Join(rootDir, "package.json")); !os.IsNotExist(err) {
			fmt.Printf("[%s] Running %s install in %s...\n", Name, packageManager, rootDir)
			cmd := exec.Command(packageManager, "install")
			cmd.Dir = rootDir
			if err := cmd.Run(); err != nil {
				fmt.Printf("[%s] Error running install command: %s\n", Name, err)
			}
		} else {
			fmt.Printf("[%s] No package.json found, cannot install dependencies.\n", Name)
		}
	} else {
		fmt.Printf("[%s] node_modules directory exists, no need to install.\n", Name)
	}
}

/**
 * Function: checkDeno
 * Purpose: Check for deno project
 * Use: checkDeno(rootDir string)
 * @see Begin
 */
func checkDeno(rootDir string) {
	if _, err := os.Stat(filepath.Join(rootDir, "deno.json")); os.IsNotExist(err) {
		fmt.Printf("[%s] No deno.json found, cannot proceed with Deno.\n", Name)
	} else {
		fmt.Printf("[%s] Deno is specified as the package manager, deno.json found.\n", Name)
	}
}
