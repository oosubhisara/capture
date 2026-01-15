; +--------------------------------------------------------------------------+
; |  file: sound.asm                                                         |
; |  sound effect fundtions (Part of the game "Capture"                      |
; |                                                                          |
; |  author: Stephen Phoenix                                                 |
; |  target: Commodore 64 (6502)                                             |
; |  assembler: 64tass cross assembler                                       |
; +--------------------------------------------------------------------------+


;-----------------------------------------------------------------------------
Clear_Sid       .block
;-----------------------------------------------------------------------------
                ldx #$00
                lda #$00
-               sta SID, x              ; clear sid registers
                inx
                cpx #$19
                bne -
                rts
                .bend
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
Playsnd         .block
;-----------------------------------------------------------------------------
                ldy #$00
                lda (addr1), y
                sta temp1               ; store waveform in temp1
                iny
                lda (addr1), y          ; set attack / decay
                sta V1ATTDEC
                iny
                lda (addr1), y
                sta V1SUSREL            ; set sustain / release
                iny
                lda (addr1), y
                sta V1VOLUME            ; set volume

                iny
read            lda (addr1), y
                bmi done
                sta V1FREQ_LO
                iny
                lda (addr1), y
                sta V1FREQ_HI
                iny
                lda (addr1), y
                sta counter1

                lda temp1
                ora #$01
                sta V1CONTROL

wait            lda #$00
                sta timer
-               lda timer
                beq -
                dec counter1
                beq nextnote 
                jmp wait 
                
nextnote        lda temp1
                sta V1CONTROL

                iny
                jmp read

done            rts
                .bend
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
Playsnd_Move      .block
;-----------------------------------------------------------------------------
                lda #<snd_move
                sta addr1
                lda #>snd_move
                sta addr1 + 1
                jsr Playsnd
                rts
                .bend
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
Playsnd_Error   .block
;-----------------------------------------------------------------------------
                lda #<snd_error
                sta addr1
                lda #>snd_error
                sta addr1 + 1
                jsr Playsnd
                rts
                .bend
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
Playsnd_Roundover .block
;-----------------------------------------------------------------------------
                lda #<snd_roundover
                sta addr1
                lda #>snd_roundover
                sta addr1 + 1
                jsr Playsnd
                rts
                .bend
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
Playsnd_Message .block
;-----------------------------------------------------------------------------
                lda #<snd_message
                sta addr1
                lda #>snd_message
                sta addr1 + 1
                jsr Playsnd
                rts
                .bend
;-----------------------------------------------------------------------------

