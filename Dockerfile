# Container image for CERN PaaS (OKD) or any OCI runtime.
# Red Hat UBI base: pulled from registry.access.redhat.com (no Docker Hub rate
# limits) and built to run under OKD's restricted SCC with an arbitrary UID.
FROM registry.access.redhat.com/ubi9/nodejs-22-minimal

WORKDIR /opt/app-root/src

COPY --chown=1001:0 package.json package-lock.json ./
RUN npm ci --omit=dev && npm cache clean --force

COPY --chown=1001:0 server.js ./
COPY --chown=1001:0 db ./db
COPY --chown=1001:0 public ./public

ENV NODE_ENV=production \
    HOST=0.0.0.0 \
    PORT=8080

USER 1001
EXPOSE 8080

# One Node process per pod — scale with replicas instead of PM2 cluster mode
CMD ["node", "server.js"]
