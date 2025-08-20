from astral_body.model import create_landmarker
from argparse import ArgumentParser
import pandas as pd
import os
from pythonosc import udp_client
import itertools

# A list of the landmark indices
landmark_list = [
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

def main(udp_ip, udp_port):

    osc_client = udp_client.SimpleUDPClient(udp_ip, udp_port)
    def tick(result, image, timestamp):

        if len(result.pose_world_landmarks) > 0:
            landmarks = result.pose_world_landmarks[0]
            df = pd.DataFrame([{
                "name": landmark_list[i],
                "x": landmark.x,
                "y": landmark.y,
                "z": landmark.z
            } for i, landmark in enumerate(landmarks)])
            # Send landmarks as a flat list of x,y,z pairs
            osc_client.send_message("/pose_landmarks", list(itertools.chain.from_iterable([(landmark.x, landmark.y, landmark.z) for landmark in landmarks])))
        
    create_landmarker(tick)
if __name__ == "__main__":
    parser = ArgumentParser()
    parser.add_argument("--ip", default="127.0.0.1", help="The ip of the OSC server")
    parser.add_argument("--port", type=int, default=57120, help="The port the OSC server is listening on")
    args = parser.parse_args()
    main(args.ip, args.port)
    os.system("clear")
