; +--------------------------------------------------------------------------+
; |  file: memory.asm                                                        |
; |  define memory addresses   (part of the game "Capture")                  |
; |                                                                          |
; |  author: Stephen Phoenix                                                 |
; |  target: Commodore 64 (6502)                                             |
; |  assembler: 64tass cross assembler                                       |
; +--------------------------------------------------------------------------+

; constants
msg_row         = 7
score_bar_delay = 7
rounds          = 2
left_color      = 2
right_color     = 6
piece_mc1       = 0
piece_mc2       = 1

left_score_plyr = $0771
left_score_chr1 = $0631
left_score_chr2 =  left_score_chr1 - 4 * 40
left_score_col1 = left_score_chr1 + $d400
left_score_col2 =  left_score_col1 - 4 * 40
right_score_plyr= left_score_plyr + 37
right_score_chr1= left_score_chr1 + 37
right_score_chr2= left_score_chr2 + 37 
right_score_col1= left_score_col1 + 37
right_score_col2= left_score_col2 + 37 

; zero page memory
addr1           = $07 
addr2           = $09
mem_size        = $0b
temp1           = $0d
temp2           = $0e
flag            = $0f
sleep_counter   = $10
counter1        = $11
counter2        = $12
sprite_org_x    = $13
text_addr       = $3f                 ; address of text message (2 bytes)
def_int         = $41                 ; default interrupt addr. (2 bytes)
;left_piece      = $45                ; left piece columns (3 bytes)
;right_piece     = $48                ; right piece columns (3 bytes)
quit_flag       = $4b
selection       = $4c
prev_dx         = $b0
prev_dy         = $b1
prev_fire       = $b2
dx              = $b3
dy              = $b4
fire            = $b5
text_rvs        = $b6
sprite_index    = $f7
sprite_x        = $f8                 ; sprite x arguments (2 bytes)
sprite_y        = $fa
timer           = $fb                 ; timer  
input_delay     = $fc                 ; timer delay 
input_counter   = $fd
fire_counter    = $fe
fire_autorepeat = $ff

; precalculated piece positions (pixel) for all 24 board squares
rows_pos          .byte $87, $a7, $c7, $87, $a7, $c7
columns_pos       .byte $3c,$00, $5c,$00, $7c,$00, $9c,$00 
                  .byte $bc,$00, $dc,$00, $fc,$00, $1c,$01
crsr_rows_pos     .byte $82, $a2, $c2
crsr_columns_pos  .byte $38,$00, $58,$00, $78,$00, $98,00
                  .byte $b8,$00, $d8,$00, $f8,$00, $18,$01

; game data 
player_count    .byte $00               ; number of players
who_play_first  .byte $00
left_score      .byte $00
right_score     .byte $00
current_round   .byte $00
winner          .byte $00
left_piece      .byte $00, $00, $00
right_piece     .byte $00, $00, $00
crsr_row        .byte $00
crsr_column     .byte $00
current_side    .byte $00
square_flag     .byte $00
crsr_on         .byte $00          
crsr_flag       .byte $00
crsr_counter    .byte $00
piece_frame     .byte $00
piece_counter   .byte $00
ai_level        .byte $00
ai_phase        .byte $00
ai_score        .byte $00
ai_best_score   .byte $00
ai_dist1        .byte $00
ai_dist2        .byte $00
ai_row          .byte $00
ai_best_row     .byte $00
ai_old_column   .byte $00
ai_new_column   .byte $00
ai_best_column  .byte $00
ai_mistake      .byte $00

; text
round_msg         .text "round "
round_msg_number  .byte $00, $00
score_msg         .null "score!"
left_win_msg      .null "red wins!"
right_win_msg     .null "blue wins!"
game_tie_msg      .null "game ended in a tie!"
rule_title        .null "r u l e s"
rule1             .null "* players will take turns in moving one"
rule2             .null "  of their pieces."
rule3             .null "* pieces can only move within rows they"
rule4             .null "  occupied."
rule5             .null "* pieces cannot move over other pieces."
rule6             .null "* the player who cannot make a move in"
rule7             .null "  his turn loses."
msg_ai_level      .null "select difficulty"
msg_ai_veryeasy   .null " very easy "
msg_ai_easy       .null " easy      "
msg_ai_normal     .null " normal    "
msg_quit          .null "do you want to abort the game?"
msg_yes           .null " yes "
msg_no            .null " no "

;screens
menu_scr        .binary "../data/screens/menuscreen.bin"
game_scr        .binary "../data/screens/gamescreen.bin"

;sound
snd_move        .byte $10, $09, $00, $0f
                .byte $00, $40, $02
                .byte $ff, $ff, $ff
snd_message     .byte $10, $09, $00, $0f
                .byte $00, $20, $04
                .byte $00, $30, $04
                .byte $00, $40, $04
                .byte $00, $80, $04
                .byte $ff, $ff, $ff
snd_error       .byte $10, $09, $00, $0f
                .byte $00, $14, $08
                .byte $00, $0a, $08
                .byte $ff, $ff, $ff
snd_roundover   .byte $10, $04, $00, $0f
                .byte $00, $40, $0a
                .byte $00, $40, $0a
                .byte $00, $20, $0f
                .byte $ff, $ff, $ff
;-----------------------------------------------------------------------------

