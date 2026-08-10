# Use official Node.js 20 Alpine lightweight base image
FROM node:20-alpine

# Set working directory inside container
WORKDIR /app

# Copy package manifest files
COPY package*.json ./

# Install production dependencies
RUN npm install --only=production

# Copy application source files
COPY . .

# Expose port 3000
EXPOSE 3000

# Set environment variables
ENV NODE_ENV=production
ENV PORT=3000

# Start the Node Express server
CMD ["node", "server.js"]
