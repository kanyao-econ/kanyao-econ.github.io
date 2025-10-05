# Base image: Ruby with necessary dependencies for Jekyll
FROM ruby:3.2

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    nodejs \
    && rm -rf /var/lib/apt/lists/*


# Create a non-root user with UID 1000
RUN groupadd -g 1000 vscode && \
    useradd -m -u 1000 -g vscode vscode

# Set the working directory
WORKDIR /usr/src/app

# Set permissions for the working directory
RUN chown -R vscode:vscode /usr/src/app

# Switch to the non-root user
USER vscode

# Copy Gem files into the container (use lockfile to ensure matching deps)
COPY Gemfile Gemfile.lock ./



# Install bundler and dependencies
RUN gem install connection_pool:2.5.0 \
 && gem install bundler:2.3.26 \
 && bundle config set without "development" \
 && bundle install --jobs 4 --retry 3

# Command to serve the Jekyll site via bundler
CMD ["bundle", "exec", "jekyll", "serve", "-H", "0.0.0.0", "-w", "--config", "_config.yml,_config_docker.yml"]
