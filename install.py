import subprocess
from pathlib import Path
import os


this_path = Path(os.path.dirname(os.path.abspath(__file__)))
python_path = this_path.joinpath("./.venv/bin/python")
# Create the environment and install the dependencies
subprocess.run(["python3.12", "-m", "venv", ".venv"])
subprocess.run([python_path, "-m", "pip", "install", this_path.joinpath("python/astral_body").resolve()])
subprocess.run([python_path, "-m", "astral_body.cli", "--fetch-model"])
homedir = os.environ.get('HOME')
def add_to_rc(rc=".zshrc"):
    alias_str = f'\nalias astral_body-start="{python_path} -m \'astral_body.cli\'"\n'
    rc_filepath = os.path.join(homedir, rc)
    content = ""
    try:
        with open(rc_filepath, "r") as file:
            content = file.read()
    except:
        pass
    with open(rc_filepath, "a") as file:
        if not alias_str in content:
            file.write(alias_str)
add_to_rc()
