import { experimentalSolve2x2x2 } from "cubing/search";
import { puzzles } from "cubing/puzzles"
import { KPattern } from "cubing/kpuzzle";
import { scrambleTypes } from "./scramble-definition.js";
import { rotate, rotateRand, rotateScrambleRand } from "./rotate.js";

let scrambleType = 'threeOriented';
let direction = 'z';


export let solvedCubeState = {
  0: { p: 0, o: 0 }, //UFR
  1: { p: 1, o: 0 }, //UBR
  2: { p: 2, o: 0 }, //UBL
  3: { p: 3, o: 0 }, //UFL
  4: { p: 4, o: 0 }, //DFR
  5: { p: 5, o: 0 }, //DFL
  6: { p: 6, o: 0 }, //DBL
  7: { p: 7, o: 0 }, //DBR 
}


export function permute(cubeState, orbit) {
  for (let i = orbit.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [cubeState[orbit[i]], cubeState[orbit[j]]] = [cubeState[orbit[j]], cubeState[orbit[i]]];
  }
}


export function orient(cubeState, orbit) {

  for (let i = 0; i < orbit.length; i++) {
    const j = Math.floor(Math.random() * 3);
    cubeState[orbit[i]].o = j;
  }
}


export function fixPairity(cubeState, ollOrbit, balancePiece) {
  if (ollOrbit.length === 0) return;
  let counter = 0;
  for (let i of Object.keys(cubeState)) {
    if (parseInt(i) !== balancePiece) {
      counter += cubeState[i].o;
    }
  }
  cubeState[balancePiece].o = (3 - counter % 3) % 3;
}


export function cubeStateToK(cubeState) {
  const pieces = [];
  const orientation = [];

  for (const [place, data] of Object.entries(cubeState)) {
    pieces[parseInt(place)] = data.p;
    orientation[parseInt(place)] = data.o;
  }
  return { CORNERS: { pieces: pieces, orientation: orientation } }
}


export async function scramble(scrambleType) {

  let scrambleDef = scrambleTypes[scrambleType];
  let cubeState = structuredClone(solvedCubeState);


  cubeState = rotateRand(cubeState);


  let orbit1 = scrambleDef.orbit1;
  let orbit2 = scrambleDef.orbit2;
  let ollOrbit = scrambleDef.ollOrbit;
  let balancePiece = scrambleDef.balancePiece;


  permute(cubeState, orbit1);
  permute(cubeState, orbit2);
  orient(cubeState, ollOrbit);
  fixPairity(cubeState, ollOrbit, balancePiece);

  // console.log(JSON.stringify(cubeState));

  var KCubeState = cubeStateToK(cubeState);

  // console.log(`kcubestate: ${JSON.stringify(KCubeState)}`);
  const cube2x2 = await puzzles["2x2x2"].kpuzzle();
  let scrState = new KPattern(cube2x2, KCubeState);
  // rotade randomley
  scrState = rotateScrambleRand(cube2x2, scrState);

  const solution = await experimentalSolve2x2x2(scrState);
  const scramble = solution.invert();
  return scramble;
}


if (process.argv[1].endsWith("scramble-222.js")) {
  (async () => {
    console.log("[")
    let scrLen = 1000;
    for (let i = 0; i < scrLen - 1; i++) {
      const s = await scramble(scrambleType);
      console.log(`"${s.toString()}",`);
    }
    const s = await scramble(scrambleType);
    console.log(`"${s.toString()}"`);
    console.log("]")
  })();
}
