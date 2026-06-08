import re, json, sys

if len(sys.argv) < 2:
    print("Usage: python3 convert_scrambles.py <input_file>")
    sys.exit(1)

data = open(sys.argv[1]).read()
items = re.findall(r'[A-Za-z0-9 \']+(?=,|\n|\])', data)
scrambles = [i.strip() for i in items if i.strip()]

out = sys.argv[1].rsplit('.', 1)[0] + '_converted.json'
with open(out, 'w') as f:
    json.dump(scrambles, f)

print(f"Written to {out}")
