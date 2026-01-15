; +--------------------------------------------------------------------------+
; |  file: game.asm                                                          |
; |  code for game screen (part of the game "Capture"                        |
; |                                                                          |
; |  author: Stephen Phoenix                                                 |
; |  target: Commodore 64 (6502)                                             |
; |  assembler: 64tass cross assembler                                       |
; +--------------------------------------------------------------------------+

;-----------------------------------------------------------------------------
Print_Msg       .macro msg, msg_stay=0 
;-----------------------------------------------------------------------------
                jsr Clear_Msg_Line
                #Textout_Center msg_row, \msg, 1, 0, 4
                .if \msg_stay == 0
                jsr Clear_Msg_Line
                .fi
                .endm
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
Get_Sprite_X    .macro sprite_index
;-----------------------------------------------------------------------------
                ldx \sprite_index
                lda SPR0_X, x
                sta sprite_org_x
                txa
                asl
                tax
                lda SPR_XMSB, x
                beq +
                lda #$01
                jmp ++
+               lda #$00
+               sta sprite_org_x + 1
                .endm
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
Init_Game       .block
;-----------------------------------------------------------------------------
                lda #$00
                sta quit_flag

                ; setup sprite pointers
                lda #(piece_sprite / 64)  ; sprite pointers for piece
                sta SPR0_PTR
                sta SPR1_PTR
                sta SPR2_PTR
                sta SPR3_PTR
                sta SPR4_PTR
                sta SPR5_PTR
                lda #(crsr_sprite / 64)   ; sprite pointer for cursor
                sta SPR6_PTR

                ; sprite expand for cursor
                lda #%01000000        
                sta SPR_EXPANDX
                sta SPR_EXPANDY

                ; set multicolor for sprites
                lda #%01111111          ; set multicolor sprite mode
                sta SPR_MULTICOLOR    
                lda #piece_mc1          ; set multicolor1
                sta SPR_MC1
                lda #piece_mc2          ; set multicolor2
                sta SPR_MC2

                ; cursor
                lda #$00
                sta crsr_on
                lda #$01
                sta CRSRCOLOR

                ; delay for joystick repeat
                lda #$14
                sta input_delay

                jsr Draw_Game_BG
return          rts
                .bend
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
Deinit_Game     .block
;-----------------------------------------------------------------------------
                lda #%00000000          ; enable sprites
                sta SPR_ENABLE
                lda #$00
                sta crsr_on
                rts
                .bend
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
Draw_Game_BG    .block
;-----------------------------------------------------------------------------
                ; transfer screen data to screen
                lda #<game_scr
                sta addr1
                lda #>game_scr
                sta addr1 + 1
                jsr Display_Screen      

                ; score bar title
                lda #16
                sta left_score_plyr
                lda player_count
                cmp #01
                bne player
cpu             lda #03
                sta right_score_plyr
                jmp color
player          lda #16
                sta right_score_plyr

color           lda #01
                sta left_score_plyr + $d400
                sta right_score_plyr + $d400
                rts
                .bend
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
New_Game        .block
;-----------------------------------------------------------------------------
                ; game status
                lda #$00                ; 0=left; 1=right
                sta current_round
                sta who_play_first       
                sta current_side        
                sta left_score
                sta right_score
                lda #$ff
                sta winner

                ; round 1 message
                jsr Playsnd_Message
                jsr Print_Round

                jsr Reset_Position
                rts
                .bend
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
Next_Round      .block
;-----------------------------------------------------------------------------
                lda #%00000000          ; hide all sprites
                sta SPR_ENABLE

                inc current_round
                lda who_play_first
                sta current_side
                eor #$01
                sta who_play_first
                lda #$ff
                sta winner

                ; round message
                jsr Playsnd_Message
                jsr Print_Round

                jsr Reset_Position
                jsr Next_Turn
                rts
                .bend
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
Print_Round     .block
;-----------------------------------------------------------------------------
                clc
                lda current_round
                adc #49 
                sta round_msg_number

                #Print_Msg round_msg, 1
                #Sleep 60
                rts
                .bend
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
Reset_Position  .block
;-----------------------------------------------------------------------------
                ; piece positions
                lda #$00
                sta left_piece          ; store column numbers of ..
                sta left_piece + 1      ; the pieces in rows
                sta left_piece + 2      ; each row can have only one piece
                lda #$07
                sta right_piece  
                sta right_piece + 1   
                sta right_piece + 2   

                ; piece colors
                lda #left_color         ; set piece color for left side 
                sta SPR0_COLOR
                sta SPR1_COLOR
                sta SPR2_COLOR
                lda #right_color         ; set piece color for right side
                sta SPR3_COLOR
                sta SPR4_COLOR
                sta SPR5_COLOR

                ; cursor 
                lda #$00
                sta crsr_row
                sta crsr_column
                lda #left_color 
                sta SPR6_COLOR 

                lda #%01111111          ; enable sprites
                sta SPR_ENABLE
                lda #$01
                sta crsr_on

                jsr Update_Pieces
                jsr Update_Crsr
                rts
                .bend
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
Game_Loop       .block
;-----------------------------------------------------------------------------
                lda timer
                beq Game_Loop

                jsr Check_Win
                jsr Game_Input
                lda quit_flag
                beq +
                jsr Deinit_Game
                rts

+               jsr Game_Draw

                lda winner
                bmi +
                
                lda current_round       ; end of round
                cmp #rounds - 1         ; check if game is over
                beq matchover
                jsr Next_Round          ; if not then begin next round
                jmp +
                
matchover       jsr Gameover            ; gameover
                jsr Deinit_Game
                rts

+               lda #$00                ; reset timer
                sta timer
                jmp Game_Loop
                .bend
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
Game_Input      .block
;-----------------------------------------------------------------------------
                ; check key for aborting game
                jsr GETIN
                cmp #$00
                beq jumper1
                cmp #81                 ; q key
                beq askquit

jumper1         jmp move

askquit         #Ask 7, msg_quit, 24, msg_yes, msg_no, 1, 14, 7 
                bne move
                lda #$01
                sta quit_flag
                rts

move            lda player_count        ; if it is one-player game ..
                cmp #$01                ; and right's move then let cpu moves
                bne playermove
                lda current_side
                beq playermove

cpumove         lda ai_level 
                beq ai0
                cmp #$01
                beq ai1

ai2             jsr Ai_Normal 
                jmp update

ai0             jsr Ai_Random
                jmp update

ai1             jsr Ai_Easy

update          jsr Update_Crsr
                #Sleep 40
                jsr Move_Piece
                rts

playermove      jsr Read_Joy
                lda fire
                bne onfire
                lda dy
                beq checkdx
                bpl ondown

onup            lda crsr_row
                beq wraptop
                dec crsr_row
                jsr Update_Crsr
                jsr Update_Pieces
                rts 

wraptop         lda #$02
                sta crsr_row
                jsr Update_Crsr
                jsr Update_Pieces
                rts

ondown          lda crsr_row
                cmp #$02
                bcs wrapbottom
                inc crsr_row
                jsr Update_Crsr
                jsr Update_Pieces
                rts 

wrapbottom      lda #$00
                sta crsr_row
                jsr Update_Crsr
                jsr Update_Pieces
                rts

checkdx         lda dx
                beq return
                bpl onright

onleft          lda crsr_column
                beq wrapright            
                dec crsr_column
                jsr Update_Crsr
                rts

wrapright       lda #$07
                sta crsr_column
                jsr Update_Crsr
                rts

onright         lda crsr_column
                cmp #$07
                bcs wrapleft          
                inc crsr_column
                jsr Update_Crsr
                rts

wrapleft        lda #$00
                sta crsr_column
                jsr Update_Crsr
                rts

onfire          jsr Move_Piece

return          rts
                .bend
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
Move_Piece      .block
;-----------------------------------------------------------------------------
                lda square_flag
                beq move
                jsr Playsnd_Error
                rts

move            jsr Playsnd_Move
                ldy crsr_row
                lda current_side
                bne right

left            lda crsr_column
                sta left_piece, y
                jsr Update_Pieces
                jsr Next_Turn
                rts

right           lda crsr_column
                sta right_piece, y
                jsr Update_Pieces
                jsr Next_Turn
                rts
                .bend
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
Get_Square_Info .block
;-----------------------------------------------------------------------------
                ldy crsr_row            
                lda left_piece, y
                cmp crsr_column          
                beq nonempty            ; cannot move to non-empty square
                lda right_piece, y
                cmp crsr_column
                beq nonempty            ; cannot move to non-empty square
                jmp +

nonempty        lda #$01
                sta square_flag
                rts

+               lda current_side
                bne right

left            lda crsr_column         ; if crsr column > opponent column ..
                cmp right_piece, y      ; then move is not possible
                bcs cannotmove

leftok          jmp canmove

cannotmove      lda #$02
                sta square_flag
                rts

canmove         lda #$00
                sta square_flag
                rts

right           lda crsr_column         ; if crsr column < opponent column ..
                cmp left_piece, y       ; then move is not possible
                bcc cannotmove

rightok         jmp canmove 
                .bend
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
Update_Crsr     .block
;-----------------------------------------------------------------------------
                lda #$00
                sta crsr_counter        ; clear cursor animation counter
                sta crsr_flag

                ; update cursor position
+               lda #$06
                sta sprite_index

                ldy crsr_row            ; set crsr sprite y-pos
                lda crsr_rows_pos, y
                sta sprite_y

                lda crsr_column         
                cmp #$ff                
                bne +                   
                lda current_side        ; if crsr column = $ff then ..
                bne right               ; set crsr column at the piece ..
left            lda left_piece, y       ; in the same row
                jmp +
right           lda right_piece, y
+               sta crsr_column

                ldx crsr_column         ; set crsr sprite x-pos
                txa
                asl
                tax
                lda crsr_columns_pos, x ; get x-pos (lsb) of the column
                sta sprite_x            ; save x-pos
                inx
                lda crsr_columns_pos, x ; get x-pos (msb) of the column
                sta sprite_x + 1        ; save x-pos

                #Push_axy
                jsr Move_Sprite
                #Pull_yxa

                ; update cursor sprite
                jsr Get_Square_Info
                lda square_flag
                beq canmove
                cmp #$01
                beq nonempty
                jmp cannotmove

canmove         lda #(crsr_sprite / 64)   ; sprite pointer for cursor
                sta SPR6_PTR
                rts
nonempty        lda #(crsr_rev_sprite / 64)
                sta SPR6_PTR
                rts
cannotmove      lda #(crsr_no_sprite / 64)
                sta SPR6_PTR 
                rts
                .bend
;=============================================================================


;=============================================================================
Update_Pieces   .block
;=============================================================================
                lda #(piece_sprite / 64)  ; reset sprite pointers
                sta SPR0_PTR
                sta SPR1_PTR
                sta SPR2_PTR
                sta SPR3_PTR
                sta SPR4_PTR
                sta SPR5_PTR

                lda current_side        ; store sprite number in temp1
                bne right
                lda crsr_row
                sta temp1
                jmp +
right           lda crsr_row
                clc
                adc #$03
                sta temp1 

                ; update piece sprite positions
+               ldy #$00                ; start with piece #0 
nextpiece       sty sprite_index
                ldx left_piece, y       ; get piece column
                txa                     ; column_pos table index = ..
                asl                     ; piece index * 2
                tax

                lda columns_pos, x      ; get x-pos (lsb) of the column 
                sta sprite_x            ; save x-pos 
                inx 
                lda columns_pos, x      ; get x-pos (msb) of the column 
                sta sprite_x + 1        ; save x-pos 

                lda rows_pos, y         ; get y-pos of the row
+               sta sprite_y            ; save y-pos 

                #Push_axy
                jsr Move_Sprite
                #Pull_yxa

                iny                     ; increment piece #
                cpy #$06                ; repeat until piece # > 5
                bne nextpiece
                rts
                .bend
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
Next_Turn       .block
;-----------------------------------------------------------------------------
                ; next side
                lda #$01
                eor current_side
                sta current_side

                ; update cursor position and color
                ; place cursor on the first row that player can move ..
                ; his piece forward
                ldy #$00
selectrow       sec
                lda right_piece, y       
                sbc left_piece, y
                cmp #$01
                beq +
                jmp acceptrow
+               iny
                cpy #$03
                bcc selectrow

                ; no row that the piece can move forward ..
                ; so select the top row
                ldy #$00            

acceptrow       sty crsr_row            ; store the row
                lda current_side
                bne right

left            lda left_piece, y       ; crsr column = left piece column
                sta crsr_column
                lda #left_color
                jmp color

right           lda right_piece, y      ; crsr column = right piece column
                sta crsr_column
                lda #right_color

color           sta SPR6_COLOR          ; cursor color

                jsr Update_Crsr
                jsr Update_Pieces
                .bend
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
Game_Draw       .block
;-----------------------------------------------------------------------------
                .bend
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
Check_Win       .block
;-----------------------------------------------------------------------------
                lda winner
                bmi checkleft           ; if winner < 0 then do check
                rts

                ; check if left player wins
checkleft       ldx #$00
-               lda left_piece, x
                cmp #$06
                bne checkright
                inx
                cpx #$03
                bcc -

                ; left player wins
                lda #$00
                sta winner
                jsr Left_Win
                rts

                ; check if right player wins
checkright      ldx #$00
-               lda right_piece, x
                cmp #$01
                bne nowinner
                inx
                cpx #$03
                bcc -

                ; right player wins
                lda #$01
                sta winner
                jsr Right_Win

nowinner        rts
                .bend
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
Left_Win        .block
;-----------------------------------------------------------------------------
                lda #%00111111          ; hide cursor sprite
                sta SPR_ENABLE
                lda #$00
                sta crsr_on

                lda #left_color
                sta SPR3_COLOR
                sta SPR4_COLOR
                sta SPR5_COLOR

                lda #$01
                sta CRSRCOLOR

                jsr Playsnd_Roundover
                jsr Clear_Msg_Line
                inc left_score
                jsr Update_Scorebar
                rts
                .bend
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
Right_Win       .block
;-----------------------------------------------------------------------------
                lda #%00111111          ; hide cursor sprite
                sta SPR_ENABLE
                lda #$00
                sta crsr_on

                lda #right_color
                sta SPR0_COLOR
                sta SPR1_COLOR
                sta SPR2_COLOR

                lda #$01
                sta CRSRCOLOR

                jsr Playsnd_Roundover
                jsr Clear_Msg_Line
                inc right_score
                jsr Update_Scorebar
                rts
                .bend
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
Gameover        .block
;-----------------------------------------------------------------------------
                lda #%00000000          ; hide all sprites
                sta SPR_ENABLE
                lda #$00
                sta crsr_on

                jsr Playsnd_Message

                lda #$01
                sta CRSRCOLOR

                lda left_score
                cmp #$02
                beq left
                lda right_score
                cmp #$02
                beq right

                #Print_Msg game_tie_msg, 1 
                jmp wait

left            #Print_Msg left_win_msg, 1
                jmp wait

right           #Print_Msg right_win_msg, 1

wait            jsr Read_Joy
                lda fire
                beq wait
                rts
                .bend
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
Clear_Msg_Line  .block
;-----------------------------------------------------------------------------
                ldx #$00
                lda #$20
loop            sta SCRMEM + msg_row * 40, x
                inx
                cpx #40
                bne loop
                rts
                .bend
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
Update_Scorebar .block
;-----------------------------------------------------------------------------
                lda winner
                bne right

                lda #left_color
                sta temp1
                lda left_score
                cmp #$01
                bne +

                lda #<left_score_chr1   ; left's first score
                sta addr1
                lda #>left_score_chr1
                sta addr1 + 1
                lda #<left_score_col1
                sta addr2
                lda #>left_score_col1
                sta addr2 + 1
                jmp drawbar

+               lda #<left_score_chr2   ; left's second score
                sta addr1
                lda #>left_score_chr2
                sta addr1 + 1
                lda #<left_score_col2
                sta addr2
                lda #>left_score_col2
                sta addr2 + 1
                jmp drawbar

right           lda #right_color
                sta temp1
                lda right_score
                cmp #$01
                bne +

                lda #<right_score_chr1   ; right's first score
                sta addr1
                lda #>right_score_chr1
                sta addr1 + 1
                lda #<right_score_col1
                sta addr2
                lda #>right_score_col1
                sta addr2 + 1
                jmp drawbar

+               lda #<right_score_chr2   ; right's second score
                sta addr1
                lda #>right_score_chr2
                sta addr1 + 1
                lda #<right_score_col2
                sta addr2
                lda #>right_score_col2
                sta addr2 + 1

drawbar         lda #$00
                sta flag
              
                ldx #17                 ; blink times (use ord number)
-               lda flag
                eor #$01
                sta flag
                ldy #$00
-               lda flag
                beq erase
                lda #$a0
                jmp writechar
erase           lda #$20
writechar       sta (addr1), y
                lda temp1               ; bar color
                sta (addr2), y

                tya
                clc
                adc #40
                tay
                cpy #160
                bne -

                #Sleep score_bar_delay
                dex
                bne --
                rts

                .bend
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
Slide_Sprite    .block
;-----------------------------------------------------------------------------
                lda sprite_x
                sta temp1
                lda sprite_x + 1
                sta temp2

                .comment
                #get_sprite_x sprite_index
                sec
                lda sprite_org_x
                sbc temp1
                sta calc1
                lda sprite_org_x + 1
                sbc temp2
                sta calc2
                .endc

done            rts
                .bend
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
Move_Sprite     .block
;-----------------------------------------------------------------------------
                ldx sprite_index
                txa               ; sprite pos addr. increment = index * 2
                asl               ; so we take index and shift left ..
                tax               ; the bits and transfer result to xr
                lda sprite_y
                sta SPR0_Y, x     ; set y-pos
                lda sprite_x
                sta SPR0_X, x     ; set x-pos
                lda sprite_x + 1  ; 
                bne xmsbon
                
xmsboff         lda #%11111110 
                ldx sprite_index
                sec
-               dex
                bmi clearxmsb
                rol
                jmp -

clearxmsb       and SPR_XMSB
                sta SPR_XMSB
                rts
  
xmsbon          lda #%00000001
                ldx sprite_index  
-               dex
                bmi setxmsb
                asl
                jmp -

setxmsb         ora SPR_XMSB
                sta SPR_XMSB
                rts
                .bend
;-----------------------------------------------------------------------------


