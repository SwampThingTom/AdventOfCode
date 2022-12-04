#!/usr/bin/env gst -q

" Probably a Fire Hazard
  https://adventofcode.com/2015/day/5
"

Object subclass: ChristmasLights [
	" A collection of christmas lights that can be on or off. "
	| lights |
	
	ChristmasLights class >> new [
        ^ super new init
    ]

	init [
		lights := ByteArray new: (1000 * 1000)
	]
	
	count [
		" Returns the count of lights that are turned on. "
		^ (lights select: [ :item | item = 1 ]) size
	]

	turnOn: point [
		" Turns on the light at point. "
		lights at: (self indexAtPoint: point) put: 1
	]

	turnOff: point [
		" Turns off the light at point. "
		lights at: (self indexAtPoint: point) put: 0
	]

	toggle: point [
		" Toggles the light at point. "
		((lights at: (self indexAtPoint: point)) = 1)
			ifTrue: [ self turnOff: point ]
			ifFalse: [ self turnOn: point ]
	]

	do: operation [
		" Performs the given operation on a range of lights. "
		(operation start x) to: (operation end x) do: [ :x |
			(operation start y) to: (operation end y) do: [ :y |
				self doCommand: (operation command) point: x@y
			]
		]
	]

	doCommand: command point: point [
		" Either toggle, turn on, or turn off the light at point. "
		(command = 'toggle') ifTrue: [ ^ self toggle: point ].
		(command = 'on') ifTrue: [ ^ self turnOn: point ].
		(command = 'off') ifTrue: [ ^ self turnOff: point ].
		self error: 'Invalid command'
	]

	indexAtPoint: point [
		^ ((point x) * 1000) + point y + 1
	]
]

ChristmasLights subclass: ChristmasLights2 [
	" A collection of christmas lights with adjustable brightness. "

	count [ 
		" The sum of the brightness for all lights. "
		| sum |
		sum := 0.
		lights do: [ :a | (a notNil) ifTrue: [ sum := sum + a ]].
		^ sum
	]

	turnOn: point [
		" Adds 1 to the brightness of the light at point. "
		| index current |
		index := (self indexAtPoint: point).
		current := self lightAt: index.
		lights at: index put: (current + 1)
	]

	turnOff: point [
		" Subtracts 1 from the brightness of the light at point. 
		  Will not go below a brightness of 0. "
		| index current |
		index := (self indexAtPoint: point).
		current := self lightAt: index.
		(current > 0) ifTrue: [ lights at: index put: (current - 1) ]
	]

	toggle: point [
		" Adds 2 to the brightness of the light at point. "
		| index current |
		index := (self indexAtPoint: point).
		current := self lightAt: index.
		lights at: index put: (current + 2)
	]

	lightAt: index [
		" Nil-coalesces array values. "
		| value |
		value := lights at: index.
		(value isNil) ifTrue: [ value := 0 ].
		^ value
	]
]

Object subclass: Operation [
	" An operation that can be performed on ChristmasLights. "
	| command start end |

	Operation class >> withCommand: command start: start end: end [
		^ self new initWithCommand: command start: start end: end
	]

	initWithCommand: myCommand start: myStart end: myEnd [
		command := myCommand.
		start := myStart.
		end := myEnd.
	]

	command [ ^ command ]

	start [ ^ start ]

	end [ ^ end ]

	printOn: stream [
		<category: 'printing'>
		super printOn: stream.
		stream nextPutAll: ' with command: '.
		command printOn: stream.
		stream nextPutAll: ' start: '.
		start printOn: stream.
		stream nextPutAll: ' end: '.
		end printOn: stream.
	]
]

Object subclass: OperationParser [

	OperationParser class >> parse: str [
		" Creates an Operation by parsing a string of the format:
		  '(command) startx,starty through endx,endy'.

		  Command can be one of 'toggle', 'turn on', or 'turn off'. "
		| tokens cmd start end |
		tokens := str tokenize: ' '.
		((tokens at: 1) = 'toggle')
			ifTrue: [
				cmd := 'toggle'.
				start := self parsePoint: (tokens at: 2).
				end := self parsePoint: (tokens at: 4)
			]
			ifFalse: [
				cmd := tokens at: 2.
				start := self parsePoint: (tokens at: 3).
				end := self parsePoint: (tokens at: 5)
			].
		^ Operation withCommand: cmd start: start end: end
	]

	OperationParser class >> parsePoint: pointStr [
		| tokens point |
		tokens := pointStr tokenize: ','.
		^ Point x: (tokens at: 1) asNumber y: (tokens at: 2) asNumber
	]
]

lights1 := ChristmasLights new.
lights2 := ChristmasLights2 new.

file := FileStream open: 'input.txt' mode: FileStream read.
file linesDo: [ :line |
	operation := OperationParser parse: line.
	lights1 do: operation.
	lights2 do: operation
].
file close.

'Part 1: ' display.
lights1 count displayNl

'Part 2: ' display.
lights2 count displayNl
