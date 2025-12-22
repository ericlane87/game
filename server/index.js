import http from 'http';

const PORT = process.env.PORT || 3000;

const server = http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({
    status: 'ok',
    message: 'Autonomous dev department scaffold server',
    path: req.url
  }));
});

server.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
