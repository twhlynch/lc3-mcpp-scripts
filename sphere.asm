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

ADD R0, R0, #15 ; offset x by 15
ADD R2, R2, #15 ; offset z by 15

LD  R3, RADIUS  ; input radius

JSR SPHERE      ; create sphere at R0, R1, R2 of radius R3

HALT

; MARK: subroutines

SPHERE ; creates a sphere at R0, R1, R2 of radius R3

    ST R7 BACKUP_7
    ST R6 BACKUP_6
    ST R5 BACKUP_5
    ST R4 BACKUP_4
    ST R3 BACKUP_3
    ST R2 BACKUP_2
    ST R1 BACKUP_1
    ST R0 BACKUP_0

    ST R3 R_INTERNAL      ; backup RADIUS internally
    NOT R3, R3
    ADD R3, R3, #1
    ST R3 R_NEGATIVE      ; save -RADIUS into R_NEGATIVE
    NOT R3, R3
    ADD R3, R3, #1
    JSR COMPUTE_R_SQUARED ; compute -R3^2 into R_SQUARED


    ; SETUP i,j,k ;;
    NOT R3, R3     ; set R3 to -RADIUS
    ADD R3, R3, #1 ; twos compliment

    ADD R4, R3, #0 ; set R4 to -RADIUS
    ADD R5, R3, #0 ; set R5 to -RADIUS

    ; local xyz are now all -RADIUS

    MAIN                   ; main loop

        ; PLACE BLOCK ;;;;;;
        JSR STORELOCATION  ; save local xyz since we need the registries

        JSR GETDISTANCE    ; get distance from 0,0,0 into R6
        LD R3 R_SQUARED    ; load -100 into R3 -(RADIUS^2)

        ADD R3, R6, R3     ; compare distance to -(RADIUS^2)
        BRp DONTPLACEBLOCK ; if > RADIUS, don't place block

        LD R3, BLOCK_ID    ; load block id
        SETB               ; set block at x, y, z

        DONTPLACEBLOCK

        JSR LOADLOCATION   ; restore local xyz into R345

        ; CUBE ;;;;;;;;;;;;;
        LD  R6, R_NEGATIVE ; set R6 to -RADIUS

        ADD R6, R3, R6     ; check X
        BRnp DONTRESETX    ; if R3 is not RADIUS dont reset                         ; if (x != RADIUS) x++; continue;
        JSR RESETX         ; if R3 is RADIUS reset X                                ; else x = -RADIUS;

        LD  R6, R_NEGATIVE ; set R6 to -RADIUS

        ADD R6, R4, R6     ; check Y
        BRnp DONTRESETY    ; if R4 is not RADIUS dont reset                         ; if (y != RADIUS) y++; continue;
        JSR RESETY         ; if R4 is RADIUS reset X                                ; else y = -RADIUS;

        LD  R6, R_NEGATIVE ; set R6 to -RADIUS

        ADD R6, R5, R6     ; check Z
        BRz EXIT           ; if R5 is RADIUS break out of loop to exit              ; if (z == RADIUS) break;
        JSR INCREMENTZ     ; if R5 is not RADIUS increment Z then Y then X          ; else z++;
        BR MAIN

        DONTRESETY
        JSR INCREMENTY     ; increment Y then X
        BR MAIN

        DONTRESETX
        JSR INCREMENTX     ; increment X

        BR MAIN            ; loop

    EXIT

    LD R7 BACKUP_7
    LD R6 BACKUP_6
    LD R5 BACKUP_5
    LD R4 BACKUP_4
    LD R3 BACKUP_3
    LD R2 BACKUP_2
    LD R1 BACKUP_1
    LD R0 BACKUP_0

    RET

COMPUTE_R_SQUARED ; compute -RADIUS^2 into R_SQUARED label

    ADD R4, R3, #0       ; copy radius into R4
    ADD R5, R3, #0       ; copy radius into R5

    ADD R5, R5, #-1      ; i-- since R4 is already radius

    MLUTPLY_LOOP         ; multiply loop
        ADD R4, R4, R3   ; result += radius
        ADD R5, R5, #-1  ; i--
    BRp MLUTPLY_LOOP     ; repeat radius times so R4 is RADIUS*RADIUS

    NOT R4, R4           ; twos complement
    ADD R4, R4, #1       ; R4 is now -R^2

    ST  R4, R_SQUARED    ; store the value

    RET

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

    LEA R6, STORE  ; load STORE memory location

    STR R3, R6, x0 ; store x in STORE
    STR R4, R6, x1 ; store y in STORE + x1
    STR R5, R6, x2 ; store z in STORE + x2

    RET

LOADLOCATION ; load local x, y, z from STORE + x0, x1, x2

    LEA R6, STORE  ; load STORE memory location

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
    NOT R3, R3          ; twos complement
    ADD R3, R3, #-1     ; R3 is negative
    SQUARE_R3
        ADD R3, R3, R6  ; add i to R3
        ADD R3, R3, R6  ; add i to R3
        ADD R6, R6, #-1 ; i--
    BRp SQUARE_R3       ; loop though to index = 1

    ADD R6, R4, #0      ; use R6 as index
    NOT R4, R4          ; twos complement
    ADD R4, R4, #-1     ; R4 is negative
    SQUARE_R4
        ADD R4, R4, R6  ; add i to R4
        ADD R4, R4, R6  ; add i to R4
        ADD R6, R6, #-1 ; i--
    BRp SQUARE_R4       ; loop though to index = 1

    ADD R6, R5, #0      ; use R6 as index
    NOT R5, R5          ; twos complement
    ADD R5, R5, #-1     ; R4 is negative
    SQUARE_R5
        ADD R5, R5, R6  ; add i to R4
        ADD R5, R5, R6  ; add i to R4
        ADD R6, R6, #-1 ; i--
    BRp SQUARE_R5       ; loop though to index = 1

; TOTAL ;;;;;;;;;;;;;;;;;
    ADD R6, R3, R4      ; add R3, and R4
    ADD R6, R6, R5      ; add R5. R6 is now total distance
    LD R3, R_INTERNAL   ; load RADIUS

    RET

; MARK: labels
BLOCK_ID  .FILL #1  ; input block ID
RADIUS    .FILL #10 ; input radius

; internals for SPHERE subroutine
R_INTERNAL .BLKW 1     ; location to save RADIUS within subroutine
R_NEGATIVE .BLKW 1     ; location for saving -RADIUS used for cube
R_SQUARED  .BLKW 1     ; location for saving -RADIUS^2 used for comparison
STORE      .BLKW 3     ; location for saving and loading xyz
BACKUP_7   .BLKW 1     ; location for backing up R7
BACKUP_6   .BLKW 1     ; location for backing up R6
BACKUP_5   .BLKW 1     ; location for backing up R5
BACKUP_4   .BLKW 1     ; location for backing up R4
BACKUP_3   .BLKW 1     ; location for backing up R3
BACKUP_2   .BLKW 1     ; location for backing up R2
BACKUP_1   .BLKW 1     ; location for backing up R1
BACKUP_0   .BLKW 1     ; location for backing up R0

.END