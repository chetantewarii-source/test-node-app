const express = require("express");
const path = require("path");

const app = express();
const PORT = 3000;

function square(num) {
    return num * num;
}

app.use(express.static("public"));

app.get("/", (req, res) => {
    res.sendFile(path.join(__dirname, "public", "index.html"));
});

app.get("/square", (req, res) => {
    const num = parseInt(req.query.num);

    if (isNaN(num)) {
        return res.json({ error: "Please provide a valid number" });
    }

    res.json({
        input: num,
        square: square(num)
    });
});

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});

module.exports = square;