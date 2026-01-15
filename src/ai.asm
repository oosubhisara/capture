; +--------------------------------------------------------------------------+
; |  File: ai.asm  (part of the game "Capture")                              |
; |                                                                          |
; |  Author: Subhisara Srimaharaja                                           |
; |  Target: Commodore 64 (6502)                                             |
; |  Assembler: 64tass cross assembler                                       |
; +--------------------------------------------------------------------------+


;-----------------------------------------------------------------------------
Ai_Random       .block
;-----------------------------------------------------------------------------
                lda #$03                ; randomly pick one of the rows
                sta temp1
pick            jsr Random 
                tay
                lda left_piece, y
                cmp #$06
                bne +
                beq pick
              
+               sty crsr_row

                ldx left_piece, y
loop            inx
                txa
                cmp right_piece, y
                bne chkrightedge  
                cpx #$07
                bne loop
                
                dex                     ; current square has own piece
                jmp done                ; move to square on the left

chkrightedge    cpx #$07
                beq done                ; reach last column, pick this square
                lda #100                ; else random 
                sta temp1
                jsr Random 
                cmp #50
                bcs done
                jmp loop

done            stx crsr_column
                rts
                .bend
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
Ai_Easy         .block
;-----------------------------------------------------------------------------
                lda #30
                sta ai_mistake
                jsr Ai_Think
                rts
                .bend
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
Ai_Normal       .block
;-----------------------------------------------------------------------------
                lda #$00
                sta ai_mistake
                jsr Ai_Think
                rts
                .bend
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
Ai_Think        .block
;-----------------------------------------------------------------------------
                ; clear memory
                lda #$00
                sta ai_best_row
                sta ai_best_column
                sta counter1
                sta counter2
                lda #$ff
                sta ai_best_score

                ; scan for valid squares
                ldy counter1
loopr           lda left_piece, y
                sta counter2
                inc counter2
                ldx counter2

loopc           txa
                cmp right_piece, y
                beq nextcolumn
                
                sty ai_row              ; save row
                sta ai_new_column       ; save new column
                lda right_piece, y      ; save old column
                sta ai_old_column
                lda ai_new_column       ; change piece column
                sta right_piece, y

                jsr Evaluate_Pos
                
                lda ai_best_score
                cmp #$ff
                beq nomistake

                lda ai_score
                cmp ai_best_score       ; compare score with best score
                bcc restorepos

                lda ai_mistake
                beq nomistake

                lda #100
                sta temp1
                jsr Random
                cmp ai_mistake
                bcs nomistake
                jmp restorepos

nomistake       lda ai_score
                cmp ai_best_score
                bne updatebestscore     ; score > best score
                lda #100                ; score = best score
                sta temp1
                jsr Random
                cmp #50
                bcc restorepos

updatebestscore lda ai_score
                sta ai_best_score       ; save new best score
                lda ai_row
                sta ai_best_row         ; save new best row
                lda ai_new_column
                sta ai_best_column      ; save new best column

restorepos      lda ai_old_column
                ldy counter1
                sta right_piece, y

nextcolumn      inc counter2
                ldx counter2
                cpx #$08
                bcs nextrow
                jmp loopc 

nextrow         lda #$00
                sta counter2
                inc counter1
                ldy counter1
                cpy #03
                bcs break
                jmp loopr

                ; set cursor to best square
break           lda ai_best_row
                sta crsr_row
                lda ai_best_column
                sta crsr_column
                rts

                .bend
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
Evaluate_Pos    .block
;-----------------------------------------------------------------------------
                lda #$00
                sta ai_score
                sta ai_phase

                ldx #$00
countphase      lda right_piece, x
                sec
                sbc left_piece, x
                cmp #$01
                bne +
                inc ai_phase
+               inx
                cpx #$03
                bcc countphase

                lda ai_phase
                beq phase0
                cmp #$01
                beq phase1
                cmp #$02
                beq phase2jumper
                jmp phase3

phase2jumper    jmp phase2

phase0          lda #$00
                sta ai_score
                rts

phase1          lda #$0a
                sta ai_score
                lda #$ff
                sta ai_dist1
                ldx #$00
loop1           lda right_piece, x      ; measure distance between pieces
                sec
                sbc left_piece, x
                cmp #$01                ; skip to next1 if they are close .. 
                beq next1               ; to each other
                ldy ai_dist1
                bpl +
                sta ai_dist1            ; store first non-adjacent distance
                jmp next1
+               sta ai_dist2            ; store second non-adjacent distance
next1           inx                     ; if row < 3 then next row 
                cpx #$03
                bcc loop1

                lda ai_dist1            ; compare distances
                cmp ai_dist2            
                bne return1
                sec                     ; if distances are equal ..
                lda #$08                ; add points to score base on the ..
                sbc ai_dist1            ; distance (the smaller, the greater)
                sta temp1
                clc
                lda ai_score
                adc temp1
                sta ai_score
return1         rts

phase2          lda #$00
                sta ai_score
                rts

phase3          lda #$64
                sta ai_score
                rts
                .bend
;-----------------------------------------------------------------------------
