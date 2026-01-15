; +--------------------------------------------------------------------------+
; | program: capture                                                         |
; | author: Subhisara Srimaharaja
; | target: Commodore 64 (6502)                                              |
; | assembler: 64tass cross assembler                                        |
; +--------------------------------------------------------------------------+

                  .include "c64.asm"
; ---------------------------------------------------------------------------/
                  *= $0801
                  .dsection Basic
                  .cerror * > $0810, "basic section too long!"
                  *= $0810
                  .dsection ML_Code
                  .cerror * > $2000, "mlcode section too long!"
                  *= $2000
                  .dsection Sprite_Data
                  .cerror * > $3000, "sprite section too long!"
                  *= $3000
                  .dsection Memory
; ---------------------------------------------------------------------------/
                  .section Basic
                  .word +, 10                     ; pointer, line number 
                  .null $9e, format("%d", Start)  ; will be sys 2064
+                 .word $00                       ; basic line end
                  .send Basic
; ////////////////////////////////////////////////////////////////////////////
                  .section ML_Code
                  .include "main.asm"
                  .include "menu.asm"
                  .include "game.asm"
                  .include "rules.asm"
                  .include "input.asm"
                  .include "sound.asm"
                  .include "ai.asm"
                  .include "utils.asm"
                  .send ML_Code
; ////////////////////////////////////////////////////////////////////////////
                  .section Memory
                  .include "memory.asm"   
                  .send Memory
; ////////////////////////////////////////////////////////////////////////////
                  .section Sprite_Data
                  .include "sprites.asm" 
                  .send Sprite_Data
; ////////////////////////////////////////////////////////////////////////////

