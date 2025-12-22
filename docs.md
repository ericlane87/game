# Ops Notes for stoop-runner

- Managed by manager.js and agents/*
- Queue tasks in tasks.json; manager will process on next run.
- Server: `npm start` (Node HTTP on port 3000)
- Tests: `npm test` (uses built-in node:test)

## Next Steps
1. Add real endpoints to server/index.js
2. Flesh out client UI in client/index.html or your preferred stack
3. Extend tests in tests/ to cover new behavior
