import { permute, dictToPieces, orient, dictToOris} from './scramble.js';

console.log(dictToOris({...orient([0,1,2]),...orient([5,6,7])}));
// console.log({...orient([0,1,2]),...orient([5,6,7])});
