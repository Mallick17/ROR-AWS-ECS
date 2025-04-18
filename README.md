# Real Time Ruby on Rails Chat App Deployment using Docker
Deploying a Ruby on Rails (RoR) application using Docker and Docker Compose involves creating three key files: `Dockerfile`, `docker-compose.yml`, and `.env`. These files work together to containerize the application, manage its dependencies, and configure the environment.

---
## 🚀 Step-by-Step Deployment Guide (Rails + Docker + PostgreSQL AWS-RDS + Redis)

### ✅ Prerequisites

- Docker & Docker Compose installed
- Rails app ready (you already have it)
- `.env` file with production secrets
- Puma configured in `config/puma.rb`

---

### 🗂 Step 1: Project Structure

Make sure your Rails app folder looks like this:

```
chat-app/
├── Dockerfile
├── docker-compose.yml
├── .env
├── Gemfile
├── Gemfile.lock
├── config/
│   └── database.yml
│   └── puma.rb
├── app/
├── ...
```

---

## Create Dockerfile

<details>
  <summary>Click to view Dockerfile</summary>

ubuntu@ip-172-31-44-76:~/chat-app$ cat Dockerfile

```Dockerfile
# Dockerfile

FROM ruby:3.2.2
## This pulls the official Ruby 3.2.2 image from Docker Hub (Docker Hub),
## which includes Ruby and a Debian-based Linux environment.
## This is the foundation for the container, ensuring compatibility with the RoR applica                                                                                                tion.

# Set working directory
WORKDIR /app

## Sets the working directory inside the container to /app,
## where all subsequent commands will execute.
## This is where the application code will reside,
## following best practices for organization.

# Install packages
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs curl redis

## Updates the package list quietly (-qq) and installs essential packages:
### build-essential: Provides compilers and libraries (e.g., gcc, make) needed for building software.
### libpq-dev: Development files for PostgreSQL, required for the pg gem used in Rails for database connectivity.
### nodejs: JavaScript runtime, necessary for asset compilation (e.g., Webpacker or Sprockets).
### curl: A tool for transferring data, used here for installing additional tools like Yarn.
## redis: Installs the Redis server, likely used for caching or real-time features like ActionCable.
## This step ensures the container has all system-level dependencies for the RoR app.

# Install Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  && apt-get update && apt-get install -y yarn

## Installs Yarn, a package manager for JavaScript, which is often used in Rails for managing frontend dependencies:
### First, adds the Yarn GPG key for secure package verification.
### Adds the Yarn repository to the sources list.
### Updates the package list and installs Yarn.
## This is crucial for applications using JavaScript frameworks or asset pipelines.

# Install bundler
RUN gem install bundler

## Installs Bundler, the Ruby dependency manager,
## which reads the Gemfile to install gems.
## This ensures the RoR application has all required Ruby libraries.

# Copy Gemfiles and install dependencies
COPY Gemfile* ./
RUN bundle install

## Copies the Gemfile and Gemfile.lock to the container,
## then runs bundle install to install the gems specified.
## This step is done early to leverage Docker layer caching,
## improving build times if the Gemfile doesn't change.

# Copy rest of the application
COPY . .
## Copies the entire application code from the host to the container's /app directory.
## This includes all source files, configurations, and assets.

# Ensure tmp directories exist
RUN mkdir -p tmp/pids tmp/cache tmp/sockets log
## Creates directories for temporary files, cache, sockets, and logs.
## The -p flag ensures parent directories are created if they don't exist,
## preventing errors. These directories are standard for Rails applications,
## used by Puma and other processes.


# Precompile assets (optional for production)
RUN bundle exec rake assets:precompile

## Precompiles assets (CSS, JavaScript) for production using the rake
## assets:precompile task. This step is optional but recommended for production
## to improve performance by serving precompiled assets, reducing server load.

# Expose the app port
EXPOSE 3000

## Informs Docker that the container listens on port 3000 at runtime.
## This is the default port for Rails applications using Puma,
## making it accessible externally when mapped.

# Start the app with Puma
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]

## Specifies the default command to run when the container starts.
## It uses Bundler to execute Puma, the web server for Rails,
## with the configuration file config/puma.rb.
## This starts the application, listening on port 3000.

```

</details>

---

## Create `docker-compose.yml`
The `docker-compose.yml` file defines and orchestrates the services needed for the application, ensuring they communicate and start in the correct order. It uses version 3.8 of the Compose file format for modern features.

<details>
  <summary>Click to view docker-compose.yml</summary>

ubuntu@ip-172-31-44-76:~/chat-app$ cat docker-compose.yml
```yml
version: '3.8'

services:
  web:
    build: .
    image: chat-app:latest
    command: bash -c "rm -f tmp/pids/server.pid && bundle exec puma -C config/puma.rb"
    volumes:
      - .:/app
    ports:
      - "3000:3000"
    env_file:
      - .env
    environment:
      RAILS_ENV: production
      DATABASE_URL: postgres://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}
      REDIS_URL: redis://redis:6379/0
    depends_on:
      - redis
    restart: always

  redis:
    image: redis:7
    container_name: redis
    restart: always
    ports:
      - "6379:6379"
```

</details>

-----------------------------------------------------------------------------------

<details>
  <summary>Click to view the explained docker-compose.yml</summary>

- **Version and Services**:
  - Command: `version: '3.8'`
  - Explanation: Specifies the Docker Compose file format version, ensuring compatibility with recent Docker features.

- **Web Service Configuration**:
  - **Build**: `build: .`
    - Explanation: Instructs Docker Compose to build the image using the `Dockerfile` in the current directory (`.`).
  - **Image**: `image: chat-app:latest`
    - Explanation: Names the built image `chat-app:latest`, making it identifiable for future use or deployment.
  - **Command**: `command: bash -c "rm -f tmp/pids/server.pid && bundle exec puma -C config/puma.rb"`
    - Explanation: Overrides the default command from the `Dockerfile`. It runs a bash command that:
      - Removes any existing server PID file (`rm -f tmp/pids/server.pid`) to prevent conflicts if the server was previously running.
      - Starts Puma with the configuration file `config/puma.rb` using Bundler.
    - This ensures a clean start, avoiding issues like "address already in use."
  - **Volumes**: `volumes: - .:/app`
    - Explanation: Mounts the current directory (`.`) on the host to `/app` in the container. This allows for live code changes to be reflected inside the container without rebuilding, useful for development but should be handled carefully in production for security.
  - **Ports**: `ports: - "3000:3000"`
    - Explanation: Maps port 3000 on the host to port 3000 in the container, making the RoR application accessible at `localhost:3000` or the server's IP on port 3000.
  - **Environment Files**: `env_file: - .env`
    - Explanation: Loads environment variables from the `.env` file, which includes database credentials, Redis URL, and secret keys, into the container.
  - **Environment Variables**: `environment: RAILS_ENV: production DATABASE_URL: postgres://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME} REDIS_URL: redis://redis:6379/0`
    - Explanation: Sets specific environment variables:
      - `RAILS_ENV: production`: Ensures the Rails application runs in production mode, affecting caching, logging, and error reporting.
      - `DATABASE_URL`: Constructs the PostgreSQL connection URL using variables from `.env`, enabling the app to connect to the RDS instance.
      - `REDIS_URL: redis://redis:6379/0`: Sets the Redis connection to point to the `redis` service on port 6379, using the default database 0.
    - Note: The `REDIS_URL` is also in `.env`, but this explicitly sets it, potentially overriding for clarity.
  - **Dependencies**: `depends_on: - redis`
    - Explanation: Ensures the `redis` service starts before the `web` service. This is crucial for applications relying on Redis, like for caching or ActionCable, though it doesn't guarantee Redis is fully ready (additional health checks may be needed).
  - **Restart Policy**: `restart: always`
    - Explanation: Configures the container to always restart if it stops, ensuring uptime, which is suitable for production environments.

- **Redis Service Configuration**:
  - **Image**: `image: redis:7`
    - Explanation: Uses the official Redis 7 image from Docker Hub ([Docker Hub](https://hub.docker.com/_/redis)), providing an in-memory data store for caching or real-time features.
  - **Container Name**: `container_name: redis`
    - Explanation: Names the container `redis`, making it easier to identify and manage.
  - **Restart Policy**: `restart: always`
    - Explanation: Ensures the Redis container restarts if it stops, maintaining availability.
  - **Ports**: `ports: - "6379:6379"`
    - Explanation: Maps port 6379 on the host to port 6379 in the container, allowing external access to Redis if needed, though in production, this might be restricted for security.
  
</details>

---

## Create or Edit `.env` file
The `.env` file contains environment variables that configure the RoR application and are used by Docker Compose. 

<details>
  <summary>Click to view .env file</summary>


ubuntu@ip-172-31-44-76:~/chat-app$ cat .env
```env
# **RAILS_ENV=production**
## Set the Rails environment to production,
## affecting how the app behaves,
## such as enabling caching and detailed error reporting.
RAILS_ENV=production

# Database connection details for your RDS
## Explanation: These variables hold the credentials and connection details for a PostgreSQL database hosted on AWS RDS.
## They are used to construct the `DATABASE_URL` in `docker-compose.yml`.
DB_USER=myuser
DB_PASSWORD=mypassword
DB_HOST=chat-app.c342ea4cs6ny.ap-south-1.rds.amazonaws.com
DB_PORT=5432
DB_NAME=chat-app

# Redis config
## Specifies the Redis connection URL, pointing to the `redis` service on port 6379,
## database 0. This is redundant with the `environment` in `docker-compose.yml`,
## but ensures consistency.
REDIS_URL=redis://redis:6379/0

# Security Keys
## These are secret keys used by Rails for decrypting credentials (`RAILS_MASTER_KEY`)
## and cryptographic purposes like signing cookies (`SECRET_KEY_BASE`).
## They must be kept secure and not committed to version control.
RAILS_MASTER_KEY=c3ca922688d4bf22ac7fe38430dd8849
SECRET_KEY_BASE=600f21de02355f788c759ff862a2cb22ba84ccbf072487992f4c2c49ae260f87c7593a1f5f6cf2e45457c76994779a8b30014ee9597e35a2818ca91e33bb7233

```

</details>

---

## Edit `database.yml` file

<details>
  <summary>Click to view database.yml file</summary>
  
ubuntu@ip-172-31-44-76:~/chat-app/config$ vi database.yml
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
  database: chat-app      ## add database name given in AWS RDS
  username: myuser        ## add username given in DB AWS RDS
  password: <%= ENV["CHAT_APP_DATABASE_PASSWORD"] %>
  pool: 5
```

</details>

---

### Add `.dockerignore` file

<details>
  <summary>Click to view .dockerignore file</summary>

ubuntu@ip-172-31-44-76:~/chat-app$ cat .dockerignore
```
log/*
tmp/*
*.log
*.pid
.env
```

</details>

---


