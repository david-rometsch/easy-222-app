import { randomScrambleForEvent } from "cubing/scramble";

export async function wcaScramble(event = "333") {
  const scramble = await randomScrambleForEvent(event);
  return scramble;
}

if (process.argv[1].endsWith("scramble-333.js")) {
  process.stderr.write = () => true;
  (async () => {
    console.log("[")
    let scrLen = 1000;
    for (let i = 0; i < scrLen - 1; i++) {
      const s = await wcaScramble("333");
      console.log(`"${s.toString()}",`);
    }
    const s = await wcaScramble("333");
    console.log(`"${s.toString()}"`);
    console.log("]")
  })();
}
