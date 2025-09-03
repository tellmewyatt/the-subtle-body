NODE_ENV=production node server.js & 
SC_FILE='../../supercollider/main.scd'

sclang $SC_FILE ||
/Applications/SuperCollider.app/Contents/MacOS/sclang $SC_FILE ||
/Applications/SuperCollider/SuperCollider.app/Contents/MacOS/sclang $SC_FILE ||
echo "SuperCollider binary not found! I checked some common locations for it for mac, but its not there.\n
You need to add it to your path"
  && kill $!
