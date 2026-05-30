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


export function dictToPieces(dict) {
  let arr = Array.from({ length: 8 }, (_, i) => i);
  for (const [pos, piece] of Object.entries(dict)) {
    arr[pos] = piece;
  }
  return arr;
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


export function dictToOris(dict) {
  let arr = Array(8).fill(0);
  for (const [pos, ori] of Object.entries(dict)) {
    arr[pos] = ori;
  }
  return arr;
}


export async function scramble() {
  var pll = {
    CORNERS: {
      pieces: [...dictToPieces({ ...permute(orbit1),...permute(orbit2)})],
      orientation: [...dictToOris({ ...orient(ollOrbit) })],
    }
  }
  const cube2x2 = await puzzles["2x2x2"].kpuzzle();
  const pattern = new KPattern(cube2x2, pll);
  const solution = await experimentalSolve2x2x2(pattern);
  const scramble = solution.invert();
  return scramble;
}


if (process.argv[1].endsWith("scramble.js")) {
  main();
}
