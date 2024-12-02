YEAR=2024
DAY=2
APP=RedNosedReports.jl
SESSION=~/.aoc-session

all: run

run: input.txt
	./$(APP) input.txt

test:
	./$(APP)

clean:
	rm -rf input.txt

input.txt:
	@test -s $(SESSION) || { echo "Advent of Code session file not found ($(SESSION))."; exit 1; }
	curl --cookie "session=$$(cat $(SESSION))" "https://adventofcode.com/$(YEAR)/day/$(DAY)/input" -o $@

.PHONY: all run test clean
