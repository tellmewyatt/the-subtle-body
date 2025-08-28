import subprocess
from argparse import ArgumentParser
import os
import atexit
from pathlib import Path
import astral_body
import requests
from astral_body import PROJECT_PATH, PYTHON_ENV

def download_file(url, outpath):
    # NOTE the stream=True parameter below
    with requests.get(url, stream=True) as r:
        r.raise_for_status()
        with open(outpath, 'wb') as f:
            for chunk in r.iter_content(chunk_size=8192): 
                # If you have chunk encoded response uncomment if
                # and set chunk_size parameter to None.
                #if chunk: 
                f.write(chunk)
def cli():
    parser = ArgumentParser()
    parser.add_argument("--ip", default="127.0.0.1", help="The ip of the OSC server")
    parser.add_argument("--port", type=int, default=57120, help="The port the OSC server is listening on")
    parser.add_argument("--video-only", action='store_true', help="If set, only creates the video process. (For development only)")
    parser.add_argument("--fetch-model", help="If set, downloads the model from google.", action='store_true')
    args = parser.parse_args()
    if args.fetch_model:
        url = "https://storage.googleapis.com/mediapipe-models/pose_landmarker/pose_landmarker_full/float16/latest/pose_landmarker_full.task"
        model_path = os.path.join(PROJECT_PATH, "models/pose_landmarker_full.task")
        os.makedirs(os.path.dirname(model_path), exist_ok=True)
        download_file(url, model_path)

    else:
        processes = []
        processes.append(subprocess.Popen([PYTHON_ENV, "-m", "astral_body.main", "--ip", str(args.ip), "--port", str(args.port)]))
        if not args.video_only:
            try: 
                process = subprocess.Popen(["sclang", os.path.join(PROJECT_PATH, "supercollider/main.scd")])
                processes.append(process)
            # Expect sclang to be in the path, but if not, try other expected locations on mac
            except FileNotFoundError:
                process = subprocess.Popen(["/Applications/SuperCollider.app/Contents/MacOS/sclang", os.path.join(PROJECT_PATH, "supercollider/main.scd")])
                processes.append(process)
            except FileNotFoundError:
                process = subprocess.Popen(["/Applications/SuperCollider/SuperCollider.app/Contents/MacOS/sclang", os.path.join(PROJECT_PATH, "supercollider/main.scd")])
                processes.append(process)
                
        def kill_subprocesses():
            for process in processes:
                process.terminate()
        while True:
            user_input = input()
            if user_input.lower() == 'q':
                break
        atexit.register(kill_subprocesses)
if __name__ == "__main__":
    cli()
