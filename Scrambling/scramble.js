import { puzzles } from "cubing/puzzles"
import { experimentalSolve2x2x2 } from "cubing/search";
import { KPattern } from "cubing/kpuzzle";


const orbit1 = [0, 1, 2, 3, 5];
const orbit2 = [4, 6, 7];
const ollOrbit = [0, 1, 2, 3, 5];
const balancePiece = 0;

const solvedPlaces = Array.from({ length: 8 }, (_, i) => i);
const solvedOris = Array(8).fill(0);


export function permute(arr) {
  let myArr = [...arr];

  for (let i = myArr.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [myArr[i], myArr[j]] = [myArr[j], myArr[i]];
  }

  let dict = Object.fromEntries(myArr.map((v, i) => [v, arr[i]]))
  return dict;
}


export function orient(arr) {
  let myArr = [...arr];

  for (let i = 0; i < myArr.length; i++) {
    myArr[i] = Math.floor(Math.random() * 2);
  }

  let dict = Object.fromEntries(myArr.map((v, i) => [arr[i], v]))
  return dict;
}


export function dictToState(solvedState, dict) {
  for (const [pos, piece] of Object.entries(dict)) {
    solvedState[pos] = piece;
  }
  return solvedState;
}



function fixPairity(balancePiece, oris) {
  let counter = 0;
  for (let i = 0; i < oris.length; i++) {
    if (i !== balancePiece) counter += oris[i];
  }

  oris[balancePiece] = (3 - counter % 3) % 3;
}

export async function scramble() {

  let pieces = dictToState(solvedPlaces, { ...permute(orbit1), ...permute(orbit2) });
  let oris = dictToState(solvedOris, orient(ollOrbit));

  fixPairity(balancePiece, oris);

  var pll = {
    CORNERS: {
      pieces: pieces,
      orientation: oris,
    }
  }

  const cube2x2 = await puzzles["2x2x2"].kpuzzle();
  const pattern = new KPattern(cube2x2, pll);
  const solution = await experimentalSolve2x2x2(pattern);
  const scramble = solution.invert();
  return scramble;
}


if (process.argv[1].endsWith("scramble.js")) {
  scramble().then((s) => console.log(s.toString()));
}
