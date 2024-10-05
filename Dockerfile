# Stage 1: Build Stage
FROM node:18-bullseye AS build

# Install required packages
RUN apt-get update && apt-get install -y \
ruby \
ruby-dev \
build-essential \
autoconf \
automake \
libtool \
pkg-config \
nasm \
zlib1g-dev \
&& gem install bundler

# Set the working directory
WORKDIR /app

# Copy dependency files first (leverage caching)
COPY package*.json ./
COPY Gemfile ./

# Install Node.js dependencies
RUN npm install

# Install Ruby gems
RUN bundler install

# Copy the rest of the application code
COPY . .

# Build the project
RUN npm run build

# Stage 2: Production Stage
FROM nginx:alpine

# Copy the built assets to Nginx's default directory
COPY --from=build /app/assets /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
