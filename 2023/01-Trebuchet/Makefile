YEAR=2023
DAY=1
APP=Trebuchet
SRC=$(APP).rs
SESSION=~/.aoc-session

all: run

run: input.txt $(APP)
	./$(APP)

clean:
	rm -rf input.txt $(APP)

test:
	rustc $(SRC) --test
	./$(APP)
	rm ./$(APP)

input.txt:
	@test -s $(SESSION) || { echo "Advent of Code session file not found ($(SESSION))."; exit 1; }
	curl --cookie "session=$$(cat $(SESSION))" "https://adventofcode.com/$(YEAR)/day/$(DAY)/input" -o $@

$(APP): $(SRC)
	rustc $(SRC)

.PHONY: all run clean test
