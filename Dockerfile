FROM node:20-alpine

# Update Alpine packages to fix vulnerabilities
RUN apk update && apk upgrade && apk add --no-cache dumb-init

WORKDIR /usr/src/app

# Copy simple HTTP server (no external dependencies)
COPY app/server.js .

ENV PORT=8080
EXPOSE 8080

# Use dumb-init for proper signal handling
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "server.js"]


