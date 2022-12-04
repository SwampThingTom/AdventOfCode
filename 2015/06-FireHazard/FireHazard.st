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
	
	count [ ^ (lights select: [ :item | item = 1 ]) size ]

	turnOn: point [
		lights at: (self indexAtPoint: point) put: 1
	]

	turnOff: point [
		lights at: (self indexAtPoint: point) put: 0
	]

	toggle: point [
		((lights at: (self indexAtPoint: point)) = 1)
			ifTrue: [ self turnOff: point ]
			ifFalse: [ self turnOn: point ]
	]

	doCommand: command point: point [
		(command = 'toggle') ifTrue: [ ^ self toggle: point ].
		(command = 'on') ifTrue: [ ^ self turnOn: point ].
		(command = 'off') ifTrue: [ ^ self turnOff: point ].
		self error: 'Invalid command'
	]

	do: operation [
		(operation start x) to: (operation end x) do: [ :x |
			(operation start y) to: (operation end y) do: [ :y |
				self doCommand: (operation command) point: x@y
			]
		]
	]

	indexAtPoint: point [
		^ ((point x) * 1000) + point y + 1
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

lights := ChristmasLights new.

file := FileStream open: 'input.txt' mode: FileStream read.
file linesDo: [ :line |
	operation := OperationParser parse: line.
	lights do: operation	
].
file close.

'Part 1: ' display.
lights count displayNl
