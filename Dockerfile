# Stage 1: Build Stage
FROM node:18-alpine AS build

# Install required dependencies for Node.js and Jekyll
RUN apk add --no-cache \
  ruby \
  ruby-dev \
  build-base \
  autoconf \
  automake \
  libtool \
  pkgconfig \
  nasm \
  zlib-dev \
  libpng-dev \
  && gem install bundler

# Set the working directory
WORKDIR /app

# Copy dependency files
COPY package*.json ./
COPY Gemfile Gemfile.lock ./

# Install Node.js dependencies and Ruby gems
RUN npm install
RUN bundler install

# Copy the rest of the application code
COPY . .

# Build the project (this will generate the static files in the _site directory)
RUN npm run build

# Stage 2: Production Stage
FROM node:18-alpine

# Install http-server globally to serve the static site
RUN npm install -g http-server

# Set the working directory for the final image
WORKDIR /app

# Copy the built static files from the build stage (from _site)
COPY --from=build /app/_site /app

# Expose port 8080 for http-server
EXPOSE 8080

# Start http-server to serve the static files in /app
CMD ["http-server", "/app", "-p", "8080"]
