###################################################
#
# Configuration
#
###################################################
ARG BUILD_USER=build
ARG APPLICATION_USER=application
ARG NODE_VERSION=10

###################################################
#
# Build OS Setup Stage
#
###################################################
FROM node:${NODE_VERSION}-alpine AS os

# Load global arguments with default values to variables in stage context
ARG BUILD_USER
ENV buildUser=$BUILD_USER

# Build dependencies for most nodejs builds
RUN apk add --update --no-cache \
    python \
    make \
    g++

# Create node user
RUN addgroup -S appgroup && adduser -S $buildUser -G appgroup

# Create nonroot secure application user
USER $buildUser

# Set workdir as user folder
WORKDIR /home/$buildUser

###################################################
#
# Install Stage
#
###################################################
FROM os AS install

# Copy package.json & package-lock.json
COPY package*.json ./

# Install production dependencies
RUN npm i --only=production

# Reserve production ready packages for cleanup stage
RUN cp -R node_modules /tmp/production_modules

# Install all dependencies
RUN npm ci

# Copy source code
COPY . .

###################################################
#
# Quality Stage
#
###################################################
FROM install AS quality

# Start quaility tasks
RUN npm run test

###################################################
#
# Build Stage
#
###################################################
FROM quality AS build

# Start build task
RUN npm run build

###################################################
#
# Reporting Stage
#
###################################################

# Send report files from quality stage to remote services
# FROM quality AS reporting

###################################################
#
# Production Stage
#
###################################################
FROM node:${NODE_VERSION}-alpine

# Load global arguments with default values to variables in stage context
ARG APPLICATION_USER
ARG BUILD_USER
ENV applicationUser=$APPLICATION_USER
ENV buildUser=$BUILD_USER

# Create node user
RUN addgroup -S appgroup && adduser -S $applicationUser -G appgroup

# Create nonroot secure application user
USER $applicationUser

# Set workdir as user folder
WORKDIR /home/$applicationUser

# Copy production dependencies from the pruned stage at line 50
COPY --from=install /tmp/production_modules node_modules

# Copy the built code from line 76
COPY --from=build /home/$buildUser/dist dist

# Expose port
EXPOSE 4444

# Start Application
CMD ["node", "./dist/server.js"]
