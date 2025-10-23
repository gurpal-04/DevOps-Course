const express = require("express");
const path = require("path");
const bodyParser = require("body-parser");

const app = express();
const PORT = process.env.PORT || 3000;

// serve static files from /public
app.use(express.static(path.join(__dirname, "public")));
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());

// simple route for health
app.get("/health", (req, res) => {
    res.json({ status: "ok" });
});

// endpoint that proxies form submission to Flask backend (optional)
app.post("/submit", async (req, res) => {
    const backendUrl = process.env.BACKEND_URL || "http://backend:5000/submit-form";

    try {
        // forward form as x-www-form-urlencoded
        const response = await fetch(backendUrl, {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: new URLSearchParams(req.body)
        });

        const data = await response.json();
        res.status(response.status).json(data);
    } catch (err) {
        console.error("Error contacting backend:", err);
        res.status(500).json({ success: false, error: "Failed to contact backend." });
    }
});

app.listen(PORT, () => {
    console.log(`Frontend running on port ${PORT}`);
});
