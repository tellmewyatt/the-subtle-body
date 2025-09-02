import { socket } from './socket'
const scorePages = import.meta.glob('./score/*.svg', { query: "?url", import: 'default'});
for (const importPage of Object.values(scorePages)) {
  console.log(importPage);
  importPage();
}
scorePages[Object.keys(scorePages).find(k => k.includes("title-page"))]().then(url => {
  document.getElementById("app").innerHTML = 
    `<img id="score" src="${url}" style="flex grow: 1"/>`
});
function changePatchAlphabetical(patchChar) {
  if ("abcdefghij".includes(patchChar)) {
    socket.emit("patch_change", patchChar);
    const page = Object.keys(scorePages).find(k => k.includes("_"+patchChar));
    scorePages[page]().then(url => {
      document.getElementById("score").src = url
    });
  }
}
document.addEventListener('keydown', e => {
  changePatchAlphabetical(e.key)
});
