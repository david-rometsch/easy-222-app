import { puzzles } from "cubing/puzzles"
import { experimentalSolve2x2x2 } from "cubing/search";
import { KPattern } from "cubing/kpuzzle";


const orbit1 = [0, 1, 2, 3, 5];
const orbit2 = [4, 6, 7];
const ollOrbit = [0, 1, 2, 3, 5]


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

  let counter = 0;
  for (let i = 0; i < myArr.length - 1; i++) {
    const j = Math.floor(Math.random() * 2);
    myArr[i] = j;
    counter += j;
  }
  myArr[arr.length - 1] = (3 - counter % 3) % 3;

  let dict = Object.fromEntries(myArr.map((v, i) => [arr[i], v]))
  return dict;
}


export function dictToState(solvedState, dict) {
  for (const [pos, piece] of Object.entries(dict)) {
    solvedState[pos] = piece;
  }
  return solvedState;
}


export async function scramble() {

  let solvedPlaces = Array.from({ length: 8 }, (_, i) => i);
  let solvedOris = Array(8).fill(0);

  let pieces = dictToState(solvedPlaces, { ...permute(orbit1), ...permute(orbit2) });
  let oris = dictToState(solvedOris, orient(ollOrbit));

  var pll = {
    CORNERS: {
      pieces: pieces,
      orientation: oris,
    }
  }
  // console.log(JSON.stringify(pll, null, 2));

  const cube2x2 = await puzzles["2x2x2"].kpuzzle();
  const pattern = new KPattern(cube2x2, pll);
  const solution = await experimentalSolve2x2x2(pattern);
  const scramble = solution.invert();
  return scramble;
}


if (process.argv[1].endsWith("scramble.js")) {
  scramble().then((s) => console.log(s.toString()));
}
