# Real-Time Chat App Deployment with Rails, PostgreSQL, Puma & Nginx in AWS EC2
This guide details the deployment of a **Real-Time Chat Application** built with Ruby on Rails (RoR). The app leverages Rails for its framework, PostgreSQL for persistent data storage, Puma as the application server to handle dynamic requests, and Nginx as the webserver to manage HTTP traffic. Designed to run on an Ubuntu server (version 22.04 based on PostgreSQL 14.17), this deployment ensures a scalable, production-ready environment for real-time communication.

## Ruby Version
- **Version**: Ruby 3.2.2
- Specified in the `Gemfile` and installed via RVM (Ruby Version Manager). This version ensures compatibility with Rails 7.0.8 and the application's dependencies.
- Installed with `rvm install 3.2.2`, allowing precise version control across environments.

## Deployment Guide for Ruby on Rails Application
This section provides an in-depth exploration of deploying a Ruby on Rails (RoR) application on an Ubuntu server. It covers every step, and details how each component interrelates to ensure a successful deployment.
| Component        | Role                                    |
|------------------|------------------------------------------|
| Nginx            | Web server, handles HTTP requests        |
| Puma             | Application server for Rails             |
| PostgreSQL       | Database server                          |
| Redis (optional) | Caching, ActionCable Pub/Sub backend     |

### Introduction
Deploying a Ruby on Rails application involves setting up the necessary infrastructure, installing dependencies, configuring servers, and ensuring the application runs smoothly in a production environment. The process outlined here uses Nginx as the webserver, Puma as the application server, and PostgreSQL as the database server. 

### System Requirements and Initial Setup
Before starting, ensure you have an Ubuntu server (version 22.04, inferred from the psql version 14.17) with root or sudo privileges. The initial steps focus on updating the system and installing necessary tools.

#### Step 1: Update and Upgrade System Packages
```bash
sudo apt-get update
sudo apt-get upgrade
```
- **What**: `sudo apt-get update` refreshes the package lists, while `sudo apt-get upgrade` installs the latest versions of installed packages.
- **Why**: Ensures the system is secure and up to date, reducing vulnerabilities and ensuring compatibility with new software.
- **How**: `apt-get update` fetches the latest package information from repositories, and `upgrade` applies updates to existing packages.
- **Interrelation**: This step is foundational, as outdated packages can cause installation failures later.

#### Step 2: Install Necessary Tools
```bash
sudo apt-get install curl gpg
```
- **What**: Installs `curl` for data transfer and `gpg` for secure communication and package verification.
- **Why**: These tools are essential for downloading RVM and verifying its integrity.
- **How**: `apt-get install` fetches and installs the specified packages from the repository.
- **Interrelation**: `curl` is used in subsequent steps to download RVM, and `gpg` ensures its authenticity.

### Ruby and Rails Installation
Ruby on Rails requires a specific Ruby version and the Rails framework, managed through RVM for flexibility.

#### Step 3: Install RVM (Ruby Version Manager)
First, import GPG keys for security:
```bash
gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
```
Then, install RVM:
```bash
\curl -sSL https://get.rvm.io | bash -s stable
```
Load RVM into the current shell:
```bash
source ~/.rvm/scripts/rvm
```
- **What**: RVM is a tool to manage multiple Ruby environments. The GPG keys ensure the installation script's authenticity.
- **Why**: Allows installing and switching between Ruby versions, crucial for compatibility.
- **How**: `curl` downloads the script, `bash` executes it, and `source` loads RVM into the shell.
- **Interrelation**: RVM sets the stage for installing Ruby, which Rails depends on.

#### Step 4: Install Ruby
```bash
rvm install 3.2.2
```
Verify RVM installation:
```bash
rvm -v
```
- **What**: Installs Ruby version 3.2.2 using RVM and checks the version.
- **Why**: The application requires a specific Ruby version for compatibility.
- **How**: `rvm install` downloads and compiles Ruby, and `rvm -v` verifies the installation.
- **Interrelation**: Ruby is the runtime for Rails, linking to the next step.

#### Step 5: Install Rails
```bash
gem install rails
```
- **What**: Installs the Rails gem, the framework for the application.
- **Why**: Rails is necessary to build and run the web application.
- **How**: `gem install` fetches and installs the Rails gem from RubyGems.
- **Interrelation**: Rails uses Ruby, connecting back to the previous step.

### JavaScript and Package Management
Rails applications often require JavaScript, managed through Node.js and Yarn.

#### Step 6: Install Node.js and Yarn
```bash
sudo apt-get install -y nodejs
sudo apt-get install -y yarn
```
- **What**: Installs Node.js for JavaScript runtime and Yarn for package management.
- **Why**: Needed for asset compilation and managing JavaScript dependencies.
- **How**: `apt-get install -y` installs without prompting for confirmation.
- **Interrelation**: These tools support Rails asset pipeline, linking to the application setup.

### Database Server Setup: PostgreSQL
PostgreSQL is the database server, storing application data.

#### Step 7: Install PostgreSQL
```bash
sudo apt-get install postgresql postgresql-contrib libpq-dev
```
- **What**: Installs PostgreSQL server, contrib modules, and development libraries.
- **Why**: PostgreSQL is the chosen database, and libpq-dev is needed for the pg gem.
- **How**: `apt-get install` fetches and installs from the repository.
- **Interrelation**: This sets up the database server, crucial for the application's data layer.

#### Step 8: Set Up PostgreSQL Database
Access PostgreSQL:
```bash
sudo -u postgres psql
```
Inside psql, execute:
```sql
CREATE USER myuser WITH PASSWORD 'mypassword';
ALTER ROLE myuser CREATEDB;
CREATE DATABASE chat_app_production OWNER myuser;
\q
```
- **What**: Creates a user (`myuser`), grants database creation rights, creates a production database, and exits.
- **Why**: Sets up the database environment for the application, ensuring secure access.
- **How**: SQL commands within psql configure the database.
- **Interrelation**: The database connects to the application via the DATABASE_URL in the environment, linking to later steps.

### Application Setup and Deployment
Now, clone the repository, configure the environment, and prepare the application for production.

#### Step 9: Install Git and Clone Repository
```bash
sudo apt-get install git
git clone https://github.com/im3shn/chat-app.git
cd chat-app
```
- **What**: Installs Git and clones the application repository, then navigates to the directory.
- **Why**: Git retrieves the application code, and `cd` sets the working directory.
- **How**: `apt-get install` installs Git, and `git clone` fetches the repository.
- **Interrelation**: This step initiates the application setup, leading to dependency installation.

#### Step 10: Set Up Environment Variables
Create and edit the `.env` file:
```bash
vi .env
```
Add:
```
RAILS_ENV=production
RAILS_MASTER_KEY=c3ca922688d4bf22ac7fe38430dd8849
DATABASE_URL=postgres://myuser:mypassword@localhost:5432/chat_app_production
SECRET_KEY_BASE=600f21de02355f788c759ff862a2cb22ba84ccbf072487992f4c2c49ae260f87c7593a1f5f6cf2e45457c76994779a8b30014ee9597e35a2818ca91e33bb7233
```
- **What**: Sets environment variables for production, database connection, and security.
- **Why**: Ensures the application runs in production mode with correct configurations.
- **How**: `vi` edits the file, and variables are manually entered.
- **Interrelation**: These variables are used in database.yml and Rails runtime, linking to configuration steps.

#### Step 11: Configure Database
Edit `config/database.yml`:
```bash
cd config/
vi database.yml
```
Ensure the production section is:
```yaml
production:
  <<: *default
  url: <%= ENV["DATABASE_URL"] %>
  pool: 5
```

<details>
  <summary>Click to view Complete database.yml file</summary>

root@ip-172-31-10-21:/var/www/chat-app/config# vi database.yml
```yml
# PostgreSQL. Versions 9.3 and up are supported.
#
# Install the pg driver:
#   gem install pg
# On macOS with Homebrew:
#   gem install pg -- --with-pg-config=/usr/local/bin/pg_config
# On macOS with MacPorts:
#   gem install pg -- --with-pg-config=/opt/local/lib/postgresql84/bin/pg_config
# On Windows:
#   gem install pg
#       Choose the win32 build.
#       Install PostgreSQL and put its /bin directory on your path.
#
# Configure Using Gemfile
# gem "pg"
#
default: &default
  adapter: postgresql
  encoding: unicode
  # For details on connection pooling, see Rails configuration guide
  # https://guides.rubyonrails.org/configuring.html#database-pooling
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  database: chat_app_development

  # The specified database role being used to connect to postgres.
  # To create additional roles in postgres see `$ createuser --help`.
  # When left blank, postgres will use the default role. This is
  # the same name as the operating system user running Rails.
  #username: chat_app

  # The password associated with the postgres role (username).
  #password:

  # Connect on a TCP socket. Omitted by default since the client uses a
  # domain socket that doesn't need configuration. Windows does not have
  # domain sockets, so uncomment these lines.
  #host: localhost
                                                                     
  # The TCP port the server listens on. Defaults to 5432.
  # If your server runs on a different port number, change accordingly.
  #port: 5432

  # Schema search path. The server defaults to $user,public
  #schema_search_path: myapp,sharedapp,public

  # Minimum log levels, in increasing order:
  #   debug5, debug4, debug3, debug2, debug1,
  #   log, notice, warning, error, fatal, and panic
  # Defaults to warning.
  #min_messages: notice

# Warning: The database defined as "test" will be erased and
# re-generated from your development database when you run "rake".
# Do not set this db to the same as development or production.
test:
  <<: *default
  database: chat_app_test

# As with config/credentials.yml, you never want to store sensitive information,
# like your database password, in your source code. If your source code is
# ever seen by anyone, they now have access to your database.
#
# Instead, provide the password or a full connection URL as an environment
# variable when you boot the app. For example:
#
#   DATABASE_URL="postgres://myuser:mypass@localhost/somedatabase"
#
# If the connection URL is provided in the special DATABASE_URL environment
# variable, Rails will automatically merge its configuration values on top of
# the values provided in this file. Alternatively, you can specify a connection
# URL environment variable explicitly:
#
#   production:
#     url: <%= ENV["MY_APP_DATABASE_URL"] %>
#
# Read https://guides.rubyonrails.org/configuring.html#configuring-a-database
# for a full overview on how database connection configuration can be specified.
#
production:
  <<: *default
  url: <%= ENV["DATABASE_URL"] %>
  pool: 5
```
  
</details>

- **What**: Configures the database connection using the environment variable.
- **Why**: Allows flexible and secure database configuration without hardcoding credentials.
- **How**: Edit the YAML file to use the DATABASE_URL from `.env`.
- **Interrelation**: Links the application to PostgreSQL, ensuring data access.

#### Step 12: Install Application Dependencies and Migrate Database
Install gems:
```bash
bundle install
```
Run migrations:
```bash
RAILS_ENV=production rails db:migrate
```
Verify DATABASE_URL:
```bash
RAILS_ENV=production rails runner 'puts ENV["DATABASE_URL"]'
```
- **What**: Installs gems from Gemfile, applies database schema changes, and verifies the database URL.
- **Why**: Ensures all dependencies are installed and the database is ready.
- **How**: `bundle install` reads Gemfile, `rails db:migrate` applies migrations, and `rails runner` executes Ruby code.
- **Interrelation**: These steps prepare the application for production, linking to the database server.

#### Step 13: Precompile Assets
```bash
rails assets:precompile RAILS_ENV=production
```
- **What**: Compiles assets (CSS, JS, images) for production.
- **Why**: Optimizes asset delivery for performance.
- **How**: Rails command compiles assets into static files.
- **Interrelation**: Assets are served by Nginx, linking to the webserver setup.

### Webserver Configuration: Nginx
Nginx acts as the webserver, handling HTTP requests and proxying to Puma.

#### Step 14: Install and Configure Nginx
Install Nginx:
```bash
sudo apt-get install nginx
```
Create configuration:
```bash
sudo vi /etc/nginx/sites-available/chat-app
```
Add:
```nginx
server {
  listen 80;
  server_name 13.201.223.210;
  root /home/ubuntu/chat-app/public;
  location / {
    proxy_pass [invalid url, do not cite]
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  }
}
```
Enable and restart:
```bash
sudo ln -s /etc/nginx/sites-available/chat-app /etc/nginx/sites-enabled/
sudo systemctl restart nginx
```
- **What**: Installs Nginx, configures it to proxy to Puma, enables the config, and restarts the service.
- **Why**: Nginx serves as the entry point, forwarding dynamic requests to Puma.
- **How**: `apt-get install` installs, `vi` edits the config, `ln -s` enables, and `systemctl restart` applies changes.
- **Interrelation**: Nginx proxies to Puma, linking the webserver to the application server.

### Application Server Configuration: Puma
Puma runs the Rails application, handling dynamic requests.

#### Step 15: Start Puma
```bash
RAILS_ENV=production bundle exec puma -C config/puma.rb
```
- **What**: Starts Puma in production mode using the specified configuration.
- **Why**: Runs the Rails application to handle requests.
- **How**: `bundle exec puma` executes Puma with the config file.
- **Interrelation**: Puma receives requests from Nginx and interacts with PostgreSQL for data.

### Additional Services: Redis
Redis may be used for caching or background jobs.

#### Step 16: Install and Verify Redis
Install Redis:
```bash
sudo apt install redis
```
Check status:
```bash
systemctl status redis
```
Edit `.env` if needed:
```bash
vi .env
```
Restart Nginx if changes:
```bash
systemctl restart nginx
sudo systemctl restart nginx
```
Restart Puma:
```bash
RAILS_ENV=production bundle exec puma -C config/puma.rb
```
- **What**: Installs Redis, checks its status, edits environment variables, and restarts services.
- **Why**: Ensures Redis is running for caching, and updates configurations.
- **How**: Standard installation and service commands.
- **Interrelation**: Redis may interact with Puma for caching, linking to the application server.

### Servers and Their Roles
- **Webserver (Nginx)**: Handles HTTP requests, serves static files, and proxies dynamic requests to Puma. Configured to listen on port 80 and forward to localhost:3000.
- **Application Server (Puma)**: Runs the Rails application, processing dynamic requests and interacting with PostgreSQL. Starts with `bundle exec puma`.
- **Database Server (PostgreSQL)**: Stores application data, configured with a user and database for production. Accessed via `psql` for setup.


# Interrelation of Components
## **Flow**: Client → Nginx → Puma → PostgreSQL/Redis → Puma → Nginx → Client.
The deployment process is interconnected:
1. **Nginx** receives HTTP requests from clients.
2. For static files, Nginx serves them directly from `/home/ubuntu/chat-app/public`.
3. For dynamic requests, Nginx proxies to **Puma** on localhost:3000, setting headers for request routing.
4. **Puma** processes requests using the Rails application, which queries **PostgreSQL** for data via the DATABASE_URL.
5. Responses flow back through Puma to Nginx, then to the client.
6. **Redis**, if used, may cache data or handle background jobs, interacting with Puma.

This flow ensures a seamless user experience, with each component playing a critical role.

---
---

## Step-by-Step Guide: Setting Up Amazon RDS for RoR App on EC2

### Step 1: Launch the EC2 Instance (if not already created)
1. **Go to EC2 Dashboard** → Instances → **Launch instance**.
2. Choose Amazon Linux 2 / Ubuntu 22.04.
3. Instance type: e.g., **t2.micro (free tier eligible)**.
4. Create a **new security group** (or select existing):
   - Allow **SSH (port 22)** from your IP.
   - Allow **HTTP (port 80)** from anywhere.
   - Leave HTTPS and other ports closed for now.

---

### Step 2: Create a Security Group for RDS

1. Go to **EC2 Dashboard** → **Security Groups** → **Create Security Group**.
2. Name: `rds-chat-db-sg`
3. Description: Security group for chat app RDS PostgreSQL.
4. VPC: Select the default VPC (or the one EC2 is in).
5. Under **Inbound Rules**, add:
   - **Type**: PostgreSQL
   - **Protocol**: TCP
   - **Port range**: 5432
   - **Source**: Choose “**Custom**” and select your **EC2 security group** (not IP address!). This ensures only your EC2 can connect to the RDS instance.

6. Click **Create Security Group**.

---

### Step 3: Create the RDS PostgreSQL Instance

1. Go to **RDS Dashboard** → **Create Database**.
2. Choose:
   - **Standard create**
   - **Engine**: PostgreSQL
   - **Version**: Select a supported version (e.g., 14.x)
3. Settings:
   - DB instance identifier: `chat-app-db`
   - Master username: `myuser`
   - Master password: `mypassword` (store securely)
4. Instance class: `db.t3.micro` (free tier if available)
5. Storage: Leave default (or increase as needed).
6. Connectivity:
   - **VPC**: Same VPC as EC2
   - **Public access**: **No** (for best security; or Yes if you want to test with pgAdmin later)
   - **VPC security group**: **Select existing**, and choose `rds-chat-db-sg`
7. Database options:
   - Initial DB name: `chat_app_production`

8. Click **Create database**

RDS will take a few minutes to initialize.

---

### Step 4: Modify EC2 Security Group (if needed)

Modify EC2 Security Group to Allow Outbound PostgreSQL
By default, EC2 security groups allow all outbound traffic. If you've restricted outbound, make sure to allow this:

Go to ec2-sg → Outbound Rules → Ensure:

Type: PostgreSQL

Port: 5432

Destination: rds-sg (or just All traffic for development)

---

### Step 5: Connect to RDS from EC2 (Test)

SSH into EC2:

```bash
psql -h <your-rds-endpoint> -U myuser -d chat_app_production -W
```

Replace `<your-rds-endpoint>` with something like:
```
chat-app-db.xxxxxxxxxxx.us-east-1.rds.amazonaws.com
```

If it connects, you're good!

---

### Step 6: Update Rails `.env` File

On your EC2, edit `.env` inside your Rails app:

```bash
vi /home/ubuntu/chat-app/.env
```

Update the `DATABASE_URL`:

```env
DATABASE_URL=postgres://myuser:mypassword@<your-rds-endpoint>:5432/chat_app_production
```

---

### Step 7: Finalize Rails Configuration

```bash
cd /home/ubuntu/chat-app/
bundle install
RAILS_ENV=production rails db:migrate
rails assets:precompile RAILS_ENV=production
```

 **Done!** We now have:
- RDS PostgreSQL securely set up.
- EC2 and RDS allowed to communicate.
- Your Rails app ready to use a remote, scalable database.

---
## Key Citations
- [Guide to Deploy a Ruby on Rails App Using AWS EC2](https://rajputlakhveer.medium.com/guide-to-deploy-a-ruby-on-rails-app-using-aws-ec2-c067c2c4e414)
- [Ruby Version Manager Installation Guide](https://rvm.io/rvm/install)
- [Nginx Configuration Documentation](https://nginx.org/en/docs/)
- [Puma Web Server for Ruby](https://puma.io/)
- [PostgreSQL Installation on Ubuntu](https://www.postgresql.org/download/linux/ubuntu/)

