; Loop x, y, z from -RADIUS to RADIUS
; when any is RADIUS, add -RADIUS to loop
; at each position, calculate distance from 0, 0, 0
; if distance is <= RADIUS place block

; store a global position in R012
; store a local position in R345
; reset R3 before SETB and restore after
; use R6 for calculations
; reserve R7 for returning

; dist:     RADIUS^2 = abs(x)^2 + abs(y)^2 + abs(z)^2
; square:   5^2 = -5 + 5+5 + 4+4 + 3+3 + 2+2 + 1+1
;               = -5 + 30
;               = 25

.ORIG x3000

; MARK: main
GETP            ; R0, R1, R2 = X, Y, Z

ADD R0, R0, #15
ADD R2, R2, #15 ; offset xz by 15

; SETUP i,j,k ;;;
LD R3, RADIUS   ; set R3 to -RADIUS
NOT R3, R3
ADD R3, R3, #1

LD R4, RADIUS   ; set R4 to -RADIUS
NOT R4, R4
ADD R4, R4, #1

LD R5, RADIUS   ; set R5 to -RADIUS
NOT R5, R5
ADD R5, R5, #1  ; local xyz are now -RADIUS

MAIN                   ; main loop

; CUBE ;;;;;;;;;;;;;;;;;
    LD  R6, RADIUS     ; set R6 to RADIUS
    NOT R6, R6         ; negate R6
    ADD R6, R6, #1     ; twos complement

    ADD R6, R3, R6     ; check X
    BRnp DONTRESETX    ; if R3 is not -RADIUS dont reset
    JSR RESETX         ; if R3 is -RADIUS reset X

    LD  R6, RADIUS     ; set R6 to RADIUS
    NOT R6, R6         ; negate R6
    ADD R6, R6, #1     ; twos complement

    ADD R6, R4, R6     ; check Y
    BRnp DONTRESETY    ; if R4 is not -RADIUS dont reset
    JSR RESETY         ; if R4 is -RADIUS reset X

    LD  R6, RADIUS     ; set R6 to RADIUS
    NOT R6, R6         ; negate R6
    ADD R6, R6, #1     ; twos complement

    ADD R6, R5, R6     ; check Z
    BRz EXIT           ; if R5 is -RADIUS break out of loop to exit
    JSR INCREMENTZ     ; if R5 is not -RADIUS increment Z then Y then X

    DONTRESETY
    JSR INCREMENTY     ; increment Y then X

    DONTRESETX
    JSR INCREMENTX     ; increment X

; PLACE BLOCK ;;;;;;;;;;
    JSR STORELOCATION  ; save local xyz since we need the registries

    JSR GETDISTANCE    ; get distance from 0,0,0 into R6
    LD R3 DISTANCE     ; load -100 into R3 -(RADIUS^2)

    ADD R3, R6, R3     ; compare distance to -(RADIUS^2)
    BRp DONTPLACEBLOCK ; if > RADIUS, don't place block

    LD R3, BLOCK_ID    ; load block id
    SETB               ; set block at x, y, z

    DONTPLACEBLOCK

    JSR LOADLOCATION   ; restore local xyz into R345

    BR MAIN            ; loop

EXIT

HALT

; MARK: subroutines
RESETX ; reset local x (R3) and take 2*RADIUS from global x (R0)

    NOT R3, R3     ; assume if we are resetting, R3 == RADUS
    ADD R3, R3, #1 ; R3 is now negative radius

    ADD R0, R0, R3 ; R0 is now 0
    ADD R0, R0, R3 ; R0 is now -RADIUS

    RET

RESETY ; reset local y (R4) and take 2*RADIUS from global y (R1)

    NOT R4, R4     ; assume if we are resetting, R4 == RADUS
    ADD R4, R4, #1 ; R4 is now negative radius

    ADD R1, R1, R4 ; R1 is now 0
    ADD R1, R1, R4 ; R1 is now -RADIUS

    RET

RESETZ ; reset local z (R5) and take 2*RADIUS from global z (R2)

    NOT R5, R5     ; assume if we are resetting, R5 == RADUS
    ADD R5, R5, #1 ; R5 is now negative radius

    ADD R2, R2, R5 ; R2 is now 0
    ADD R2, R2, R5 ; R2 is now -RADIUS

    RET

INCREMENTX ; add 1 to local and global x

    ADD R0, R0, #1 ; increment global
    ADD R3, R3, #1 ; increment local

    RET

INCREMENTY ; add 1 to local and global y

    ADD R1, R1, #1 ; increment global
    ADD R4, R4, #1 ; increment local

    RET

INCREMENTZ ; add 1 to local and global z

    ADD R2, R2, #1 ; increment global
    ADD R5, R5, #1 ; increment local

    RET

STORELOCATION ; store local x, y, z in STORE + x0, x1, x2

    LD  R6, STORE  ; load STORE memory location

    STR R3, R6, x0 ; store x in STORE
    STR R4, R6, x1 ; store y in STORE + x1
    STR R5, R6, x2 ; store z in STORE + x2

    RET

LOADLOCATION ; load local x, y, z from STORE + x0, x1, x2

    LD  R6, STORE  ; load STORE memory location

    LDR R3, R6, x0 ; load x from STORE
    LDR R4, R6, x1 ; load x from STORE + x1
    LDR R5, R6, x2 ; load x from STORE + x2

    RET

GETDISTANCE ; get distance from R3,4,5 to 0,0,0 into R6

; ABSOLUTE VALUES ;;;;;;;
    ADD R3, R3, #0      ; check R3
    BRzp ABSOLUTE_R3    ; if R3 is negative, skip
        NOT R3, R3      ; else negate
        ADD R3, R3, #1  ; twos complement

    ABSOLUTE_R3         ; R3 is positive by here

    ADD R4, R4, #0      ; check R4
    BRzp ABSOLUTE_R4    ; if R4 is negative, skip
        NOT R4, R4      ; else negate
        ADD R4, R4, #1  ; twos complement

    ABSOLUTE_R4         ; R4 is positive by here

    ADD R5, R5, #0      ; check R5
    BRzp ABSOLUTE_R5    ; if R5 is negative, skip
        NOT R5, R5      ; else negate
        ADD R5, R5, #1  ; twos complement

    ABSOLUTE_R5         ; R5 is positive by here

; SQUARE VALUES ;;;;;;;;; -n + 2n + 2(n-1) + ... + 2(1)
    ADD R6, R3, #0      ; use R6 as index
    NOT R3, R3          ; twos complimet
    ADD R3, R3, #-1     ; R3 is negative
    SQUARE_R3
        ADD R3, R3, R6  ; add i to R3
        ADD R3, R3, R6  ; add i to R3
        ADD R6, R6, #-1 ; i--
    BRp SQUARE_R3       ; loop though to index = 1

    ADD R6, R4, #0      ; use R6 as index
    NOT R4, R4          ; twos complimet
    ADD R4, R4, #-1     ; R4 is negative
    SQUARE_R4
        ADD R4, R4, R6  ; add i to R4
        ADD R4, R4, R6  ; add i to R4
        ADD R6, R6, #-1 ; i--
    BRp SQUARE_R4       ; loop though to index = 1

    ADD R6, R5, #0      ; use R6 as index
    NOT R5, R5          ; twos complimet
    ADD R5, R5, #-1     ; R4 is negative
    SQUARE_R5
        ADD R5, R5, R6  ; add i to R4
        ADD R5, R5, R6  ; add i to R4
        ADD R6, R6, #-1 ; i--
    BRp SQUARE_R5       ; loop though to index = 1

; TOTAL ;;;;;;;;;;;;;;;;;
    ADD R6, R3, R4      ; add R3, and R4
    ADD R6, R6, R5      ; add R5. R6 is now total distance
    ADD R6, R6, RADIUS  ; reduce by RADIUS to avoid clipping

    RET

; MARK: labels
BLOCK_ID .FILL #95    ; GLASS_BLOCK

RADIUS   .FILL #10
DISTANCE .FILL #-100  ; -RADIUS^2 used for comparison

STORE    .FILL 0x3100 ; location for saving and loading xyz

.END