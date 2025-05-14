from model import create_landmarker
from argparse import ArgumentParser
import os
from pythonosc import udp_client

# A list of the landmark indices
# 0 - nose
# 1 - left eye (inner)
# 2 - left eye
# 3 - left eye (outer)
# 4 - right eye (inner)
# 5 - right eye
# 6 - right eye (outer)
# 7 - left ear
# 8 - right ear
# 9 - mouth (left)
# 10 - mouth (right)
# 11 - left shoulder
# 12 - right shoulder
# 13 - left elbow
# 14 - right elbow
# 15 - left wrist
# 16 - right wrist
# 17 - left pinky
# 18 - right pinky
# 19 - left index
# 20 - right index
# 21 - left thumb
# 22 - right thumb
# 23 - left hip
# 24 - right hip
# 25 - left knee
# 26 - right knee
# 27 - left ankle
# 28 - right ankle
# 29 - left heel
# 30 - right heel
# 31 - left foot index
# 32 - right foot index

def main(udp_ip, udp_port):

    osc_client = udp_client.SimpleUDPClient(udp_ip, udp_port)
    def tick(result, image, timestamp):

        os.system("clear")
        if len(result.pose_world_landmarks) > 0:
            landmarks = result.pose_world_landmarks[0]
            for landmark in landmarks:
                print(landmark)
            osc_client.send_message("/right_wrist_x", landmarks[16].x)
            osc_client.send_message("/right_wrist_y", landmarks[16].x)
        
    create_landmarker(tick)
if __name__ == "__main__":
    parser = ArgumentParser()
    parser.add_argument("--ip", default="127.0.0.1", help="The ip of the OSC server")
    parser.add_argument("--port", type=int, default=5005, help="The port the OSC server is listening on")
    args = parser.parse_args()
    main(args.ip, args.port)
