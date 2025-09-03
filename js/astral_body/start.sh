SC_FILE='../../supercollider/main.scd'
NODE_ENV=production node server.js &
NODE_PID=$!
sleep 1
open http://localhost:3000 &
OPEN_PID=$!
sclang $SC_FILE ||
/Applications/SuperCollider.app/Contents/MacOS/sclang $SC_FILE ||
/Applications/SuperCollider/SuperCollider.app/Contents/MacOS/sclang $SC_FILE ||
echo "SuperCollider binary not found! I checked some common locations for it for mac, but its not there.\n
You need to add it to your path"
SUPERCOLLIDER_PID=$!
wait
KILL $NODE_PID $OPEN_PD $SUPERCOLLIDER_PID
