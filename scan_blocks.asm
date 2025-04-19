; scans a 2D area and prints out all the ids in a grid
; will scan from player tile to ~-10 ~ ~-10

; output format:
; 012 012 012 012 012 012 012 012 012 012
; 012 012 012 012 012 012 012 012 012 012
; 012 001 001 012 012 012 001 001 001 001
; 012 001 001 001 001 001 001 001 001 001
; 000 003 003 001 001 001 001 001 001 001
; 000 000 003 003 003 001 001 001 001 001
; 000 000 000 003 001 001 001 001 001 001
; 000 000 000 001 001 001 001 001 001 001
; 000 000 000 000 001 001 001 001 001 001
; 000 000 000 000 000 001 001 001 001 001

.ORIG	x3000

; MARK: main
GETP                    ; R0, R1, R2 = X, Y, Z
GETH                    ; R1 = block under player

LD  R6, SCALE           ; index starts at SCALE
MAIN_LOOP

    BR OUTPUT_ROW       ; output current row
    DID_OUTPUT_ROW

    ADD R2, R2, #-1     ; move Z-1
    ADD R6, R6, #-1     ; decrease index
    BRz EXIT            ; exit once 0

BR MAIN_LOOP

EXIT

HALT

; MARK: subroutines
OUTPUT_ROW ; output the block ids inline with 

    LEA R5, STRING         ; set R5 to string

    LD  R4, SCALE
    ROW_LOOP

        GETB                ; set R3 to block id

        JSR STORELOCATION

        BR STORE_ID         ; store block id in string (will move R5 across 4 in char arr)
        DID_STORE_ID

        JSR LOADLOCATION

        ADD R0, R0, #-1     ; move  X-1
        ADD R4, R4, #-1     ; decrease index
        BRz BREAK           ; exit once 0

    BR ROW_LOOP

    BREAK

    LD  R4, SCALE
    ADD R0, R0, R4          ; move X back to start

; PRINT ;;;;;;;;;;;;;;;;;
    ADD R5, R0, #0      ; save X in R5

    LEA R0, STRING      ; load char array address
    PUTS                ; log
    CHAT                ; also output to chat cos why not

    ADD R0, R5, #0      ; load X back from R5

    BR DID_OUTPUT_ROW   ; jump back to main loop

STORE_ID ; stores number at R3 in address at R5 + x0, x1, x2
    
    ADD R1, R3, #0               ; copy R3 into R1

; HUNDREDTHS ;;;;;;;;;;;;;;;;;;;;;
    LD  R0, ZERO                 ; count hundredths
    LD  R2, NEG_HUNDRED          ; -100 is too big to use inline

    HUNDREDS_LOOP                ; loop

        ADD R0, R0, #1           ; add 1 to count
        ADD R1, R1, R2           ; subtract 100

        BRn BREAK_HUNDREDS_NEG   ; break once less than 100
        BRz FINISHED_HUNDREDS    ; break once equal to 100
        BRp HUNDREDS_LOOP        ; keep looping

    BREAK_HUNDREDS_NEG
    ADD R0, R0, #-1              ; sub 1 from count
    NOT R2, R2                   ; twos complement
    ADD R2, R2, #1               ; R2 is now -100
    ADD R1, R1, R2               ; add 100
    BR  FINISHED_HUNDREDS        ; technically redundant but safe practice

    FINISHED_HUNDREDS

    LD  R2, ASCII_OFFSET
    ADD R0, R0, R2               ; add ascii offset to character
    STR R0, R5, x0               ; store character in string memory

; TENS ;;;;;;;;;;;;;;;;;;;;;;;;;;;
    LD  R0, ZERO                 ; count tens

    TENS_LOOP                    ; loop

        ADD R0, R0, #1           ; add 1 to count
        ADD R1, R1, #-10         ; subtract 10

        BRn BREAK_TENS_NEG       ; break once less than 10
        BRz FINISHED_TENS        ; break once equal to 10
        BRp TENS_LOOP            ; keep looping

    BREAK_TENS_NEG
    ADD R0, R0, #-1              ; sub 1 from count
    ADD R1, R1, #10              ; add 10
    BR  FINISHED_TENS            ; technically redundant but safe practice

    FINISHED_TENS

    LD  R2, ASCII_OFFSET
    ADD R0, R0, R2               ; add ascii offset to character
    STR R0, R5, x1               ; store character in string memory

; ONES ;;;;;;;;;;;;;;;;;;;;;;;;;;; we can just use the remaining value for the ones
    LD  R2, ASCII_OFFSET
    ADD R0, R1, R2               ; add ascii offset to character
    STR R0, R5, x2               ; store character in string memory

    ADD R5, R5, #4               ; add 4 offset to R5

    BR DID_STORE_ID

STORELOCATION ; store local x, y, z

    STI R0, STOREX ; store x
    STI R1, STOREY ; store y
    STI R2, STOREZ ; store z

    RET

LOADLOCATION ; load local x, y, z

    LDI R0, STOREX ; load x
    LDI R1, STOREY ; load y
    LDI R2, STOREZ ; load z

    RET

; MARK: labels
ZERO          .FILL #0      ; zero for starting counting
ONE           .FILL #1      ; for negative bools

NEG_HUNDRED   .FILL #-100   ; too big to be used inline

ASCII_OFFSET  .FILL #48     ; ascii 0

SCALE .FILL #10             ; 10x10 scan area

STRING .STRINGZ "000 000 000 000 000 000 000 000 000 000 \n"

STOREX .FILL x3100          ; storing x
STOREY .FILL x3101          ; storing y
STOREZ .FILL x3102          ; storing z

.END