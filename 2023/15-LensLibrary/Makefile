YEAR=2023
DAY=15
APP=LensLibrary
SRC=$(APP).rs
SESSION=~/.aoc-session

all: run

run: input.txt $(APP)
	./$(APP)

test:
	rustc $(SRC) --test
	./$(APP)
	rm ./$(APP)

clean:
	rm -rf input.txt $(APP)

input.txt:
	@test -s $(SESSION) || { echo "Advent of Code session file not found ($(SESSION))."; exit 1; }
	curl --cookie "session=$$(cat $(SESSION))" "https://adventofcode.com/$(YEAR)/day/$(DAY)/input" -o $@

$(APP): $(SRC)
	rustc $(SRC)

.PHONY: all run test clean
