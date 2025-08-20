# The Astral Body
This is the git repository for my piece "The Astral Body". Below you will find instructions on how to install and run it.
## Installation Instructions
1. [Install git from here](https://git-scm.com/downloads).
2. [Install SuperCollider from here](https://supercollider.github.io/).
3. [Install Python from here](https://www.python.org/downloads/). 
4. In your terminal, run `git clone https://github.com/tellmewyatt/the-subtle-body.git`. This will create a new folder with the name `the-subtle-body`. 
5. We need to create a python virtual environment that will contain all the dependencies for the project. To do this, run `cd the-subtle-body` to enter the project folder. Then run `python3 -m "venv" env` to create the virtual environemnt. Then run `source env/bin/activate`. If you are using windows, run `env\Scripts\activate.bat`. See [here for details](https://docs.python.org/3/library/venv.html#how-venvs-work).
6. Installing the reuqirements. Change directory to python/astral_body by running `cd python/astral_body`. Run `pip install -e .` to install the requirements. This should add a command `astral_body` to your path.
7. Download the AI model by running `astral_body --fetch-model`.

## Playing the piece
1. Every time you run a new terminal to play this piece, you will need to run `source env/bin/activate` or `env\Scripts\activate.bat` as listed above before doing anything else.
2. Run the command `astral_body`. You should see text printed to the terminal for a few seconds. Then you should see two windows pop open - one for video and one blank window.
3. Click on the blank window so that it can collect key input.
