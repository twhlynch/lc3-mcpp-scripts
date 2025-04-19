; builds stairs with a given width
; loops moving up or across based on whether i is odd or even

.ORIG x3000

; MARK: main
GETP                        ; R0, R1, R2 = X, Y, Z
ADD R1, R1, #-5             ; offset Y by -5

LD R3, BLOCK_ID             ; Load block id
LD R4, LIMIT                ; start R4 as i

LOOP

    LD R6, WIDTH
    ADD R0, R0, R6          ; move X to end
    BUILD_LOOP
        SETB
        ADD R0, R0, #-1     ; move X back 1
        ADD R6, R6, #-1     ; decrease i
    BRp BUILD_LOOP          ; loop WIDTH times

    BR END                  ; jump over UP and ACROSS

    UP
        ADD R1, R1, #1      ; move Y + 1
        BR DONE             ; jump to done

    ACROSS
        ADD R2, R2, #1      ; move Z + 1
        BR DONE             ; jump to done

    END

        AND R5, R4, #1      ; check if R4 is odd or even
        BRp UP              ; odd
        BRz ACROSS          ; even

    DONE
    
    ADD R4, R4, #-1         ; subtract 1 from i

BRp LOOP                    ; loop until 0

HALT

; MARK: labels
BLOCK_ID .FILL #98  ; Stone Bricks
LIMIT .FILL #100    ; loop 100 times
WIDTH .FILL #10     ; stair width

.END