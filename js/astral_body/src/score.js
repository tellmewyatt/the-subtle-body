import { socket } from './socket'
const scorePages = import.meta.glob('./score/*.svg', { query: "?url", import: 'default'});
function initialSetup() {
  for (const importPage of Object.values(scorePages)) {
    importPage();
  }

  scorePages[Object.keys(scorePages).find(k => k.includes("title-page"))]().then(url => {
    document.getElementById("app").innerHTML = 
      `<img id="score" src="${url}" style="flex grow: 1"/>`
  });
}
function seekPatch(patchChar) {
  socket.emit("patch_change", patchChar);
  const page = Object.keys(scorePages).find(k => k.includes("_"+patchChar));
  scorePages[page]().then(url => {
    document.getElementById("score").src = url
  });
}
function incrementPatch(scoreOrder, currentIndex) {
  const index = currentIndex + 1;
  const patchChar = scoreOrder[index];
  socket.emit("patch_change", patchChar);
  return  index;
}
export function addScoreKeyListeners() {
  initialSetup();
  const scoreOrder = "0abcdefghij";
  let currentIndex = 0
  document.addEventListener('keydown', e => {
    if(e.key === "PageDown")  
      currentIndex = incrementPatch(scoreOrder, currentIndex);
    else if(e.key === "Escape")
      socket.emit("patch_stop", 1);
    else if(scoreOrder.includes(e.key))
      seekPatch(e.key);
  });

}
