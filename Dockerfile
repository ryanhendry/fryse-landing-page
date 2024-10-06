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
FROM nginx:alpine

# Copy the built assets to Nginx's default directory
COPY --from=build /app/assets /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
