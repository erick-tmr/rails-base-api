# syntax=docker/dockerfile:1
# check=error=true

# This Dockerfile is designed for production, not development. Use with Kamal or build'n'run by hand:
# docker build -t rails_base_api .
# docker run -d -p 80:80 -e RAILS_MASTER_KEY=<value from config/master.key> --name rails_base_api rails_base_api

# For a containerized dev environment, see Dev Containers: https://guides.rubyonrails.org/getting_started_with_devcontainer.html

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.4.2
# ------------------------------------------------------------------------------
# Base Stage: Runtime dependencies
# ------------------------------------------------------------------------------
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Rails app lives here
WORKDIR /rails

# Install essential runtime libraries and utilities
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# ------------------------------------------------------------------------------
# Build Dependencies Stage: Installs tools needed to build gems
# ------------------------------------------------------------------------------
FROM base AS build_deps

# Install packages needed to build gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev pkg-config libyaml-dev && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install Bundler
ARG BUNDLER_VERSION=2.5.11 # Or your preferred Bundler version
RUN gem install bundler -v $BUNDLER_VERSION

# Set common Bundler configuration
ENV BUNDLE_PATH="/usr/local/bundle"
WORKDIR /rails

# ------------------------------------------------------------------------------
# Development Stage
# ------------------------------------------------------------------------------
FROM build_deps AS development

ENV RAILS_ENV="development" \
    BUNDLE_WITHOUT="production" \
    PORT="3000"

# Install all gems (including development and test)
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local without "$BUNDLE_WITHOUT" && \
    bundle install

# Copy the rest of the application code
COPY . .

# Development server
EXPOSE 3000
CMD ["bin/rails", "server", "-b", "0.0.0.0"]

# ------------------------------------------------------------------------------
# Test Stage
# ------------------------------------------------------------------------------
FROM build_deps AS test

ENV RAILS_ENV="test" \
    BUNDLE_WITHOUT="production"

# Install all gems (including development and test)
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local without "$BUNDLE_WITHOUT" && \
    bundle install

# Copy the rest of the application code
COPY . .

# Default command for test stage (can be overridden)
CMD ["bin/rails", "test"]


# ------------------------------------------------------------------------------
# Production Build Stage: Builds assets and bundles production gems
# ------------------------------------------------------------------------------
FROM build_deps AS production_build

ENV RAILS_ENV="production" \
    BUNDLE_WITHOUT="development:test" \
    BUNDLE_DEPLOYMENT="1"

# Install production gems
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local without "$BUNDLE_WITHOUT" && \
    bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# ------------------------------------------------------------------------------
# Final Production Stage: Minimal runtime image
# ------------------------------------------------------------------------------
FROM base AS production

ENV RAILS_ENV="production" \
    # Make sure BUNDLE_PATH matches build stage
    BUNDLE_PATH="/usr/local/bundle"

# Copy built artifacts: gems, application code, assets
COPY --from=production_build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=production_build /rails /rails

# Run and own only the runtime files as a non-root user for security
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    # Ensure necessary directories exist and have correct permissions
    mkdir -p log tmp/pids storage && \
    chown -R rails:rails db log storage tmp && \
    # Ensure entrypoint is executable
    chmod +x /rails/bin/docker-entrypoint

USER 1000:1000

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start server via Thruster by default, this can be overwritten at runtime
# Keep original port
EXPOSE 80
CMD ["./bin/thrust", "./bin/rails", "server"]
