YEAR=2015
DAY=5
APP=InternElves.lisp
SESSION=~/.aoc-session

all: run

run: input.txt
	./$(APP)

clean:
	rm -f input.txt input-moves.txt

input.txt:
	@test -s $(SESSION) || { echo "Advent of Code session file not found ($(SESSION))."; exit 1; }
	curl --cookie "session=$$(cat $(SESSION))" "https://adventofcode.com/$(YEAR)/day/$(DAY)/input" -o $@

.PHONY: all run clean
