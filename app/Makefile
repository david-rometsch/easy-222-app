scripts/scrambles.txt: 
	cd scramble && node scramble.js > ../scripts/scrambles.txt

assets/scrambles/two_by_two/222scrambles.json: scripts/scrambles.txt
	python3 scripts/convert_scrambles.py scripts/scrambles.txt
	mv scripts/scrambles_converted.json assets/scrambles/two_by_two/222scrambles.json

.PHONY: all
all: assets/scrambles/two_by_two/222scrambles.json



