# Stage 1: Build Stage
FROM node:18-alpine AS build

# Install Ruby and Bundler
RUN apk add --no-cache ruby ruby-dev build-base && \
    gem install bundler

# Set the working directory
WORKDIR /app

# Copy dependency files first (leverage caching)
COPY package*.json ./
RUN npm install

COPY Gemfile Gemfile.lock ./
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