YEAR=2022
DAY=1
APP=ReportRepair.py
INPUT=../../input/01-input.txt
SESSION=~/.aoc-session

all: run

run: $(INPUT)
	./$(APP)

clean:
	rm -f $(INPUT)

$(INPUT):
	@test -s $(SESSION) || { echo "Advent of Code session file not found ($(SESSION))."; exit 1; }
	curl --cookie "session=$$(cat $(SESSION))" "https://adventofcode.com/$(YEAR)/day/$(DAY)/input" -o $@

.PHONY: all run clean
