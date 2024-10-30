pub fn index() -> String {
    const INDEX: &str = r#"
        <div class="wrapper">
            <h1 class="title">Hello, Slate!</h1>
            <button class="count" id="count">Count is: 0</button>
        </div>

        <script>
            const count = document.getElementById('count');
            let counter = 1;
            count.addEventListener('click', () => {
                count.textContent = `Count is: ${counter}`;
                counter++;
            });

            console.log('Hello Slate! \x1b[35m●\x1b[0m');
        </script>

        <style>
          body {
            background: #111;
            color: #fff;
            font-family: system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
            user-select: none;
            -webkit-user-select: none;
            -webkit-user-drag: none;
            -moz-user-select: none;
            -ms-user-select: none;
            height: 100vh;
            margin: 0;
            display: flex;
            align-items: center;
            justify-content: center;
          }

          .wrapper {
            text-align: center;
          }

          .title {
            font-size: 60px;
          }

          .count {
            background-color: #242424;
            color: #fff;
            padding: 20px;
            border-radius: 10px;
            font-size: 30px;
            outline: none;
            border: 2px solid transparent;
            transition: border 0.2s ease;
          }

          .count:hover {
            cursor: pointer;
            border: 2px solid rgba(139, 98, 244, 0.5);
          }
        </style>
        </body>
        </html>
    "#;
    return INDEX.to_string();
}

pub fn not_found() -> String {
    const NOT_FOUND: &str = r#"
        <html>
        <head><title>404 Not Found</title></head>
        <body>
        <h1>We've encountered an error:</h1>
        <h2>404 | Not Found</h2>
        <p>Sorry, the file you are looking for does not exist.</p>
        <h5>Powered by Slate</h5>
        <style>
        body {
            font-family: system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
            background-color: black;
            color: white;
            font-size: 16px;
            padding: 20px;
            text-align: center;
            margin: 0;
            height: 100vh;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
        }
        </style>
        </body>
        </html>
    "#;
    return NOT_FOUND.to_string();
}
