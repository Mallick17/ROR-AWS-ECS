# Real-Time Chat App Deployment with Rails, PostgreSQL, Puma & Nginx in AWS EC2
This guide details the deployment of a **Real-Time Chat Application** built with Ruby on Rails (RoR). The app leverages Rails for its framework, PostgreSQL for persistent data storage, Puma as the application server to handle dynamic requests, and Nginx as the webserver to manage HTTP traffic. Designed to run on an Ubuntu server (version 22.04 based on PostgreSQL 14.17), this deployment ensures a scalable, production-ready environment for real-time communication.

## Ruby Version
- **Version**: Ruby 3.2.2
- Specified in the `Gemfile` and installed via RVM (Ruby Version Manager). This version ensures compatibility with Rails 7.0.8 and the application's dependencies.
- Installed with `rvm install 3.2.2`, allowing precise version control across environments.

## Deployment Guide for Ruby on Rails Application
This section provides an in-depth exploration of deploying a Ruby on Rails (RoR) application on an Ubuntu server. It covers every step, explains the roles of the webserver (Nginx), application server (Puma), and database server (PostgreSQL), and details how each component interrelates to ensure a successful deployment.

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

### Interrelation of Components
The deployment process is interconnected:
1. **Nginx** receives HTTP requests from clients.
2. For static files, Nginx serves them directly from `/home/ubuntu/chat-app/public`.
3. For dynamic requests, Nginx proxies to **Puma** on localhost:3000, setting headers for request routing.
4. **Puma** processes requests using the Rails application, which queries **PostgreSQL** for data via the DATABASE_URL.
5. Responses flow back through Puma to Nginx, then to the client.
6. **Redis**, if used, may cache data or handle background jobs, interacting with Puma.

This flow ensures a seamless user experience, with each component playing a critical role.

## Key Citations
- [Guide to Deploy a Ruby on Rails App Using AWS EC2](https://rajputlakhveer.medium.com/guide-to-deploy-a-ruby-on-rails-app-using-aws-ec2-c067c2c4e414)
- [Ruby Version Manager Installation Guide](https://rvm.io/rvm/install)
- [Nginx Configuration Documentation](https://nginx.org/en/docs/)
- [Puma Web Server for Ruby](https://puma.io/)
- [PostgreSQL Installation on Ubuntu](https://www.postgresql.org/download/linux/ubuntu/)

