const express = require("express");
const app = express();

const PORT = 3000;

app.get("/", (req, res) => {
  res.send("Hello from Node App deployed via Jenkins + Kubernetes!!");
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});