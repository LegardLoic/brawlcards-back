import { app } from "./src/app.js";
import { config } from "./server.config.js";
// import { registerWs } from "./src/sockets/index.js";
import http from "http";
import { Server as SocketIOServer } from "socket.io";
// import { WsRuntime } from "./src/sockets/index.js";

// HTTP + WS
const httpServer = http.createServer(app);
// const io = new SocketIOServer(httpServer, {
//   cors: { origin: "*", methods: ["GET", "POST"] },
// });

// WsRuntime.io = io;

// // branche la logique WS dans un module dédié
// registerWs(io);

const port = config.server.port;
httpServer.listen(port, () => console.log(`✅ HTTP+WS sur ${port}`));