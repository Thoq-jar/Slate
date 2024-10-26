package slate

import (
	"fmt"
	"net"
	"net/http"
	"time"
)

/**
 * Function: serveFile
 * Purpose: Serve a file
 * Use: serveFile(rootDir, file, host, port)
 * @see Begin
 */
//goland:noinspection HttpUrlsUsage
func serveFile(rootDir, file, host, port string) {
	address := fmt.Sprintf("%s:%s", host, port)
	if host == "0.0.0.0" {
		localIP, err := getLocalIP()
		if err != nil {
			fmt.Printf("[%s] Error getting local IP: %s\n", Name, err)
			return
		}

		fmt.Printf("  - File: %s\n", file)
		fmt.Printf("  - Local: http://%s/%s\n", address, file)
		fmt.Printf("  - Network: http://%s:%s/%s\n\n", localIP, port, file)
	} else {
		fmt.Printf("  - File: %s\n", file)
		fmt.Printf("  - Local: http://%s/%s\n", address, file)
		fmt.Printf("  - Network: Set host to 0.0.0.0 to expose server!\n")
	}

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		w.Header().Set("X-Powered-By", "Slate")
		w.Header().Set("Server", "Slate")
		http.FileServer(http.Dir(rootDir)).ServeHTTP(w, r)
		duration := time.Since(start)
		logTraffic(r.URL.Path, duration)
	})

	err := http.ListenAndServe(address, nil)
	if err != nil {
		fmt.Printf("[%s] Error starting server: %s", Name, err)
	}
}

/**
 * Function: getLocalIP
 * Purpose: Get the computer's IP address
 * Use: getLocalIP() (string, error)
 * @see serveFile
 */
func getLocalIP() (string, error) {
	address, err := net.InterfaceAddrs()
	if err != nil {
		return "", err
	}
	for _, addr := range address {
		if ipnet, ok := addr.(*net.IPNet); ok && !ipnet.IP.IsLoopback() && ipnet.IP.To4() != nil {
			return ipnet.IP.String(), nil
		}
	}
	return "", fmt.Errorf("no valid IP address found")
}
