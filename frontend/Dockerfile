# Stage 1: Build Stage
FROM node:14-alpine AS build

WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Copy the entire application code
COPY . .

# Build the application
RUN npm run build

# Stage 2: Production Stage
FROM node:14-alpine

WORKDIR /app

# Set environment variable for PATH
ENV PATH /app/node_modules/.bin:$PATH

# Copy only necessary files from the build stage
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist

# Expose the application port
EXPOSE 3000

# Command to run the application
CMD ["npm", "start"]
