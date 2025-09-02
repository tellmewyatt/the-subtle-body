import express from "express";
import ViteExpress from "vite-express";
import { Server } from "socket.io";
import { Client as OscClient } from 'node-osc';
import dgram from 'dgram'

const osc = new OscClient('127.0.0.1', 3333);
const app = express();

const server = ViteExpress.listen(app, 3000, () => console.log("Server is listening..."))
const io = new Server(server);
io.on('connection', (socket) => {
  console.log('a user connected');
  socket.on('landmarks', (landmarks) =>  {
    try {
      // send as flat xyz pairs
      if (landmarks)
        osc.send('/pose_landmarks', 
          landmarks.flatMap(({x, y, z}) => [x,y,z]));
    }
    catch (error){
      console.log("caught the following error while getting a landmarks message");
      console.error(error);
    }
  });
  socket.on('disconnect', () => {
    console.log('user disconnected');
  });
});
