YEAR=2022
DAY=4
APP=CampCleanup
SRC=$(APP).c
SESSION=~/.aoc-session

all: run

run: input.txt build/$(APP)
	build/$(APP)

clean:
	rm -rf build input.txt

input.txt:
	@test -s $(SESSION) || { echo "Advent of Code session file not found ($(SESSION))."; exit 1; }
	curl --cookie "session=$$(cat $(SESSION))" "https://adventofcode.com/$(YEAR)/day/$(DAY)/input" -o $@

build:
	mkdir -p $@

build/$(APP): build $(SRC)
	cc -o $@ -Wno-deprecated-declarations $(SRC)

.PHONY: all run clean
