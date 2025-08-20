import subprocess
from argparse import ArgumentParser
import os
import atexit
from pathlib import Path
def cli():
    parser = ArgumentParser()
    parser.add_argument("--ip", default="127.0.0.1", help="The ip of the OSC server")
    parser.add_argument("--port", type=int, default=57120, help="The port the OSC server is listening on")
    args = parser.parse_args()
    dir_path = os.path.dirname(os.path.realpath(__file__))
    vid_process = subprocess.Popen(["python", "-m", "astral_body.main", "--ip", str(args.ip), "--port", str(args.port)])
    sclang_process = subprocess.Popen(["sclang", Path(os.path.join(dir_path, "../../../supercollider/main.scd")).resolve()])
    def kill_subprocesses():
        vid_process.terminate()
        sclang_process.terminate()
    while True:
        user_input = input()
        if user_input.lower() == 'q':
            break
    atexit.register(kill_subprocesses)
