# Dockerfile for Strapi on ECS Fargate
FROM node:18-alpine

WORKDIR /opt/app

# Install dependencies for Strapi
RUN apk add --no-cache \
    build-base \
    gcc \
    autoconf \
    automake \
    zlib-dev \
    libpng-dev \
    vips-dev \
    git

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install --production=false

# Copy application files
COPY . .

# Set environment to development
ENV NODE_ENV=development

# Expose Strapi port
EXPOSE 1337

# Create a startup script that handles first-time setup
RUN echo '#!/bin/sh\n\
if [ ! -d ".cache" ]; then\n\
  echo "First run detected, building admin..."\n\
  npm run build || true\n\
fi\n\
echo "Starting Strapi..."\n\
exec npm run start\n\
' > /opt/app/start.sh && chmod +x /opt/app/start.sh

# Start Strapi using the startup script
CMD ["/opt/app/start.sh"]
