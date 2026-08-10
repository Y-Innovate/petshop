// Default for local development (npm run dev / npm run build outside the
// container). The Docker image overwrites this exact file at container
// startup - see docker/40-generate-runtime-config.sh - so in production it
// carries the real API_BASE_URL instead of null.
window.__RUNTIME_CONFIG__ = null;
