all: build/StockingStuffer

.PHONY: all

build:
	mkdir -p $@

build/StockingStuffer: StockingStuffer.c
	cc -o $@ -Wno-deprecated-declarations StockingStuffer.c

clean:
	rm -f build/*