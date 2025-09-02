import express from "express";
import ViteExpress from "vite-express";
import { Server } from "socket.io";

const app = express();


const server = ViteExpress.listen(app, 3000, () => console.log("Server is listening..."))
const io = new Server(server);
io.on('connection', (socket) => {
  console.log('a user connected');
  socket.on('message', value => console.log(value));
  socket.on('disconnect', () => {
    console.log('user disconnected');
  });
});
