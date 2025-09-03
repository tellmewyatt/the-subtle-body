import { FilesetResolver, DrawingUtils, PoseLandmarker } from '@mediapipe/tasks-vision'
import { socket } from './socket'
import { addScoreKeyListeners } from './score'
const video = document.querySelector("#webcam");
const canvasElement = document.querySelector("#webcamCanvas");
const canvasCtx = canvasElement.getContext("2d");
const drawingUtils = new DrawingUtils(canvasCtx);

const landmarkList = [
    "nose",
    "left eye (inner)",
    "left eye",
    "left eye (outer)",
    "right eye (inner)",
    "right eye",
    "right eye (outer)",
    "left ear",
    "right ear",
    "mouth (left)",
    "mouth (right)",
    "left shoulder",
    "right shoulder",
    "left elbow",
    "right elbow",
    "left wrist",
    "right wrist",
    "left pinky",
    "right pinky",
    "left index",
    "right index",
    "left thumb",
    "right thumb",
    "left hip",
    "right hip",
    "left knee",
    "right knee",
    "left ankle",
    "right ankle",
    "left heel",
    "right heel",
    "left foot index",
    "right foot index"
]

if (navigator.mediaDevices.getUserMedia) {
  navigator.mediaDevices.getUserMedia({ video: true })
    .then(function (stream) {
      video.srcObject = stream;
    })
    .then(() => setupLandmarker().then(poseLandmarker => renderLoop(poseLandmarker, video)))
    .catch(function (error) {
      console.log("Something went wrong!");
    });
}
async function setupLandmarker() {
  const vision = await FilesetResolver.forVisionTasks(
    "/wasm"
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
  socket.emit("landmarks", result.worldLandmarks[0]);
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
addScoreKeyListeners();
