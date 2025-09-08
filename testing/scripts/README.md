# Moodle v4.5 Installation Script

## Overview

This directory contains an automated installation script for Moodle v4.5 (MOODLE_405_STABLE) on Ubuntu 22/24 systems. The script is fully automated and requires no human intervention during the installation process.

## Features

- **Fully Automated**: Complete installation without human intervention
- **Modular Design**: Each installation step is in its own function for easy troubleshooting
- **Comprehensive Logging**: All operations are logged with timestamps
- **Error Handling**: Proper error detection and reporting
- **Web Server Options**: Supports both Apache and Nginx
- **Security Hardening**: Includes production-ready security configurations
- **Backup System**: Automated daily database backups
- **Antivirus**: ClamAV installation and configuration

## Prerequisites

- Ubuntu 22.04 LTS or Ubuntu 24.04 LTS
- Root or sudo access
- Internet connection for package downloads
- At least 2GB RAM and 10GB disk space

## Usage

### Basic Installation

```bash
sudo ./install_moodle.sh
```

This will install Moodle with default settings using Apache as the web server.

### Installation with Options

```bash
sudo ./install_moodle.sh --webserver nginx --domain moodle.example.com --admin-email admin@example.com
```

### Available Options

| Option | Description | Default |
|--------|-------------|---------|
| `--webserver TYPE` | Web server type (apache or nginx) | apache |
| `--domain ADDRESS` | Domain name or IP address | Auto-detected IP |
| `--protocol PROTOCOL` | Protocol (http:// or https://) | http:// |
| `--site-name NAME` | Full site name | Moodle Site |
| `--site-shortname NAME` | Short site name | Moodle |
| `--admin-email EMAIL` | Administrator email address | admin@example.com |
| `--help` | Show help message | - |

## Installation Process

The script performs the following steps:

### Phase 1: System Preparation
1. **System Update**: Updates package lists and upgrades existing packages
2. **Base Packages**: Installs PHP 8.3, MariaDB, and required dependencies

### Phase 2: Web Server Installation
1. **Web Server**: Installs and configures Apache or Nginx
2. **PHP Configuration**: Optimizes PHP settings for Moodle

### Phase 3: Moodle Installation
1. **Code Download**: Clones Moodle v4.5 from GitHub
2. **Directory Setup**: Creates and secures moodledata directory
3. **Database**: Creates database and user with secure credentials
4. **CLI Installation**: Runs Moodle installation via command line
5. **Cron Setup**: Configures automated tasks

### Phase 4: Security Hardening
1. **Firewall**: Configures UFW with appropriate rules
2. **Database Security**: Sets root password and removes test databases
3. **Backup System**: Sets up automated daily backups
4. **Antivirus**: Installs and configures ClamAV

## Post-Installation

After successful installation, the script provides:

### Credentials
All credentials are automatically generated and saved to secure files:
- **Database Credentials**: `/root/.moodle_db_credentials`
- **Admin Credentials**: `/root/.moodle_admin_credentials`
- **MySQL Root**: `/root/.mysql_root`

### Access Information
The installation summary displays:
- Moodle URL
- Admin username and password
- Admin email address

### Next Steps
1. Access Moodle at the provided URL
2. Complete site registration
3. Configure additional settings as needed
4. Enable ClamAV in Site Administration > Plugins > Antivirus plugins
5. For production sites, enable HTTPS:
   ```bash
   sudo certbot --apache  # For Apache
   # or
   sudo certbot --nginx   # For Nginx
   ```

## Troubleshooting

### Log Files
- **Installation Log**: `/var/log/moodle_install_YYYYMMDD_HHMMSS.log`
- **Apache Logs**: `/var/log/apache2/moodle_error.log` and `moodle_access.log`
- **Nginx Logs**: `/var/log/nginx/error.log` and `access.log`

### Common Issues

1. **Permission Denied**: Ensure you're running the script with sudo or as root
2. **Package Not Found**: Update package lists with `apt-get update`
3. **Port Already in Use**: Stop existing web servers before installation
4. **Database Connection Failed**: Check MariaDB is running with `systemctl status mariadb`

### Function-Level Debugging
Each installation step is contained in its own function, making it easy to troubleshoot specific issues:

- `check_root()`: Privilege verification
- `check_ubuntu_version()`: OS compatibility check
- `update_system()`: System updates
- `install_base_packages()`: Package installation
- `install_apache()` / `install_nginx()`: Web server setup
- `configure_php()`: PHP configuration
- `obtain_moodle_code()`: Code download
- `setup_moodledata_directory()`: Data directory creation
- `setup_database()`: Database creation
- `configure_moodle_cli()`: Moodle installation
- `setup_cron()`: Cron job configuration
- `setup_firewall()`: Firewall rules
- `secure_database()`: Database hardening
- `setup_backup_system()`: Backup automation
- `setup_antivirus()`: ClamAV setup

To debug a specific function, you can add `set -x` before the function call and `set +x` after it in the main() function.

## Security Considerations

The script implements several security best practices:

1. **Random Passwords**: All passwords are randomly generated using OpenSSL
2. **Secure File Permissions**: Credential files are readable only by root (600)
3. **Database Security**: Removes anonymous users and test databases
4. **Firewall**: Only necessary ports are opened
5. **Directory Permissions**: Moodledata is secured with restrictive permissions
6. **Backup System**: Automated backups protect against data loss

## Customization

### Environment Variables
You can set environment variables before running the script:

```bash
export WEBSERVER_TYPE=nginx
export WEBSITE_ADDRESS=moodle.myschool.edu
export ADMIN_EMAIL=it@myschool.edu
sudo -E ./install_moodle.sh
```

### Configuration Variables
Edit these variables at the top of the script for permanent changes:
- `MOODLE_VERSION`: Git branch/tag to checkout
- `MOODLE_DIR`: Installation directory
- `MOODLEDATA_DIR`: Data storage directory
- `BACKUP_DIR`: Backup storage location

## License

This script is provided as-is for educational and administrative purposes. It follows the installation procedures documented in the official Moodle documentation.

## Support

For issues specific to this script, please check the troubleshooting section above. For Moodle-specific questions, refer to:
- [Moodle Documentation](https://docs.moodle.org/)
- [Moodle Forums](https://moodle.org/forums/)
- [Moodle Tracker](https://tracker.moodle.org/)
