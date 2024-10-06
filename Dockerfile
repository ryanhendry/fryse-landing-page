# Stage 1: Build Stage
FROM node:18-alpine AS build

# Install required packages
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

# Copy dependency files first (leverage caching)
COPY package*.json ./
COPY Gemfile Gemfile.lock ./

# Install Node.js dependencies
RUN npm install

# Install Ruby gems
RUN bundler install

# Copy the rest of the application code
COPY . .

# Build the project
RUN npm run build

# Stage 2: Production Stage
FROM node:18-alpine

# Install http-server globally
RUN npm install -g http-server

# Set the working directory in the final image
WORKDIR /app

# Copy the built static files from the build stage
COPY --from=build /app/assets /app

# Expose the port that http-server will run on
EXPOSE 8080

# Start http-server to serve your static files
CMD ["http-server", "/app", "-p", "8080"]
