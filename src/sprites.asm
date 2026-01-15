; +--------------------------------------------------------------------------+
; |  file: sprite.asm                                                        |
; |  sprite data (part of the game "Capture")                                |
; |                                                                          |
; |  author: Stephen Phoenix                                                 |
; |  target: Commodore 64 (6502)                                             |
; |  assembler: 64tass cross assembler                                       |
; +--------------------------------------------------------------------------+

piece_sprite      .binary "../data/sprites/sprites.spr"
crsr_sprite       = piece_sprite + 4*64
crsr_rev_sprite   = crsr_sprite + 64
crsr_no_sprite    = crsr_rev_sprite + 64


