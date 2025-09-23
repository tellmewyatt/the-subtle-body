import { socket } from './socket'
const scorePages = import.meta.glob('./score/*.svg', { query: "?raw", import: 'default'});
function getPlayer() {
  const urlParams = new URLSearchParams(window.location.search);
  return parseInt(urlParams.get('player'));
}
function initialSetup() {
  for (const importPage of Object.values(scorePages)) {
    importPage();
  }

  scorePages[Object.keys(scorePages).find(k => k.includes("title-page"))]().then(content=> {
    document.getElementById("app").innerHTML = content
  });
}
function seekPatch(scoreOrder, patchChar, player) {
  socket.emit("patch_change", patchChar);
  const page = Object.keys(scorePages).find(path => {
    let filename = path.split("/").pop()
    if(!filename.includes("score"))
      return
    filename = filename.replace(".svg","");
    return filename.split("_")[player+1].includes(patchChar)
  })
  if(page)
    scorePages[page]().then(content => {
      document.getElementById("app").innerHTML = content
      const circle = document.querySelector(`circle[patch="${player}${patchChar}"]`);
      circle.style.fill = "red";
    });
  return scoreOrder.indexOf(patchChar)
}
function resetToTitlePage() {
  const page = Object.keys(scorePages).find(k => k.includes("title-page"));
  socket.emit("patch_stop", 1);
  scorePages[page]().then(content => {
    document.getElementById("app").innerHTML = content
  });
  return -1;
}
function incrementPatch(scoreOrder, currentIndex, player) {
  const index = currentIndex + 1;
  if(index < scoreOrder.length) {
    const patchChar = scoreOrder[index];
    seekPatch(scoreOrder, patchChar, player);
    return  index;
  }
  else
    return resetToTitlePage();

}
export function addScoreKeyListeners(doubleCueInterval=3000) {
  initialSetup();
  const scoreOrder = "0abcdefghi";
  const player = getPlayer();
  let currentIndex = 0
  let canCue = true
  document.addEventListener('keydown', e => {
    if((e.key === "PageDown" || e.key === ' ' || e.key === 'Spacebar') && canCue) {
      currentIndex = incrementPatch(scoreOrder, currentIndex, player);
      canCue = false;
      setTimeout(() => { canCue = true }, doubleCueInterval);
    }
    else if(e.key === "Escape")
      socket.emit("patch_stop", 1);
    else if(scoreOrder.includes(e.key))
      currentIndex = seekPatch(scoreOrder, e.key, player);
  });

}
