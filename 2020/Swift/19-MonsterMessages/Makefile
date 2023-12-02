YEAR=2020
DAY=19
APP=MonsterMessages.swift
INPUT=../../input/19-input.txt
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
