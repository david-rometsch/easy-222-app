import { puzzles } from "cubing/puzzles";
import { rotate } from "./rotate.js";
import { experimentalSolve2x2x2 } from "cubing/search";
import { KPattern } from "cubing/kpuzzle";

import { permute, orient, solvedCubeState, fixPairity, cubeStateToK} from './scramble.js';
import { scrambleTypes } from './scramble-definition.js';


//
//
let scrambleType = 'pll';
// let axis = 'redOrange';
//
let orbit1 = scrambleTypes[scrambleType].orbit1;
// let orbit2 = scrambleTypes[scrambleType].orbit2;
let ollOrbit = scrambleTypes[scrambleType].ollOrbit;
//
// let scrambledOrbit1 = permute(orbit1);
// // let scrambledOrbit2 = Object.fromEntries(orbit2.map(v => [v, v]));
// let bothOrbits = { ...scrambledOrbit1, ...scrambledOrbit2 };
//
//
export async function test(scrambleType) {
 
  let myCubeState = structuredClone(solvedCubeState);
  
  
  myCubeState = rotate(myCubeState, 'x');
  
  // console.log(JSON.stringify(myCubeState));

  // permute(myCubeState, orbit1);
  // orient(myCubeState, ollOrbit);
  // fixPairity(myCubeState, scrambleTypes[scrambleType].balancePiece);
  var KCubeState = cubeStateToK(myCubeState);
  // console.log(`k cube state: ${JSON.stringify(KCubeState)}`);

  const cube2x2 = await puzzles["2x2x2"].kpuzzle();
  const scrState = new KPattern(cube2x2, KCubeState);
  const solution = await experimentalSolve2x2x2(scrState);
  const scramble = solution.invert();
  return scramble;
}
if (process.argv[1].endsWith("test.js")) {
  // test(scrambleType).then((s) => console.log(s.toString()));
  const yMove = cube2x2.algToTransformation("y");
  const rotated = defaultPattern.applyTransformation(yMove);
  console.log(JSON.stringify(rotated.patternData));
}

