const rotation = {
  x: {
    0: { p: 4, o: 2 },
    1: { p: 0, o: 1 },
    2: { p: 3, o: 2 },
    3: { p: 5, o: 1 },
    4: { p: 7, o: 1 },
    5: { p: 6, o: 2 },
    6: { p: 2, o: 1 },
    7: { p: 1, o: 2 },
  },
  y: {
    0: { p: 1, o: 0 },
    1: { p: 2, o: 0 },
    2: { p: 3, o: 0 },
    3: { p: 0, o: 0 },
    4: { p: 7, o: 0 },
    5: { p: 4, o: 0 },
    6: { p: 5, o: 0 },
    7: { p: 6, o: 0 },
  },
  z: {
    0: { p: 3, o: 1 },
    1: { p: 2, o: 2 },
    2: { p: 6, o: 1 },
    3: { p: 5, o: 2 },
    4: { p: 0, o: 2 },
    5: { p: 4, o: 1 },
    6: { p: 7, o: 2 },
    7: { p: 1, o: 1 },
  }
}

// {"CORNERS":{"pieces":[1,2,3,0,7,4,5,6],"orientation":[0,0,0,0,0,0,0,0]}}   y rotatin data 
// {"CORNERS":{"pieces":[3,2,6,5,0,4,7,1],"orientation":[1,2,1,2,2,1,2,1]}}   z rotation data
// var KCubeState = cubeStateToK(cubeState);
// KCubeState = {
//   CORNERS: {
//     pieces: [4, 0, 3, 5, 7, 6, 2, 1],
//     orientation: [2, 1, 2, 1, 1, 2, 1, 2],
//   }
// }


// my function to rotate before scrambling
export function rotate(cubeState, direction) {
  let myRotation = rotation[direction];
  const myCubeState = structuredClone(cubeState);
  const rotatedCubeState = Object.fromEntries(
    Object.entries(myCubeState).map(([place, data]) => {
      return [place, {    //NOTE: fix for multiple rotation bugs. 
        p: myCubeState[myRotation[place].p].p,
        o: (myCubeState[myRotation[place].p].o + myRotation[place].o) % 3
      }];
    })
  );
  return rotatedCubeState;
}


export function rotateRand(cubeState) {
  let rotations = Math.floor(Math.random() * 4);
  for (let i = 0; i < rotations; i++) {
    cubeState = rotate(cubeState, 'x');
  }

  rotations = [0, 1, 3][Math.floor(Math.random() * 3)];
  for (let i = 0; i < rotations; i++) {
    cubeState = rotate(cubeState, 'z');
  }

  rotations = Math.floor(Math.random() * 4);
  for (let i = 0; i < rotations; i++) {
    cubeState = rotate(cubeState, 'y');
  }

  return cubeState;
}


// rotate using library 
export function rotateScramble(cube2x2, scrState, direction) {
  const xMove = cube2x2.algToTransformation(direction);
  const rotated = scrState.applyTransformation(xMove);
  return rotated;
}


export function rotateScrambleRand(cube2x2, scrState) {
  let rotations = Math.floor(Math.random() * 4);
  for (let i = 0; i < rotations; i++) {
    scrState = rotateScramble(cube2x2, scrState, 'x');
  }

  rotations = [0, 1][Math.floor(Math.random() * 2)];
  for (let i = 0; i < rotations; i++) {
    scrState = rotateScramble(cube2x2, scrState, 'z');
  }

  rotations = Math.floor(Math.random() * 4);
  for (let i = 0; i < rotations; i++) {
    scrState = rotateScramble(cube2x2, scrState, 'y');
  }

  return scrState;
}


// generate rotations
import { puzzles } from "cubing/puzzles"
const cube2x2 = await puzzles["2x2x2"].kpuzzle();
const defaultPattern = cube2x2.defaultPattern();
const yMove = cube2x2.algToTransformation("z");
const rotated = defaultPattern.applyTransformation(yMove);
console.log(JSON.stringify(rotated.patternData));
