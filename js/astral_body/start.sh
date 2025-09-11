SC_FILE='../../supercollider/main.scd'
NODE_ENV=production node server.js &
NODE_PID=$!
sleep 1
open "http://localhost:3000?player=$1" &
OPEN_PID=$!
pw-jack sclang $SC_FILE $1 ||
/Applications/SuperCollider.app/Contents/MacOS/sclang $SC_FILE $1 ||
/Applications/SuperCollider/SuperCollider.app/Contents/MacOS/sclang $SC_FILE $1 ||
echo "SuperCollider binary not found! I checked some common locations for it for mac, but its not there.\n
You need to add it to your path"
SUPERCOLLIDER_PID=$!
wait
KILL $NODE_PID $OPEN_PD $SUPERCOLLIDER_PID
