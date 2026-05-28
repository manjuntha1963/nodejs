# Use official Node.js LTS image based on Debian/Ubuntu
FROM node:24-bullseye

# Set working directory inside container
WORKDIR /usr/src/app

# Copy package files first for caching
COPY package*.json ./

# Install dependencies
RUN npm install --production

# Copy the rest of your app
COPY . .

# Expose the port your app listens on
EXPOSE 3000

# Start the app
CMD ["node", "app.js"]
