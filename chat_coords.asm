; print out the players coordinates to chat
; works up to 5 digit numbers (to support 32768 limit)
; converts the digits into characters
; prints them with a null byte after
; clears leading zeros and adds a label and '-' or ' '

; chat format:
;
; X: 0
; Y:-12345
; Z: 99999

; uses R012 for coords
; uses R3 for passing to CHAT_INTEGER
; uses R456 for output formatting

.ORIG x3000

; MARK: main
LD  R0, ZERO       ; output for a newline
CHAT

GETP               ; R0, R1, R2 = X, Y, Z

; STORE NEGATIVES ;;;;;;;;;
ADD R0, R0, #0            ; check if X is negative
BRn NEGATE_X              ; make it positive
X_POSITIVE
ADD R1, R1, #0            ; check if Y is negative
BRn NEGATE_Y              ; make it positive
Y_POSITIVE
ADD R2, R2, #0            ; check if Z is negative
BRn NEGATE_Z              ; make it positive
Z_POSITIVE

BR AVOID_NEGATES          ; jump over the negate functions

NEGATE_X
    NOT R0, R0            ; twos complement to negate
    ADD R0, R0, #1
    LD  R3, ONE           ; set is x negative to true
    ST  R3, X_IS_NEGATIVE
    BR X_POSITIVE         ; jump back
NEGATE_Y
    NOT R1, R1            ; twos complement to negate
    ADD R1, R1, #1
    LD  R3, ONE           ; set is y negative to true
    ST  R3, Y_IS_NEGATIVE
    BR Y_POSITIVE
NEGATE_Z
    NOT R2, R2            ; twos complement to negate
    ADD R2, R2, #1
    LD  R3, ONE           ; set is z negative to true
    ST  R3, Z_IS_NEGATIVE
    BR Z_POSITIVE

AVOID_NEGATES

; FORMAT & PRINT ;;;;;;;;;;
LD  R3, X_CHAR
ST  R3, CHAR_LABEL        ; set the label to 'X'
LD  R3, SPACE_CHAR        ; set - back to space first
ST  R3, NEGATIVE_CHAR
LD  R3, X_IS_NEGATIVE
ADD R3, R3, #0
BRnz X_NOT_NEG            ; if negative, use a -
    LD  R3, DASH_CHAR
    ST  R3, NEGATIVE_CHAR
X_NOT_NEG
ADD R3, R0, #0            ; copy X into R3
JSR CHAT_INTEGER          ; output

LD  R3, Y_CHAR
ST  R3, CHAR_LABEL        ; set the label to 'Y'
LD  R3, SPACE_CHAR        ; set - back to space first
ST  R3, NEGATIVE_CHAR
LD  R3, Y_IS_NEGATIVE
ADD R3, R3, #0
BRnz Y_NOT_NEG            ; if negative, use a -
    LD  R3, DASH_CHAR
    ST  R3, NEGATIVE_CHAR
Y_NOT_NEG
ADD R3, R1, #0            ; copy Y into R3
JSR CHAT_INTEGER          ; output

LD  R3, Z_CHAR
ST  R3, CHAR_LABEL        ; set the label to 'Z'
LD  R3, SPACE_CHAR        ; set - back to space first
ST  R3, NEGATIVE_CHAR
LD  R3, Z_IS_NEGATIVE
ADD R3, R3, #0
BRnz Z_NOT_NEG            ; if negative, use a -
    LD  R3, DASH_CHAR
    ST  R3, NEGATIVE_CHAR
Z_NOT_NEG
ADD R3, R2, #0            ; copy Z into R3
JSR CHAT_INTEGER          ; output

HALT

; MARK: subroutine
CHAT_INTEGER ; output the value at R3 to chat as a string ; uses R4, R5, and R6

; TEN THOUSANDTHS ;;;;;;;;;;;;;;;;
    LD  R4, ZERO                 ; count ten thousandths
    ADD R5, R3, #0               ; copy R3 into R5 the first time
    LD  R6, NEG_10K              ; -10000 is too big to use inline

    LOOP_10K                     ; loop

        ADD R4, R4, #1           ; add 1 to count
        ADD R5, R5, R6           ; subtract 10000

        BRn BREAK_10K_NEG        ; break once less than 10000
        BRz FINISHED_10K         ; break once equal to 10000
        BRp LOOP_10K             ; keep looping

    BREAK_10K_NEG
    ADD R4, R4, #-1              ; sub 1 from count
    NOT R6, R6                   ; twos complement
    ADD R6, R6, #1               ; R6 is now -10000
    ADD R5, R5, R6               ; add 10000
    BR  FINISHED_10K             ; technically redundant but safe practice

    FINISHED_10K

    LD  R6, ASCII_OFFSET
    ADD R4, R4, R6               ; add ascii offset to character
    ST  R4, CHAR_10K             ; store character in string memory

; THOUSANDTHS ;;;;;;;;;;;;;;;;;;;;
    LD  R4, ZERO                 ; count thousandths
    LD  R6, NEG_1K               ; -1000 is too big to use inline

    LOOP_1K                      ; loop

        ADD R4, R4, #1           ; add 1 to count
        ADD R5, R5, R6           ; subtract 1000

        BRn BREAK_1K_NEG         ; break once less than 1000
        BRz FINISHED_1K          ; break once equal to 1000
        BRp LOOP_1K              ; keep looping

    BREAK_1K_NEG
    ADD R4, R4, #-1              ; sub 1 from count
    NOT R6, R6                   ; twos complement
    ADD R6, R6, #1               ; R6 is now -1000
    ADD R5, R5, R6               ; add 1000
    BR  FINISHED_1K              ; technically redundant but safe practice

    FINISHED_1K

    LD  R6, ASCII_OFFSET
    ADD R4, R4, R6               ; add ascii offset to character
    ST  R4, CHAR_1K              ; store character in string memory

; HUNDREDTHS ;;;;;;;;;;;;;;;;;;;;;
    LD  R4, ZERO                 ; count hundredths
    LD  R6, NEG_HUNDRED          ; -100 is too big to use inline

    HUNDREDS_LOOP                ; loop

        ADD R4, R4, #1           ; add 1 to count
        ADD R5, R5, R6           ; subtract 100

        BRn BREAK_HUNDREDS_NEG   ; break once less than 100
        BRz FINISHED_HUNDREDS    ; break once equal to 100
        BRp HUNDREDS_LOOP        ; keep looping

    BREAK_HUNDREDS_NEG
    ADD R4, R4, #-1              ; sub 1 from count
    NOT R6, R6                   ; twos complement
    ADD R6, R6, #1               ; R6 is now -100
    ADD R5, R5, R6               ; add 100
    BR  FINISHED_HUNDREDS        ; technically redundant but safe practice

    FINISHED_HUNDREDS

    LD  R6, ASCII_OFFSET
    ADD R4, R4, R6               ; add ascii offset to character
    ST  R4, CHAR_HUNDREDS        ; store character in string memory

; TENS ;;;;;;;;;;;;;;;;;;;;;;;;;;;
    LD  R4, ZERO                 ; count tens

    TENS_LOOP                    ; loop

        ADD R4, R4, #1           ; add 1 to count
        ADD R5, R5, #-10         ; subtract 10

        BRn BREAK_TENS_NEG       ; break once less than 10
        BRz FINISHED_TENS        ; break once equal to 10
        BRp TENS_LOOP            ; keep looping

    BREAK_TENS_NEG
    ADD R4, R4, #-1              ; sub 1 from count
    ADD R5, R5, #10              ; add 10
    BR  FINISHED_TENS            ; technically redundant but safe practice

    FINISHED_TENS

    LD  R6, ASCII_OFFSET
    ADD R4, R4, R6               ; add ascii offset to character
    ST  R4, CHAR_TENS            ; store character in string memory

; ONES ;;;;;;;;;;;;;;;;;;;;;;;;;;; we can just use the remaining value for the ones
    LD  R6, ASCII_OFFSET
    ADD R4, R5, R6               ; add ascii offset to character
    ST  R4, CHAR_ONES            ; store character in string memory

; CLEAR LEADING ZEROS ;;;;;;;;;;;;
    LD  R3, ZERO                 ; set to zero for how many chars to move to the left

    LD  R6, ASCII_OFFSET
    NOT R6, R6
    ADD R6, R6, #1               ; negative ascii offset

    LD  R0, CHAR_10K             ; load first digit
    ADD R0, R0, R6               ; sub ascii zero
    BRnp DONE_CLEARING           ; break out if not a zero
    ADD R3, R3, #1               ; move all chars left +1

    LD  R0, CHAR_1K              ; load second digit
    ADD R0, R0, R6               ; sub ascii zero
    BRnp DONE_CLEARING           ; break out if not a zero
    ADD R3, R3, #1               ; move all chars left +1

    LD  R0, CHAR_HUNDREDS        ; load third digit
    ADD R0, R0, R6               ; sub ascii zero
    BRnp DONE_CLEARING           ; break out if not a zero
    ADD R3, R3, #1               ; move all chars left +1

    LD  R0, CHAR_TENS            ; load fourth digit
    ADD R0, R0, R6               ; sub ascii zero
    BRnp DONE_CLEARING           ; break out if not a zero
    ADD R3, R3, #1               ; move all chars left +1

    DONE_CLEARING

    ADD R3, R3, #0
    BRz SKIP_LEFT
    LEFT_LOOP                    ; move digits left 1 char

        LD  R4, CHAR_1K
        ST  R4, CHAR_10K         ; move thousandths into ten thousandths

        LD  R4, CHAR_HUNDREDS
        ST  R4, CHAR_1K          ; move hundredths into thousandths

        LD  R4, CHAR_TENS
        ST  R4, CHAR_HUNDREDS    ; move tens into ten hundredths

        LD  R4, CHAR_ONES
        ST  R4, CHAR_TENS        ; move ones into tens

        LD  R4, SPACE_CHAR
        ST  R4, CHAR_ONES        ; copy space into ones

        ADD R3, R3, #-1          ; decrease loops remaining
        BRp LEFT_LOOP
    SKIP_LEFT

; FINAL OUTPUT ;;;;;;;;;;;;;;;;;;;
    LEA R0, CHAR_LABEL           ; load character array address
    CHAT                         ; output to chat

    RET

; MARK: labels
ZERO          .FILL #0      ; zero for starting counting
ONE           .FILL #1      ; for negative bools

NEG_HUNDRED   .FILL #-100   ; too big to be used inline
NEG_1K        .FILL #-1000
NEG_10K       .FILL #-10000

ASCII_OFFSET  .FILL #48     ; ascii 0

X_CHAR        .FILL #88     ; X ascii value
Y_CHAR        .FILL #89     ; Y ascii value
Z_CHAR        .FILL #90     ; Z ascii value

DASH_CHAR     .FILL #45     ; '-' ascii value

CHAR_LABEL    .FILL #0      ; character array
CHAR_COLON    .FILL #58     ; : ascii value
SPACE_CHAR    .FILL #32     ; space ascii value
NEGATIVE_CHAR .FILL #32     ; space by default, replaced by - when negative
CHAR_10K      .FILL #0
CHAR_1K       .FILL #0
CHAR_HUNDREDS .FILL #0
CHAR_TENS     .FILL #0
CHAR_ONES     .FILL #0

NULL_BYTE  .STRINGZ ""      ; null byte (could be just #0 but this helps for understanding)

X_IS_NEGATIVE .FILL #0      ; booleans for if coords are negative
Y_IS_NEGATIVE .FILL #0
Z_IS_NEGATIVE .FILL #0

.END