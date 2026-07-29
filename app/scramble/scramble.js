import { scramble } from "./scramble-222.js";

const scrambleType = "threeOriented";
const count = 1000;

(async () => {
  console.log("[");
  for (let i = 0; i < count - 1; i++) {
    const s = await scramble(scrambleType);
    console.log(`"${s.toString()}",`);
  }
  const s = await scramble(scrambleType);
  console.log(`"${s.toString()}"`);
  console.log("]");
})();
