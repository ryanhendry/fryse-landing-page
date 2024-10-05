# Stage 1: Build Stage
FROM node:18-bullseye AS build

# Install Ruby and Bundler
RUN apt-get update && apt-get install -y \
    ruby-full \
    build-essential \
    && gem install bundler

# Set the working directory
WORKDIR /app

# Copy the project files
COPY . .

# Install Node.js dependencies
RUN npm install

# Install Ruby gems
RUN bundler install

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