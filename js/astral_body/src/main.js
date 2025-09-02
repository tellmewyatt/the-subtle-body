import { io } from 'socket.io-client'
import { FilesetResolver, DrawingUtils, PoseLandmarker } from '@mediapipe/tasks-vision'
const socket = io();
const video = document.querySelector("#webcam");
const canvasElement = document.querySelector("#webcamCanvas");
const canvasCtx = canvasElement.getContext("2d");
const drawingUtils = new DrawingUtils(canvasCtx);
document.querySelector("#startButton").onclick = () => {
  const landmarker = setupLandmarker().then(poseLandmarker => renderLoop(poseLandmarker, video));
}

if (navigator.mediaDevices.getUserMedia) {
  navigator.mediaDevices.getUserMedia({ video: true })
    .then(function (stream) {
      video.srcObject = stream;
    })
    .catch(function (error) {
      console.log("Something went wrong!");
    });
}
async function setupLandmarker() {
  const vision = await FilesetResolver.forVisionTasks(
    // path/to/wasm/root
    "https://cdn.jsdelivr.net/npm/@mediapipe/tasks-vision@latest/wasm"
  );
  const poseLandmarker = await PoseLandmarker.createFromOptions(
      vision,
      {
        baseOptions: {
          modelAssetPath: "/pose_landmarker_full.task",
        },
        runningMode: "VIDEO"
      });
  const fillBox = document.querySelector("#vidContainer");
  canvasElement.width = video.videoWidth;
  canvasElement.height= video.videoHeight;
  fillBox.width = video.videoWidth;
  fillBox.height= video.videoHeight;
  return poseLandmarker

}
let lastVideoTime = -1;
function processResults(result) {
  canvasCtx.save();
  canvasCtx.clearRect(0, 0, canvasElement.width, canvasElement.height);
  for (const landmark of result.landmarks) {
    drawingUtils.drawLandmarks(
      landmark, 
      {
        radius: data => DrawingUtils.lerp(
          data.from.z, 
          -0.15, 0.1, 5, 1)
      }
    );
    drawingUtils.drawConnectors(landmark, PoseLandmarker.POSE_CONNECTIONS);
  }
  canvasCtx.restore();
}
function renderLoop(poseLandmarker, video) {
  if (video.currentTime !== lastVideoTime) {
    const poseLandmarkerResult = poseLandmarker.detectForVideo(video, video.currentTime * 1000);
    processResults(poseLandmarkerResult);
    lastVideoTime = video.currentTime;
  }

  requestAnimationFrame(() => {
    renderLoop(poseLandmarker, video);
  });
}
