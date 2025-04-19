.ORIG x3000

; MARK: main
GETP            ; R0, R1, R2 = X, Y, Z
GETH            ; move y to block under player

ADD R0, R0, #15 ; move away from player 15
ADD R1, R1, #15 ; move above ground 15
ADD R2, R2, #15 ; move away from player 15

LD R3, BLOCK    ; block id

LD R7, BEGIN    ; comparison

LD R4, BEGIN    ; start value x
LD R5, BEGIN    ; start value y
LD R6, BEGIN    ; start value z

START

    ADD R7, R6, #-15        ; check z is max / end
    BRz EXIT                ; if so, exit

    BR MOVE_X

    MOVE_Z
        ADD R0, R0, #-15    ; reset x
        ADD R4, R4, #-15    ; reset local x

        ADD R1, R1, #-14    ; reset y
        ADD R5, R5, #-14    ; reset local y

        ADD R2, R2, #1      ; move z
        ADD R6, R6, #1      ; move local z

        BR DONE

    MOVE_Y
        ADD R7, R5, #-14    ; check y is max
        BRz MOVE_Z

        ADD R0, R0, #-15    ; reset x
        ADD R4, R4, #-15    ; reset local x

        ADD R1, R1, #1      ; move y
        ADD R5, R5, #1      ; move local y

        BR DONE

    MOVE_X
        ADD R7, R4, #-15    ; check x is max
        BRz MOVE_Y

        BR DONE

    DONE
        ADD R0, R0, #1      ; move x
        ADD R4, R4, #1      ; move local x

    ADD R7, R6, #-15        ; check z is max / end
    BRz EXIT                ; if so, exit

    LD R3, BLOCK            ; load block id
    SETB                    ; set block

BR START

EXIT

HALT

; MARK: labels
BLOCK  .FILL #95  ; GLASS_BLOCK
BEGIN  .FILL #0   ; for counting

.END