import subprocess
from pathlib import Path
import os

this_path = Path(os.path.dirname(os.path.abspath(__file__)))
python_path = this_path.joinpath("./.venv/bin/python")
# Create the environment and install the dependencies
subprocess.run(["python3.12", "-m", "venv", ".venv"])
subprocess.run([python_path, "-m", "pip", "install", this_path.joinpath("python/astral_body").resolve()])
subprocess.run([python_path, "-m", "astral_body.cli", "--fetch-model"])
