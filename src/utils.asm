; +--------------------------------------------------------------------------+
; |  file: utils.asm                                                         |
; |  Useful functions and macros                                             |
; |                                                                          |
; |  author: Stephen Phoenix                                                 |
; |  target: Commodore 64 (6502)                                             |
; |  assembler: 64tass cross assembler                                       |
; +--------------------------------------------------------------------------+


; push ac, xr, yr to the stack
; effect: ac, stack
;-----------------------------------------------------------------------------
Push_axy        .macro
;-----------------------------------------------------------------------------
                pha                     ; save ac, xr, yr
                txa
                pha                     
                tya
                pha                     
                .endm
;-----------------------------------------------------------------------------


; pull yr, xr, ac from the stack
; effect: ac, xr, yr, stack
;-----------------------------------------------------------------------------
Pull_yxa        .macro
;-----------------------------------------------------------------------------
                pla                     
                tay                     ; restore ac, xr, yr
                pla
                tax
                pla
                .endm
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
Wait_Raster     .macro
;-----------------------------------------------------------------------------
loop            lda #$fb                ; wait for vertical retrace ..
                cmp RASTER              ; until it reaches 251th raster line
                bne loop
                .endm
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
Clear_Line      .proc
;-----------------------------------------------------------------------------
                lda #<SCRMEM
                sta addr1
                lda #>SCRMEM
                sta addr1 + 1

seek            clc
                lda addr1
                adc #40
                sta addr1
                lda addr1 + 1
                adc #$00
                sta addr1 + 1
                dey
                bne seek

                ldy #$00
                lda #$20
loop            sta (addr1), y
                iny
                cpy #40
                bne loop
                rts
                .pend
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
Type            .macro delay
;-----------------------------------------------------------------------------
                sta addr1
                sty addr1 + 1
                ldy #$00
loop            lda (addr1), y
                cmp #$00
                beq done
                jsr CHROUT
                #Sleep \delay
                iny
                jmp loop

done              
                .endm
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
Textout         .macro x, y, msg, color=255, reverse=0, delay=0
;-----------------------------------------------------------------------------
                ldy #\x
                ldx #\y 
                clc
                jsr PLOT

                .if \color != 255
                lda #\color
                sta CRSRCOLOR
                .fi

                .if \reverse == 1
                lda #18
                jsr CHROUT
                .fi

                lda #<\msg
                ldy #>\msg
                clc
                .if \delay == 0
                jsr STROUT
                .else
                #Type \delay
                .fi

                .if \reverse == 1
                lda #146
                jsr CHROUT
                .fi
                .endm
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
Textout_Center  .macro y, msg, color=255, reverse=0, delay=0
;-----------------------------------------------------------------------------
x               .var (40 - size(\msg) + 1) / 2 
                ldy #x
                ldx #\y 
                clc
                jsr PLOT

                .if \color != 255
                lda #\color
                sta CRSRCOLOR
                .fi

                .if \reverse == 1
                lda #18
                jsr CHROUT
                .fi

                lda #<\msg
                ldy #>\msg
                clc
                .if \delay == 0
                jsr STROUT
                .else
                #Type \delay
                .fi

                .if \reverse == 1
                lda #146
                jsr CHROUT
                .fi
                .endm
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
Move_Mem        .proc
;-----------------------------------------------------------------------------
movedown        ldy #0
                ldx mem_size + 1
                beq md2
md1             lda (addr1),y ; move a page at a time
                sta (addr2),y
                iny
                bne md1
                inc addr1 + 1
                inc addr2 + 1
                dex
                bne md1
md2             ldx mem_size
                beq md4
md3             lda (addr1),y ; move the remaining bytes
                sta (addr2),y
                iny
                dex
                bne md3
md4             rts
                .pend
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
Display_Screen  .proc
;-----------------------------------------------------------------------------
                lda addr1
                sta temp1
                lda addr1 + 1
                sta temp2
                
                lda #$e8
                sta mem_size
                lda #$03
                sta mem_size + 1

                lda #<SCRMEM
                sta addr2
                lda #>SCRMEM
                sta addr2 + 1
                jsr Move_Mem

                clc
                lda temp1
                adc mem_size 
                sta addr1
                lda temp2
                adc mem_size + 1
                sta addr1 + 1

                lda #<COLORMEM
                sta addr2
                lda #>COLORMEM
                sta addr2 + 1
                jsr Move_Mem

                rts
                .pend
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
Sleep           .macro delay
;-----------------------------------------------------------------------------
                lda #\delay
                sta sleep_counter
                jsr Sleep_
                .endm
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
Sleep_          .proc
;-----------------------------------------------------------------------------
                lda #$00
                sta timer
loop            lda timer
                beq loop

                dec sleep_counter
                beq return
                lda #$00
                sta timer
                jmp loop

return          rts
                .pend
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
Init_Randomizer .proc
;-----------------------------------------------------------------------------
                lda #$ff
                sta $d40e               ; voice 3 frequency low byte
                sta $d40f               ; voice 3 frequency high byte
                lda #$80                ; noise waveform, gate bit off
                sta $d412               ; voice 3 control register
                rts
                .pend
;-----------------------------------------------------------------------------


; load random number from 0 to upper (temp1) into accumulator
; effect: accumulator, temp1
;-----------------------------------------------------------------------------
Random          .proc 
;-----------------------------------------------------------------------------
                lda $d41b
                sec
mod             sbc temp1
                bcs mod
                clc
                adc temp1
                rts
                .pend
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
Ask             .macro y, msg, y2, yes_text, no_text, msg_color, color1, color2
;-----------------------------------------------------------------------------
                ldy #\y
                jsr Clear_Line
                #Textout_Center \y, \msg, \msg_color, 0, 1

spaces          = 10
x1              = (40 - size(\yes_text) - size(\no_text) - spaces + 1) / 2 
x2              = x1 + size(\yes_text) + spaces 
                
                lda #$01
                sta selection
                sta timer
loop            lda timer
                beq loop

                jsr Read_Joy
                lda fire
                beq +
                jmp done

+               lda dx
                beq draw
                bpl right
left            lda selection
                beq draw
                dec selection
                jmp draw
right           lda selection
                cmp #$01
                beq draw
                inc selection

draw            lda selection
                beq rvs_yes
                #Textout x1, \y2, \yes_text, \color1, 0
                jmp +
rvs_yes         #Textout x1, \y2, \yes_text, \color2, 1
+               lda selection
                bne rvs_no
                #Textout x2, \y2, \no_text, \color1, 0
                jmp +
rvs_no          #Textout x2, \y2, \no_text, \color2, 1
+               lda #$00
                sta timer
                jmp loop

done            ldy #\y
                jsr Clear_Line
                ldy #\y2
                jsr Clear_Line
                lda selection
                .endm
;-----------------------------------------------------------------------------

