; +--------------------------------------------------------------------------+
; |  File: input.asm  (part of the game "Capture")                           |
; |  Description: keyboard / joystick input                                  |
; |                                                                          |
; |  Author: Subhisara Srimaharaja                                           |
; |  Target: Commodore 64 (6502)                                             |
; |  Assembler: 64tass cross assembler                                       |
; +--------------------------------------------------------------------------+


;----------------------------------------------------------------------------- 
Read_Joy          .block
;----------------------------------------------------------------------------- 
                  lda JOY2
                  ldx #$00
                  ldy #$00

                  lsr                     ; check up / down
                  bcc joyup               ; bit 0 = up
                  lsr
                  bcc joydown             ; bit 1 = down
                  jmp checklr             ; not up or down then next axis 

joyup             dey                     ; up: decrement y-offset 
                  lsr                     ;     shift bit to the right
                  jmp checklr             ;     next axis

joydown           iny                     ; down: increment y-offset
                                          ;       next axis

checklr           lsr                     ; check left / right 
                  bcc joyleft             ; bit 3 = left
                  lsr
                  bcc joyright            ; bit 4 = right
                  jmp checkfire           ; not left / right : check joybutton

joyleft           dex                     ; left: decrement x-offset
                  lsr                     ;       shift bits to the right
                  jmp checkfire           ;       next, check joybutton
joyright          inx                     ; right: increment x-offset 
                  
checkfire         lsr                     ; check joybutton
                  bcc joyfire
                  lda #$00                ; joybutton was not pressed ..
                  sta fire                ; clear fire flag
                  jmp comparedir 

joyfire           lda #$01
                  sta fire
                  jmp comparedir   


comparedir        cpx prev_dx             ; prevent direction repeats ..
                  bne newdir              ; the pad must be released before ..
                  cpy prev_dy             ; pressing it again
                  bne newdir

                  lda input_counter
                  bne waitdir
                  jmp newdir

waitdir           ldx #$00                ; the direction repeats so return ..
                  stx dx                  ; x and y offset as no movement
                  ldy #$00
                  sty dy
                  dec input_counter
                  jmp comparefire

newdir            stx dx                  ; new direction: update dx, dy and ..
                  sty dy                  ; store last direction
                  stx prev_dx
                  sty prev_dy
                  lda input_delay
                  sta input_counter

comparefire       lda fire
                  cmp prev_fire 
                  bne acceptfire

                  lda fire_autorepeat
                  beq waitfire

                  lda fire_counter
                  bne waitfire
                  jmp acceptfire

waitfire          lda #$00
                  sta fire
                  rts

acceptfire        lda fire
                  sta prev_fire
                  rts
                  .bend
;----------------------------------------------------------------------------- 


