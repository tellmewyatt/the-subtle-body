# The Astral Body
This is the git repository for my piece "The Astral Body". Below you will find instructions on how to install and run it.
## Technical Requirements
1. 3 Performers
2. 3 Laptops, each with stereo output (for a total of 6 stereo outputs).
3. 3 Webcams (If not attached to laptop already)
4. 3 Page turn pedals set to output spaces.
5. The software listed below.

NOTE: This piece has only been tested with Mac. Contact me at wyattcannon78@gmail.com if you need a different version.
## Perusal Score
A perusal score can be found [here](https://wyattcannon.com/pieces/astral-body/perusal.pdf). Note that in the actual performannce, the score is displayed in the browser and tied to the correct patches.
## Installation Instructions
1. [Install git from here](https://git-scm.com/downloads).
2. [Install SuperCollider from here](https://supercollider.github.io/).
3. [Install Node.js from here](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm).
4. In the terminal run `git clone https://github.com/tellmewyatt/the-subtle-body`.
5. Then, `cd the-subtle-body/js/astral_body`.
6. Finally, run `npm run setup && npm run start <part>`. <part> will be either 0, 1 or 2, depending on the part you will play in the piece. Each time you start the piece, just run `npm run start` from this directory. This should automatically start supercollider and open your browser to the correct page. If it doesn't, go to localhost:3000?player=<part> in your web browser, replacing part with 0, 1 or 2. This page will also prompt you asking for webcam permission. To quit the piece, go back to the terminal and hit CMD+C.
You can press the Escape key to stop the patches from playing. To test if you have sound, please press "d" in the browser window. You should see the score page change. With your body and hands in view of the camera, wave your hands around. You should hear output through the device you have selected. If you need to change the device, stop the program using CMD+C and select your device on your mac. Then restart the program.
