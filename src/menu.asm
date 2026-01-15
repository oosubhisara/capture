; +--------------------------------------------------------------------------+
; |  file: main.asm                                                          |
; |                                                                          |
; |  author: Stephen Phoenix                                                 |
; |  target: Commodore 64 (6502)                                             |
; |  assembler: 64tass cross assembler                                       |
; +--------------------------------------------------------------------------+

menucount         = #4
menu0pos          = $0575
menu1pos          = menu0pos + 80 
menu2pos          = menu1pos + 80
menu3pos          = menu2pos + 80
menu0col          = menu0pos + $d400
menu1col          = menu0col + 80
menu2col          = menu1col + 80
menu3col          = menu2col + 80
level_count       = 3

;-----------------------------------------------------------------------------
Init_Menu       .block
;-----------------------------------------------------------------------------
                ; initialize 
                lda #$00
                sta BORDER           
                sta BKGND
                sta prev_dx
                sta prev_dy
                sta dx
                sta dy
                sta crsr_row
                sta crsr_on

                lda #$14
                sta input_delay

                ; transfer screen data to screen
                lda #<menu_scr
                sta addr1
                lda #>menu_scr
                sta addr1 + 1
                jsr Display_Screen      

                jsr Draw_Selection      ; draw hidden selection markers
                jsr Menu_Draw           

                rts
                .bend
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
Draw_Selection  .block
;-----------------------------------------------------------------------------
                lda #$00                ; hide markers by set their colors .. 
                sta menu0col            ; to background color
                sta menu1col
                sta menu2col
                sta menu3col

                lda #$51                ; these markers stay hidden ..
                sta menu0pos            ; in background color
                sta menu1pos
                sta menu2pos
                sta menu3pos
                rts
                .bend
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
Menu_Loop       .block
;-----------------------------------------------------------------------------
                lda timer
                beq Menu_Loop
                jsr Menu_Input
                lda fire
                bne +
                jsr Menu_Draw
                lda #$00
                sta timer
                jmp Menu_Loop

+               rts
                .bend
;-----------------------------------------------------------------------------
          

;-----------------------------------------------------------------------------
Menu_Input      .block
;-----------------------------------------------------------------------------
                jsr Read_Joy

+               lda dy                  ; check joy2 y direction
                beq return
                bpl down            

                lda crsr_row            ; press up
                beq return
                dec crsr_row             
                jsr Playsnd_Move
                rts

down            lda crsr_row            ; press down
                cmp menucount-1
                beq return
                inc crsr_row  
                jsr Playsnd_Move

return          rts
                .bend
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
Menu_Draw       .block
;-----------------------------------------------------------------------------
                lda #$00                ; hide markers by set their colors .. 
                sta menu0col            ; to background color
                sta menu1col
                sta menu2col
                sta menu3col
                lda #$05                ; set green color for visible marker
                ldx crsr_row
                bne m1
                sta menu0col            ; draw selection marker at item 0
                rts         
m1              cpx #$01
                bne m2
                sta menu1col            ; draw selection marker at item 1
                rts         
m2              cpx #$02
                bne m3
                sta menu2col            ; draw selection marker at item 2
                rts            
m3              sta menu3col            ; draw selection marker at item 3
                rts            
                .bend
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
Init_Menu_Ai    .block
;-----------------------------------------------------------------------------
                ; initialize 
                lda #$00
                sta BORDER           
                sta BKGND
                sta prev_dx
                sta prev_dy
                sta dx
                sta dy
                sta crsr_row
                sta crsr_on

                lda #$14
                sta input_delay

                jsr CLRSCR
                jsr Menu_Ai_Draw           

                rts
                .bend
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
Menu_Ai_Loop    .block
;-----------------------------------------------------------------------------
                lda timer
                beq Menu_Ai_Loop
                jsr Menu_Ai_Input
                lda fire
                bne onfire
                jsr Menu_Ai_Draw
                lda #$00
                sta timer
                jmp Menu_Ai_Loop

onfire          lda crsr_row
                sta ai_level
                rts
                .bend
;-----------------------------------------------------------------------------
          

;-----------------------------------------------------------------------------
Menu_Ai_Input     .block
;-----------------------------------------------------------------------------
                jsr Read_Joy

                lda dy                  ; check joy2 y direction
                beq return
                bpl down            

                lda crsr_row            ; press up
                beq return
                dec crsr_row             
                jsr Playsnd_Move
                rts

down            lda crsr_row            ; press down
                cmp #level_count - 1
                beq return
                inc crsr_row  
                jsr Playsnd_Move

return          rts
                .bend
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
Menu_Ai_Draw    .block
;-----------------------------------------------------------------------------
color1          = 15
color2          = 7

                lda #$01
                sta CRSRCOLOR
                #Textout_Center 7, msg_ai_level

                lda crsr_row
                cmp #$00
                beq rvs0
                #Textout_Center 11, msg_ai_veryeasy, color1, 0
                jmp +
rvs0            #Textout_Center 11, msg_ai_veryeasy, color2, 1

+               lda crsr_row
                cmp #$01
                beq rvs1
                #Textout_Center 13, msg_ai_easy, color1, 0
                jmp +
rvs1            #Textout_Center 13, msg_ai_easy, color2, 1

+               lda crsr_row 
                cmp #$02
                beq rvs2
                #Textout_Center 15, msg_ai_normal, color1, 0
                jmp +
rvs2            #Textout_Center 15, msg_ai_normal, color2, 1

+               rts            
                .bend
;-----------------------------------------------------------------------------

