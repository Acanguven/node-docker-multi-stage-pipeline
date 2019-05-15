###################################################
#
# Configuration
#
###################################################
ENV BUILD_USER=build
ENV APPLICATION_USER=application
ENV NODE_VERSION=10

###################################################
#
# Build OS Setup Stage
#
###################################################
FROM node:${NODE_VERSION}-alpine AS os

# Build dependencies for most nodejs builds
RUN apk add --update --no-cache \
    python \
    make \
    g++

# Create node user
RUN addgroup -S appgroup && adduser -S $BUILD_USER -G appgroup

# Create nonroot secure application user
USER $BUILD_USER

# Set workdir as user folder
WORKDIR /home/$BUILD_USER

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

# Create node user
RUN addgroup -S appgroup && adduser -S $APPLICATION_USER -G appgroup

# Create nonroot secure application user
USER $APPLICATION_USER

# Set workdir as user folder
WORKDIR /home/$APPLICATION_USER

# Copy production dependencies from the pruned stage at line 32
COPY --from=install /tmp/production_modules node_modules

# Copy the builded code from line 29
COPY --from=build /home/$BUILD_USER/dist dist

# Expose port
EXPOSE 4444

# Start Application
CMD ["node", "./dist/server.js"]
