; +--------------------------------------------------------------------------+
; |  file: rules.asm                                                         |
; |  display rules of the game (part of the game "Capture")                  |
; |                                                                          |
; |  author: Stephen Phoenix                                                 |
; |  target: Commodore 64 (6502)                                             |
; |  assembler: 64tass cross assembler                                       |
; +--------------------------------------------------------------------------+


;-----------------------------------------------------------------------------
Show_Rules      .block
;-----------------------------------------------------------------------------
delay           = 30
                jsr CLRSCR
                jsr Playsnd_Message

                lda #01
                sta CRSRCOLOR
                #Textout_Center 5, rule_title

                lda #10
                sta CRSRCOLOR
                #Textout 0, 8, rule1
                #Textout 0, 9, rule2
                #Sleep delay
                
                lda #13
                sta CRSRCOLOR
                #Textout 0, 11, rule3
                #Textout 0, 12, rule4
                #Sleep delay

                lda #07
                sta CRSRCOLOR
                #Textout 0, 14, rule5
                #Sleep delay

                lda #03
                sta CRSRCOLOR
                #Textout 0, 16, rule6
                #Textout 0, 17, rule7
                #Sleep delay

wait            jsr Read_Joy
                lda fire
                beq wait
                rts
                .bend
;-----------------------------------------------------------------------------

