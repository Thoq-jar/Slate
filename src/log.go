package slate

import (
	"fmt"
	"os"
	"time"
)

var logFile *os.File

/**
 * Function: createLogFile
 * Purpose: Make the file the session should log to
 * Use: createLogFile()
 * @see serveFile
 */
func createLogFile() {
	err := os.Mkdir("logs", 0755)
	if err != nil && !os.IsExist(err) {
		fmt.Printf("[%s] Error creating logs directory: %s\n", Name, err)
		return
	}

	currentTime := time.Now()
	logFileName := fmt.Sprintf("logs/%s-%s-slate.log", currentTime.Format("2006-01-02"), currentTime.Format("15-04-05"))
	logFile, err = os.OpenFile(logFileName, os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0666)
	if err != nil {
		fmt.Printf("[%s] Error creating log file: %s\n", Name, err)
		return
	}
}

/**
 * Function: logTraffic
 * Purpose: Log incoming requests to a file and console
 * Use: logTraffic(path, duration)
 * @see serveFile
 */
func logTraffic(path string, duration time.Duration) {
	currentTime := time.Now()
	logEntry := fmt.Sprintf("[%s] [%s] [%s] Latency: %s ..................... %s\n",
		Name,
		currentTime.Format("2006-01-02"),
		currentTime.Format("15:04:05"),
		duration,
		path)

	fmt.Print(logEntry)
	if logFile != nil {
		_, err := logFile.WriteString(logEntry)
		if err != nil {
			fmt.Printf("[%s] Failed to write to log file!\n", Name)
		}
	}
}

/**
 * Function: cleanup
 * Purpose: Close log file
 * Use: cleanup()
 * @see init
 */
func cleanup() {
	if logFile != nil {
		err := logFile.Close()
		if err != nil {
			fmt.Print("[%s] Failed to close log file!\n", Name)
		}
	}
}

/**
 * Function: init
 * Purpose: Initialize the logger
 * Use: init()
 */
func init() {
	defer cleanup()
}
