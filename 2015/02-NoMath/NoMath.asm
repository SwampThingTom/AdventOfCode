; I Was Told There Would Be No Math
; https://adventofcode.com/2015/day/2

; Boot loader
!source "loader.asm"
+start_at $1000

; C-64 BASIC ROM subroutines
print_word=$bdcd	; Print 16-bit integer (A=msb, X=lsb)
print_str=$ab1e		; Print string (Y=#>string, A=#<string)

; PETSCII (yes, really) characters
petscii_cr=13		; Same as ascii (shrug)

; Calculate the sum of the result of calling .fn for all gifts.
; Parameters
; 	.fn		Function that operates on (next_gift).
; 	.fn_result	Location of function result.
;	.index		Location of current gift index.
;	.gift_data	Location of start of gift data.
;	.num_gifts	Location of number of gifts.
;	.data_size	Number of bytes of data for each gift. (0...255)
;	.total		Pointer to final sum (32-bit).
; Memory Locations
;	next_gift	Zero-page pointer to next gift data.
; Result is stored in .total.
!macro sum_fn .fn, .fn_result, .index, .gift_data, .num_gifts, .data_size, .total {
	; store address of first row of dimensions in next_data
	lda #<.gift_data
	sta next_gift
	lda #>.gift_data
	sta next_gift+1
.next
	; calculate result and add to total
	jsr .fn
	+add_32 .fn_result, .total
	; increment index
	clc
	lda .index
	adc #1
	sta .index
	lda .index+1
	adc #0
	sta .index+1
	; are we done?
	cmp .num_gifts+1
	bcc .continue
	lda .index
	cmp .num_gifts
	beq .done
.continue
	; get address of next row of data
	clc
	lda next_gift
	adc #.data_size
	sta next_gift
	bcc .next
	inc next_gift+1
	jmp .next
.done
}

; Calculate the area of a rect with sides stored in .dim1 and .dim2 (8-bit).
; Store 16-bit result in .result.
!macro calc_area .dim1, .dim2, .result {
	lda .dim1
	ldy .dim2
	jsr mul8
	sty .result
	sta .result+1
}

; Compare two 16-bit words and jump to .if_less_than if .word1 < .word2.
; Falls through if .word1 >= .word2.
!macro cmp_word .word1, .word2, .if_less_than {
	lda .word1+1
	cmp .word2+1
	bcc .if_less_than
	bne .done
	lda .word1
	cmp .word2
	bcc .if_less_than
.done
}

; Add two 16-bit words.
; Store 16-bit result in .result.
!macro add_word .word1, .word2, .result {
	clc
	lda .word1
	adc .word2
	sta .result
	lda .word1+1
	adc .word2+1
	sta .result+1
}

; Add 16-bit word to 32-bit word.
!macro add_32 .word16, .word32 {
	clc
	lda .word16
	adc .word32
	sta .word32
	lda .word16+1
	adc .word32+1
	sta .word32+1
	lda #0
	adc .word32+2
	sta .word32+2
	lda #0
	adc .word32+3
	sta .word32+3
}

; Sum .count 16-bit words.
; Store 16-bit result in .result
!macro sum_words .words, .count, .result {
	ldx #0
	stx .result
	stx .result+1
.next
	clc
	lda .words,x
	adc .result
	sta .result
	lda .words+1,x
	adc .result+1
	sta .result+1
	inx
	inx
	cpx #.count*2
	bne .next
}

; Print null-terminated text in .string.
!macro print .string {
	lda #<.string
	ldy #>.string
	jsr print_str
}

; Zeropage addresses
next_gift=$fb		; contains pointer to dimensions of next gift

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Solve both parts of today's puzzle and print results.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
entry
	; part 1
	jsr calc_wrap
	jsr hex_string		; convert result to hex
	+print res_msg
	rts

count	!word 0			; mumber of gifts processed so far
result	!32 0			; final result for each part
res_msg	!text "PART 1: 0X"
res_hex	!text "00000000", petscii_cr, 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Part 1
;
; Calculate total square feet of wrapping paper needed by elves.
; Each present's dimensions are stored in 3 bytes (one per dimension) 
; starting at gift_data. Count is in num_gifts.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
calc_wrap
	; call gift_area for each gift and store the sum of each in result
	+sum_fn gift_area, total, count, gift_data, num_gifts, 3, result
	rts

; Determine surface area of cube with dimensions in (next_data) + slack (area
; of smallest side).
; Store result in total.
gift_area
	jsr init_gift
	; calculate areas
	+calc_area dim, dim+1, area1
	+calc_area dim, dim+2, area2
	+calc_area dim+1, dim+2, area3
	; slack = min(area1, area2, area3)
	+cmp_word area1, area2, .cmp_a1_a3
	+cmp_word area2, area3, .slack_a2
	jmp .slack_a3
.cmp_a1_a3
	+cmp_word area1, area3, .slack_a1
	jmp .slack_a3
.slack_a1 ; a1 = min(a1, a2, a3)
	lda area1+1
	ldx area1
	jmp .set_slack
.slack_a2 ; a2 = min(a1, a2, a3)
	lda area2+1
	ldx area2
	jmp .set_slack
.slack_a3 ; a3 = min(a1, a2, a3)
	lda area3+1
	ldx area3
.set_slack
	sta slack+1
	stx slack
	; sum total area
	+sum_words area1, 3, total
	; multiply area x 2
	asl total
	rol total+1
	; add slack
	+add_word slack, total, total
	rts

; Copies the dimensions for the next gift and zeroes the total.
init_gift:
	; copy next dimensions (1 byte each)
	ldy #2
.copy_dim
	lda (next_gift),y
	sta dim,y
	dey
	bpl .copy_dim
	; clear intermediate values and total
	lda #0
	ldy #9
.zero_values
	sta area1,y
	dey
	bpl .zero_values
	rts

; data used when calculating per gift results
dim	!byte 0, 0, 0		; dimensions of one gift
area1	!word 0
area2	!word 0
area3	!word 0
slack   !word 0
total   !word 0			; result for one gift

; Multiply A * Y using add-and-shift.
; Return result in AY.
; https://wiki.nesdev.org/w/index.php/8-bit_Multiply
mul8
	sty factor
	ldy #0
	sty mul_res
	sty mul_res+1
	ldy #8		; shift count
.add
	lsr
	bcc .shift
	pha
	clc
	lda mul_res+1
	adc factor
	sta mul_res+1
	pla
.shift
	lsr mul_res+1
	ror mul_res
	dey
	bne .add
	ldy mul_res
	lda mul_res+1
	rts

factor	!byte 0
mul_res	!word 0

; Convert 32-bit integer in result to a hex string.
; Place result in res_hex.
hex_string
	lda result
	jsr hex_byte
	sta res_hex+6
	stx res_hex+7

	lda result+1
	jsr hex_byte
	sta res_hex+4
	stx res_hex+5

	lda result+2
	jsr hex_byte
	sta res_hex+2
	stx res_hex+3

	lda result+3
	jsr hex_byte
	sta res_hex
	stx res_hex+1
	rts

; Convert byte in A to hex string.
; Return result in AX.
hex_byte
	pha
	and #$0f
	tay
	lda hex,y
	tax		; lsb in X
	pla
	lsr
	lsr
	lsr
	lsr
	tay
	lda hex,y	; msb in A
	rts

hex	!text "0123456789ABCDEF"

; Data
!source "input.asm"
