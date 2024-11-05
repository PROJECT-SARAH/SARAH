<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Project Sarah - README</title>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; margin: 0; padding: 20px; background-color: #f4f4f4; color: #333; }
        h1, h2 { color: #0056b3; }
        pre { background: #e8e8e8; padding: 10px; border-radius: 5px; overflow-x: auto; }
        code { color: #d63384; }
        .container { max-width: 800px; margin: auto; background: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 0 10px rgba(0, 0, 0, 0.1); }
        .section { margin-top: 20px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Project Sarah - Server Automation Script</h1>
        <p><strong>Version:</strong> 1.6<br><strong>Author:</strong> Random Ryan</p>

        <p>This script automates the setup of a PHP server, runs Cloudflared to expose the server online, and sends the accessible link to a specified Telegram chat. It includes process management, dependency installation, and secure configurations.</p>

        <div class="section">
            <h2>Features</h2>
            <ul>
                <li>Installs necessary dependencies (PHP, curl, unzip, git).</li>
                <li>Sets up a PHP server on a specified host and port.</li>
                <li>Downloads and starts Cloudflared to expose the server online.</li>
                <li>Sends the server’s public URL to a specified Telegram chat.</li>
                <li>Configures security settings with <code>.htaccess</code> and <code>robots.txt</code> files.</li>
            </ul>
        </div>

        <div class="section">
            <h2>WSL2 Installation on Windows</h2>
            <p>Follow these steps to set up WSL2 (Windows Subsystem for Linux) on Windows with Debian and Kali Linux distributions:</p>
            <ol>
                <li><strong>Enable WSL2:</strong> Open PowerShell as Administrator and run:
                    <pre><code>dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart</code></pre>
                </li>
                <li><strong>Enable Virtual Machine Platform:</strong> This is required for WSL2.
                    <pre><code>dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart</code></pre>
                </li>
                <li><strong>Set WSL2 as the Default Version:</strong>
                    <pre><code>wsl --set-default-version 2</code></pre>
                </li>
                <li><strong>Install a Linux Distribution:</strong> Open the Microsoft Store and search for your preferred Linux distributions. Install both <strong>Debian</strong> and <strong>Kali Linux</strong> by selecting them and clicking <em>Get</em>.</li>
                <li><strong>Launch and Configure Distributions:</strong> After installation, open each distribution from the Start menu, and complete the initial setup (username and password).</li>
                <li><strong>Verify WSL Version:</strong> Check if WSL2 is running by executing:
                    <pre><code>wsl -l -v</code></pre>
                    You should see both Debian and Kali Linux with version 2.
                </li>
            </ol>
        </div>

        <div class="section">
            <h2>Prerequisites</h2>
            <ul>
                <li><strong>Operating System:</strong> Linux (Debian/Ubuntu/Kali on WSL2 recommended).</li>
                <li><strong>Access:</strong> Root or sudo privileges.</li>
                <li><strong>Telegram Bot:</strong> A bot token and chat ID.</li>
            </ul>
        </div>

        <div class="section">
            <h2>Installation</h2>
            <ol>
                <li><strong>Clone the Repository:</strong>
                    <pre><code>git clone https://github.com/your-username/your-repository.git
cd your-repository</code></pre>
                </li>
                <li><strong>Make the Script Executable:</strong>
                    <pre><code>chmod +x start_script.sh</code></pre>
                </li>
                <li><strong>Run the Script:</strong> The script automatically installs required dependencies, sets up directories, and prepares necessary files.
                    <pre><code>./start_script.sh</code></pre>
                </li>
            </ol>
        </div>

        <div class="section">
            <h2>Configuration</h2>
            <ol>
                <li><strong>Create a Telegram Bot:</strong> Go to <a href="https://t.me/BotFather" target="_blank">BotFather</a> on Telegram and create a bot. Obtain your bot’s token and the chat ID where you want to receive messages.</li>
                <li><strong>Set up the <code>.env</code> file:</strong> The script will create a <code>.env</code> file automatically if it doesn’t exist. Open it and set the following variables:
                    <pre><code>TELEGRAM_BOT_TOKEN=your_bot_token_here
TELEGRAM_CHAT_ID=your_chat_id_here</code></pre>
                </li>
                <li><strong>Verify Configuration:</strong> Ensure the <code>.env</code> file is configured with your Telegram bot token and chat ID.</li>
            </ol>
        </div>

        <div class="section">
            <h2>Usage</h2>
            <p><strong>Starting the Script:</strong> Run the script to start the PHP server and expose it with Cloudflared.</p>
            <pre><code>./start_script.sh</code></pre>
            <p><strong>Stopping the Server:</strong> The script automatically stops existing PHP and Cloudflared processes each time it runs, ensuring no duplicate processes.</p>
            <h3>Example Output</h3>
            <ol>
                <li>Script starts, displays project banner, and installs dependencies.</li>
                <li>PHP server starts and displays the local URL.</li>
                <li>Cloudflared starts and generates a public URL.</li>
                <li>The public URL is sent to the specified Telegram chat.</li>
            </ol>
        </div>

        <div class="section">
            <h2>Files Created</h2>
            <ul>
                <li><strong>your_site/login.php</strong>: A sample login page for the server.</li>
                <li><strong>your_site/.htaccess</strong>: Disables directory listing, secures <code>.env</code> file, and rewrites URLs.</li>
                <li><strong>your_site/robots.txt</strong>: Restricts search engine access to sensitive files.</li>
                <li><strong>your_site/other_php_files</strong>: Additional necessary PHP and CSS files are created as part of the project.</li>
                <li><strong>.env</strong>: Holds Telegram bot token and chat ID for notifications.</li>
            </ul>
        </div>

        <div class="section">
            <h2>Troubleshooting</h2>
            <ul>
                <li><strong>Missing Dependencies:</strong> Ensure that your system has <code>curl</code>, <code>php</code>, <code>git</code>, and other dependencies.</li>
                <li><strong>Telegram Notification Failure:</strong> Double-check the <code>TELEGRAM_BOT_TOKEN</code> and <code>TELEGRAM_CHAT_ID</code> in the <code>.env</code> file.</li>
                <li><strong>Cloudflared Issues:</strong> Check the <code>.server/cloudflared_output.log</code> for Cloudflared errors.</li>
            </ul>
        </div>

        <div class="section">
            <h2>License</h2>
            <p>This project is licensed under the MIT License. See <code>LICENSE</code> for more details.</p>
        </div>

        <p>Happy coding! Feel free to contribute to the project by opening issues or submitting pull requests.</p>
    </div>
</body>
</html>
