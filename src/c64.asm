; +--------------------------------------------------------------------------+
; |  file: c64.asm                                                           |
; |  define labels for ROM addresses and constants                           |
; |                                                                          |
; |  author: Stephen Phoenix                                                 |
; |  target: Commodore 64 (6502)                                             |
; |  assembler: 64tass cross assembler                                       |
; +--------------------------------------------------------------------------+

; ROM addresses
CRSRCOLOR         = $0286
CINV              = $0314
SCRMEM            = $0400
SPR0_PTR          = $07f8
SPR1_PTR          = $07f9
SPR2_PTR          = $07fa
SPR3_PTR          = $07fb
SPR4_PTR          = $07fc
SPR5_PTR          = $07fd
SPR6_PTR          = $07fe
SPR7_PTR          = $07ff
STROUT            = $ab1e
COLORMEM          = $d800
RASTER            = $d012
BKGND             = $d021
BORDER            = $d020
SID               = $d400
V1FREQ_LO         = $d400
V1FREQ_HI         = $d401
V1CONTROL         = $d404
V1ATTDEC          = $d405
V1SUSREL          = $d406
V1VOLUME          = $d418
JOY2              = $dc00
CLRSCR            = $e544
SETLFS            = $ffba
SETNAM            = $ffbd
CHROUT            = $ffd2
LOAD              = $ffd5
SPR0_X            = $d000
SPR0_Y            = $d001
SPR1_X            = $d002
SPR1_Y            = $d003
SPR2_X            = $d004
SPR2_Y            = $d005
SPR3_X            = $d006
SPR3_Y            = $d007
SPR4_X            = $d008
SPR4_Y            = $d009
SPR5_X            = $d00a
SPR5_Y            = $d00b
SPR6_X            = $d00c
SPR6_Y            = $d00d
SPR7_X            = $d00e
SPR7_Y            = $d00f
SPR_XMSB          = $d010
SPR_ENABLE        = $d015
SPR_EXPANDX       = $d017
SPR_MULTICOLOR    = $d01c
SPR_EXPANDY       = $d01d
SPR_MC1           = $d025
SPR_MC2           = $d026
SPR0_COLOR        = $d027
SPR1_COLOR        = $d028
SPR2_COLOR        = $d029
SPR3_COLOR        = $d02a
SPR4_COLOR        = $d02b
SPR5_COLOR        = $d02c
SPR6_COLOR        = $d02d
SPR7_COLOR        = $d02e
GETIN             = $ffe4
PLOT              = $fff0


; Colors
BLACK             = 0
WHITE             = 1
RED               = 2
CYAN              = 3
PURPLE            = 4
GREEN             = 5
BLUE              = 6
YELLOW            = 7
ORANGE            = 8
BROWN             = 9
LIGHT_RED         = 10
GRAY1             = 11
GRAY2             = 12
LIGHT_GREEN       = 13
LIGHT_BLUE        = 14
GRAY3             = 15


