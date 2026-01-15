; +--------------------------------------------------------------------------+
; |  File: main.asm  (part of the game "Capture")                            |
; |                                                                          |
; |  Author: Subhisara Srimaharaja                                           |
; |  Target: Commodore 64 (MOS 6502)                                         |
; |  Assembler: 64tass cross assembler                                       |
; +--------------------------------------------------------------------------+

;-----------------------------------------------------------------------------
Start           .block
;-----------------------------------------------------------------------------
                jsr Set_Interrupt
                jsr Clear_Sid
                jsr Init_Randomizer

                lda #$00
                sta fire_autorepeat

                ; menu screen
loop            jsr Init_Menu

                jsr Menu_Loop           ; loop until user make selection

                ; menu selection handling
                lda crsr_row
                beq oneplayer           ; 0 = one player
                cmp #$01
                beq twoplayers          ; 1 = two players
                cmp #$02
                beq instruction
                jsr CLRSCR
                jmp quit                ; 3 = exit

instruction     jsr Show_Rules          ; show rules of the game
                jmp loop

oneplayer       lda #$01 
                sta player_count        ; player_count = 1
                jsr Init_Menu_Ai        ; show cpu level selection screen
                jsr Menu_Ai_Loop
                jmp gamestart

twoplayers      lda #$02
                sta player_count        ; player_count = 2

                ; game screen
gamestart       jsr Init_Game 

                jsr New_Game
                jsr Game_Loop
                jmp loop

quit            lda #$0e                ; restore colors to default
                sta CRSRCOLOR
                sta BORDER
                lda #$06
                sta BKGND
                jsr Reset_Interrupt     ; restore default interrupt
                rts                     ; exit to c64 basic
                .bend
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
Set_Interrupt   .block
;-----------------------------------------------------------------------------
                lda #$00                ; reset timer flag
                sta timer

                lda CINV                ; save default interrupt pointer
                sta def_int
                lda CINV + 1
                sta def_int + 1

                sei                     ; disable interrupt
                lda #<Game_Interrupt    ; set new interrupt pointer
                sta CINV
                lda #>Game_Interrupt
                sta CINV + 1
                cli                     ; enable interrupt
                rts
                .bend
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
Game_Interrupt  .block
;-----------------------------------------------------------------------------
                ; limit frame rate to 60 frame per second:
                ;   the main loop resets timer to 0
                ;   and while the main loop is waiting for it to become 1 
                ;   the interrupt will set the flag to 1 if it is 0
                ;   then main loop goes on with its stuff 
                ;   and set timer to 0 again.
                ; since the interrupt occurs 60 times in a second
                ; the main loop can limit fps via timer flag communication
                lda timer               
                beq +                   
                jmp (def_int)


+               inc timer 
                lda crsr_on             ; cursor is on only in game screen
                bne chkanimate          ; so continue if it is on
                jmp (def_int)           ; else jump to ROM routines instead


chkanimate      lda piece_counter       ; jump to animate if piece animation .. 
                beq animate             ; counter reaches zero ..
                dec piece_counter       ; else decrement the counter ..
                jmp chkblink            ; and skip to cursor blink checking

animate         inc piece_frame         ; increment piece's sprite frame
                lda piece_frame
                cmp #$04                ; if frame is in range then ..
                bcc setsprdata          ; set sprite data
                lda #$00                ; else reset frame to zero
                sta piece_frame

setsprdata      lda crsr_row            ; To get sprite number of selected .. 
                ldy current_side        ; piece we have to know current side ..
                beq +                   ; take current row .. 
                clc                     ; then add 3 for right side
                adc #$03

                ; update sprite data pointer of selected piece
+               tax                       ; store sprite number in xr
                lda #(piece_sprite / 64)  ; sprite pointers for piece
                clc
                adc piece_frame           ; add offset to current frame
                sta SPR0_PTR, x
                lda #$05                  ; next animation in next 5 cycles
                sta piece_counter

chkblink        lda crsr_counter          ; toggle cursor visibility when ..
                beq blinkcrsr             ; cursor counter reaches zero
                dec crsr_counter          ; else jump to ROM routines
                jmp (def_int)

blinkcrsr       lda crsr_flag             ; toggle cursor sprite on/off
                eor #$01                  
                sta crsr_flag
                beq off
                lda #%01111111            ; hide cursor sprite
                sta SPR_ENABLE
                jmp +
off             lda #%10111111            ; show cursor sprite
                sta SPR_ENABLE

+               lda #$14                  ; reset cursor counter
                sta crsr_counter

                jmp (def_int)
                .bend
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
Reset_Interrupt .block
;-----------------------------------------------------------------------------
                sei
                lda def_int
                sta CINV
                lda def_int + 1
                sta CINV + 1
                cli
                rts
                .bend
;-----------------------------------------------------------------------------

