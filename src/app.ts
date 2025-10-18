// src/server.js
import express from "express";
import cors from "cors";
import dotenv from "dotenv";

// import { router } from "./routes/indexRoute.js";

dotenv.config();

export const app = express();

app.use(cors());
app.use(express.json());

app.get("/", (req, res) => res.send("BrawlCards Origins API - Online ✅"));
// app.use("/api", router);



