FROM public.ecr.aws/docker/library/ruby:3.2.2

# Set working directory
WORKDIR /app

# Install required packages including Nginx
RUN apt-get update -qq && apt-get install -y \
  build-essential libpq-dev nodejs curl redis nginx

# Install Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  && apt-get update && apt-get install -y yarn

# Install bundler
RUN gem install bundler

# Copy Gemfile and install gems
COPY Gemfile* ./
RUN bundle install

# Copy application code
COPY . .

# Prepare Rails app directories
RUN mkdir -p tmp/pids tmp/cache tmp/sockets log

# Precompile assets
RUN bundle exec rake assets:precompile

# Copy Nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80
EXPOSE 80

# Start Nginx (background) and then Puma (foreground)
CMD nginx && bundle exec puma -C config/puma.rb

