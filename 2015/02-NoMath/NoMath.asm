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
	sta mult1
	lda .dim2
	sta mult2
	lda #0
	sta mult1+1
	sta mult2+1
	jsr mul_word
	; copy lower 16-bit word to result
	lda mult1+2
	sta .result
	lda mult1+3
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
	; clear results
	lda #0
	ldx #5
.zero_next
	sta count,x
	dex
	bpl .zero_next
	; update text for "part 2"
	lda #"2"
	sta res_msg+5
	; part 2
	jsr calc_ribbon
	jsr hex_string
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Part 2
;
; Calculate total square of feet of ribbon needed by elves.
; Uses the same gift dimension data as part 1.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
calc_ribbon
	; call ribbon_length for each gift and store the sum of each in result
	+sum_fn ribbon_length, total, count, gift_data, num_gifts, 3, result
	rts

; Calculate ribbon length for a single gift.
; Ribbon length is equal to the perimeter of the smallest face + ribbon for
; the bow (volume of gift).
; Store result in total.
ribbon_length:
	jsr init_gift
	; bow length = volume of gift
	+calc_area dim, dim+1, slack	; slack = dim1 x dim2
	lda slack			; slack *= dim3
	sta mult1
	lda slack+1
	sta mult1+1
	lda dim+2
	sta mult2
	lda #0
	sta mult2+1
	jsr mul_word
	lda mult1+2			; store result back in slack
	sta slack
	lda mult1+3
	sta slack+1
	; find max side
	lda dim
	cmp dim+1			; dim0 >= dim1?
	bcc .cmp_d1_d2			; if not, try dim1 and dim2
	cmp dim+2			; dim0 >= dim2?
	bcc .d2_max			; if not, dim2 is max
	lda dim+1			; dim0 is max so use dim1 and dim2
	sta area2
	lda dim+2
	sta area3
	jmp .find_length
.cmp_d1_d2
	lda dim+1
	cmp dim+2			; dim1 >= dim2?
	bcc .d2_max			; if not, dim2 is max
	lda dim				; dim1 is max so use dim0 and dim2
	sta area2
	lda dim+2
	sta area3
	jmp .find_length
.d2_max
	lda dim				; dim2 is max so use dim0 and dim1
	sta area2
	lda dim+1
	sta area3
.find_length
	; multiply area 2 by 2
	asl area2
	rol area2+1
	; multiply area 3 by 2
	asl area3
	rol area3+1
	; sum total length (area2 + area3 + slack)
	+sum_words area2, 3, total
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
slack   !word 0			; slack (part 1) and bow (part 2)
total   !word 0			; result for one gift

; Multiply two 16-bit words in mult1 and mult2 using add-and-shift.
; The 32-bit result will overwrite mult1 and mult2.
; http://forum.6502.org/viewtopic.php?p=2846#p2846
mul_word
	; move multiplicand to scratchpad
	lda mult2
	sta scratch
	lda mult2+1
	sta scratch+1
	lda #0
	sta mult2
	sta mult2+1
	ldy #$10		; shift count
.shift
	; shift 32-bits
	asl mult2
	rol mult2+1
	rol mult1
	rol mult1+1
	bcc .next
	; add multiplier to result
	clc
	lda scratch
	adc mult2
	sta mult2
	lda scratch+1
	adc mult2+1
	sta mult2+1
	; if carry set, inc low byte of high word
	lda 0
	adc mult1
	sta mult1
.next	; are we done?
	dey
	bne .shift
	rts

mult1	!word 0
mult2	!word 0
scratch	!word 0

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
