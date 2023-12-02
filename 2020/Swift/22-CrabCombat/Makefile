YEAR=2020
DAY=22
APP=CrabCombat.swift
INPUT=../../input/22-input.txt
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
