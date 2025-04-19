; place blocks in the fibonacci sequence

.ORIG x3000

; MARK: main
GETP            ; R0, R1, R2 = X, Y, Z
ADD R1, R1, #-3 ; move down 3

ADD R3, R0, #0  ; origin
LD R4, ZERO     ; last
LD R5, ONE      ; value
LD R6, ZERO     ; count
LD R7, ZERO     ; comparison

START

    BR SKIP                 ; jump over EVEN and ODD

    EVEN
        ADD R0, R3, R5      ; add value and origin into x
        ADD R4, R4, R5      ; add value and last into last
        BR DONE

    ODD
        ADD R0, R3, R4      ; add last and origin into x
        ADD R5, R5, R4      ; add last and value into value
        BR DONE

    SKIP
        AND R7, R6, #1      ; check if count is odd or even to alternate
        BRz EVEN
        BRp ODD

    DONE
        ADD R7, R3, #0      ; save R3 into R7

        LD R3, ONE          ; load 1 (stone)
        SETB                ; place block

        ADD R3, R7, #0      ; load R3 from R7

        ADD R6, R6, #1      ; add 1 to count

        ADD R7, R6, #-15    ; stop at 15

BRnp START

HALT

; MARK: labels
ZERO .FILL #0
ONE  .FILL #1

.END