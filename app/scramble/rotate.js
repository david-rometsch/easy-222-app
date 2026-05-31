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
  }
}

// var KCubeState = cubeStateToK(cubeState);
// KCubeState = {
//   CORNERS: {
//     pieces: [4, 0, 3, 5, 7, 6, 2, 1],
//     orientation: [2, 1, 2, 1, 1, 2, 1, 2],
//   }
// }


// my function to rotate before scrambling
export function rotate (cubeState, direction) {
  let myRotation = rotation[direction]; 
  console.log(myRotation);
  const myCubeState = structuredClone(cubeState);
  const rotatedCubeState = Object.fromEntries(
    Object.entries(myCubeState).map(([place, data]) => {
      console.log(place, data.o, myRotation[place].o);
      return [place, {
        p: myRotation[place].p,
        o: (data.o + myRotation[place].o) % 3
        }];
      })
  ); 
  console.log(JSON.stringify(rotatedCubeState));
  return rotatedCubeState;
}


// rotate using library 
export function rotateScramble (cube2x2, scrState) {
  const xMove = cube2x2.algToTransformation("x");
  const rotated = scrState.applyTransformation(xMove);
  // console.log(JSON.stringify(rotated.patternData));
  return rotated;
}
