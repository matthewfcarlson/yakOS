        CPU     8086
        ORG     0h
InterruptVectorTable:
        ; Internal x86 Interrupts:
        dd      0 ; Reserved (Div err)  ; Int 00h
        dd      0 ; Reserved (Step)     ; Int 01h
        dd      0 ; Reserved (NMI)      ; Int 02h
        dd      0 ; Reserved (Break)    ; Int 03h
        dd      0 ; Reserved (Overflow) ; Int 04h
        dd      0                       ; Int 05h
        dd      0                       ; Int 06h
        dd      0                       ; Int 07h
        ; Hardware Interrupts:
        dd      ResetISR ; Reset               ; Int 08h (IRQ 0)
        dd      TickISR  ; Tick                ; Int 09h (IRQ 1)
        dd      0 ; Keyboard            ; Int 0Ah (IRQ 2)
        dd      0 ; Simptris Game Over  ; Int 0Bh (IRQ 3)
        dd      0 ; Simptris New Piece  ; Int 0Ch (IRQ 4)
        dd      0 ; Simptris Received   ; Int 0Dh (IRQ 5)
        dd      0 ; Simptris Touchdown  ; Int 0Eh (IRQ 6)
        dd      0 ; Simptris Clear      ; Int 0Fh (IRQ 7)
        ; Software Interrupts:
        dd      0 ; Reserved (PC BIOS)  ; Int 10h
        dd      0                       ; Int 11h
        dd      0                       ; Int 12h
        dd      0                       ; Int 13h
        dd      0                       ; Int 14h
        dd      0                       ; Int 15h
        dd      0                       ; Int 16h
        dd      0                       ; Int 17h
        dd      0                       ; Int 18h
        dd      0                       ; Int 19h
        dd      0                       ; Int 1Ah
        dd      0                       ; Int 1Bh
        dd      0                       ; Int 1Ch
        dd      0                       ; Int 1Dh
        dd      0                       ; Int 1Eh
        dd      0                       ; Int 1Fh
        dd      0                       ; Int 20h
        dd      0 ; Reserved (DOS)      ; Int 21h
        dd      0 ; Simptris Services   ; Int 22h
        dd      0                       ; Int 23h
        dd      0                       ; Int 24h
        dd      0                       ; Int 25h
        dd      0                       ; Int 26h
        dd      0                       ; Int 27h
        dd      0                       ; Int 28h
        dd      0                       ; Int 29h
        dd      0                       ; Int 2Ah
        dd      0                       ; Int 2Bh
        dd      0                       ; Int 2Ch
        dd      0                       ; Int 2Dh
        dd      0                       ; Int 2Eh
        dd      0                       ; Int 2Fh
KeyBuffer:                              ; Address 0xC0
        dw      0
NewPieceType:                           ; Address 0xC2
        dw      0
NewPieceID:                             ; Address 0xC4
        dw      0
NewPieceOrientation:                    ; Address 0xC6
        dw      0
NewPieceColumn:                         ; Address 0xC8
        dw      0
TouchdownID:                            ; Address 0xCA
	dw	0
ScreenBitMap0:                          ; Address 0xCC
        dw      0
ScreenBitMap1:
        dw      0
ScreenBitMap2:
        dw      0
ScreenBitMap3:
        dw      0
ScreenBitMap4:
        dw      0
ScreenBitMap5:
        dw      0
TIMES   100h-($-$$) db  0               ; Fill up to (but not including) address 100h with 0
	jmp	main
; This file contains support routines for 32-bit on the 8086.
; It is intended for use code generated by the C86 compiler.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SR_asldiv:			; l1 /= l2
	push	bp
	mov	bp,sp
	push	bx
	mov	bx,[bp+4]	; Get address of l1	(was push3)
	push	word [bp+8]	; Push hi l2		(was push1)
	push	word [bp+6]	; Push lo l2		(was push2)
	push	word [bx+2]	; Push hi l1
	push	word [bx]	; Push lo l1
	call	SR_ldiv
	mov	bx,[bp+4]	; Restore l1 address
	mov	[bx+2],dx	; Store result
	mov	[bx],ax
	pop	bx
	pop	bp
	ret
SR_aslmod:			; l1 %= l2
	push	bp
	mov	bp,sp
	push	bx
	mov	bx,[bp+4]	; Get address of l1	(was push3)
	push	word [bp+8]	; Push hi l2		(was push1)
	push	word [bp+6]	; Push lo l2		(was push2)
	push	word [bx+2]	; Push hi l1
	push	word [bx]	; Push lo l1
	call	SR_lmod
	mov	bx,[bp+4]	; Restore l1 address
	mov	[bx+2],dx	; Store result
	mov	[bx],ax
	pop	bx
	pop	bp
	ret
SR_aslmul:			; l1 *= l2
	push	bp
	mov	bp,sp
	push	bx
	mov	bx,[bp+4]	; Get address of l1	(was push3)
	push	word [bp+8]	; Push hi l2		(was push1)
	push	word [bp+6]	; Push lo l2		(was push2)
	push	word [bx+2]	; Push hi l1
	push	word [bx]	; Push lo l1
	call	SR_lmul
	add	sp,8
	mov	bx,[bp+4]	; Restore l1 address
	mov	[bx+2],dx	; Store result
	mov	[bx],ax
	pop	bx
	pop	bp
	ret
SR_aslshl:			; l1 <<= l2
	push	bp
	mov	bp,sp
	push	bx
	mov	bx,[bp+4]	; Get address of l1	(was push3)
	push	word [bp+8]	; Push hi l2		(was push1)
	push	word [bp+6]	; Push lo l2		(was push2)
	push	word [bx+2]	; Push hi l1
	push	word [bx]	; Push lo l1
	call	SR_lshl
	add	sp,8
	mov	bx,[bp+4]	; Restore l1 address
	mov	[bx+2],dx	; Store result
	mov	[bx],ax
	pop	bx
	pop	bp
	ret
SR_aslshr:			; l1 >>= l2
	push	bp
	mov	bp,sp
	push	bx
	mov	bx,[bp+4]	; Get address of l1	(was push3)
	push	word [bp+8]	; Push hi l2		(was push1)
	push	word [bp+6]	; Push lo l2		(was push2)
	push	word [bx+2]	; Push hi l1
	push	word [bx]	; Push lo l1
	call	SR_lshr
	add	sp,8
	mov	bx,[bp+4]	; Restore l1 address
	mov	[bx+2],dx	; Store result
	mov	[bx],ax
	pop	bx
	pop	bp
	ret


SR_asuldiv:			; u1 /= u2
	push	bp
	mov	bp,sp
	push	bx
	mov	bx,[bp+4]	; Get address of u1	(was push3)
	push	word [bp+8]	; Push hi u2		(was push1)
	push	word [bp+6]	; Push lo u2		(was push2)
	push	word [bx+2]	; Push hi u1
	push	word [bx]	; Push lo u1
	call	SR_uldiv
	mov	bx,[bp+4]	; Restore u1 address
	mov	[bx+2],dx	; Store result
	mov	[bx],ax
	pop	bx
	pop	bp
	ret
SR_asilmod:			; u1 %= u2
	push	bp
	mov	bp,sp
	push	bx
	mov	bx,[bp+4]	; Get address of u1	(was push3)
	push	word [bp+8]	; Push hi u2		(was push1)
	push	word [bp+6]	; Push lo u2		(was push2)
	push	word [bx+2]	; Push hi u1
	push	word [bx]	; Push lo u1
	call	SR_ilmod
	mov	bx,[bp+4]	; Restore u1 address
	mov	[bx+2],dx	; Store result
	mov	[bx],ax
	pop	bx
	pop	bp
	ret
SR_asulmul:			; u1 *= u2
	push	bp
	mov	bp,sp
	push	bx
	mov	bx,[bp+4]	; Get address of u1	(was push3)
	push	word [bp+8]	; Push hi u2		(was push1)
	push	word [bp+6]	; Push lo u2		(was push2)
	push	word [bx+2]	; Push hi u1
	push	word [bx]	; Push lo u1
	call	SR_ulmul
	add	sp,8
	mov	bx,[bp+4]	; Restore u1 address
	mov	[bx+2],dx	; Store result
	mov	[bx],ax
	pop	bx
	pop	bp
	ret
SR_asulshl:			; u1 << u2
	push	bp
	mov	bp,sp
	push	bx
	mov	bx,[bp+4]	; Get address of u1	(was push3)
	push	word [bp+8]	; Push hi u2		(was push1)
	push	word [bp+6]	; Push lo u2		(was push2)
	push	word [bx+2]	; Push hi u1
	push	word [bx]	; Push lo u1
	call	SR_ulshl
	add	sp,8
	mov	bx,[bp+4]	; Restore u1 address
	mov	[bx+2],dx	; Store result
	mov	[bx],ax
	pop	bx
	pop	bp
	ret
SR_asulshr:			; u1 >> u2
	push	bp
	mov	bp,sp
	push	bx
	mov	bx,[bp+4]	; Get address of u1	(was push3)
	push	word [bp+8]	; Push hi u2		(was push1)
	push	word [bp+6]	; Push lo u2		(was push2)
	push	word [bx+2]	; Push hi u1
	push	word [bx]	; Push lo u1
	call	SR_ulshr
	add	sp,8
	mov	bx,[bp+4]	; Restore u1 address
	mov	[bx+2],dx	; Store result
	mov	[bx],ax
	pop	bx
	pop	bp
	ret


; Main 32-bit routines begin here:

SR_ldiv:	; N_LDIV@
	pop    cx
	push   cs
	push   cx
	; LDIV@
	xor    cx,cx
	jmp    LSR_01
SR_uldiv:	; N_LUDIV@
	pop    cx
	push   cs
	push   cx
	; F_LUDIV@
	mov    cx,0001
	jmp    LSR_01
SR_lmod:	; N_LMOD@
	pop    cx
	push   cs
	push   cx
	; F_LMOD@
	mov    cx,0002
	jmp    LSR_01
SR_ilmod:	; N_LUMOD@
	pop    cx
	push   cs
	push   cx
	; LUMOD@
	mov    cx,0003
LSR_01:
	push   bp
	push   si
	push   di
	mov    bp,sp
	mov    di,cx
	mov    ax,[bp+0Ah]
	mov    dx,[bp+0Ch]
	mov    bx,[bp+0Eh]
	mov    cx,[bp+10h]
	or     cx,cx
	jne    LSR_02
	or     dx,dx
	je     LSR_10
	or     bx,bx
	je     LSR_10
LSR_02:
	test   di,0001
	jne    LSR_04
	or     dx,dx
	jns    LSR_03
	neg    dx
	neg    ax
	sbb    dx,0000
	or     di,000Ch
LSR_03:
	or     cx,cx
	jns    LSR_04
	neg    cx
	neg    bx
	sbb    cx,0000
	xor    di,0004
LSR_04:
	mov    bp,cx
	mov    cx,0020h
	push   di
	xor    di,di
	xor    si,si
LSR_05:
	shl    ax,1
	rcl    dx,1
	rcl    si,1
	rcl    di,1
	cmp    di,bp
	jb     LSR_07
	ja     LSR_06
	cmp    si,bx
	jb     LSR_07
LSR_06:
	sub    si,bx
	sbb    di,bp
	inc    ax
LSR_07:
	loop   LSR_05
	pop    bx
	test   bx,0002
	je     LSR_08
	mov    ax,si
	mov    dx,di
	shr    bx,1
LSR_08:
	test   bx,0004h
	je     LSR_09
	neg    dx
	neg    ax
	sbb    dx,0000
LSR_09:
	pop    di
	pop    si
	pop    bp
	retf   0008
LSR_10:
	div    bx
	test   di,0002
	je     LSR_11
	xchg   dx,ax
LSR_11:
	xor    dx,dx
	jmp    LSR_09
SR_lshl:	; N_LXLSH@
SR_ulshl:
	; r = a << b
	pop    bx
	push   cs
	push   bx

	push   bp
	mov    bp,sp

	push   cx	; C86 doesn't expect use of cx or bx

	mov    ax, [bp+6]	; pop loword(a)
	mov    dx, [bp+8]	; pop hiword(a)
	mov    cx, [bp+10]	; pop word(b)
	
	; LXLSH@
	cmp    cl,10h
	jnb    LSR_12
	mov    bx,ax
	shl    ax,cl
	shl    dx,cl
	neg    cl
	add    cl,10h
	shr    bx,cl
	or     dx,bx
	pop    cx
	pop    bp
	retf
LSR_12:
	sub    cl,10h
	xchg   dx,ax
	xor    ax,ax
	shl    dx,cl
	pop    cx
	pop    bp
	retf
SR_lshr:	; N_LXRSH@
	; r = a >> b
	pop    bx
	push   cs
	push   bx

	push   bp
	mov    bp,sp

	push   cx	; C86 doesn't expect use of cx or bx

        mov    ax, [bp+6]	; pop loword(a)
	mov    dx, [bp+8]	; pop hiword(a)
	mov    cx, [bp+10]	; pop word(b)
	
	; LXRSH@
	cmp    cl,10h
	jnb    LSR_13
	mov    bx,dx
	shr    ax,cl
	sar    dx,cl
	neg    cl
	add    cl,10h
	shl    bx,cl
	or     ax,bx
	pop    cx
	pop    bp
	retf
LSR_13:
	sub    cl,10h
	xchg   dx,ax
	cwd
	sar    ax,cl
	pop    cx
	pop    bp
	retf
SR_ulshr:	; N_LXURSH@
	; r = a >> b
	pop    bx
	push   cs
	push   bx

	push   bp
	mov    bp,sp

	push   cx	; C86 doesn't expect use of cx or bx

        mov    ax, [bp+6]	; pop loword(a)
	mov    dx, [bp+8]	; pop hiword(a)
	mov    cx, [bp+10]	; pop word(b)
	
	; LXURSH@
	cmp    cl,10h
	jnb    LSR_14
	mov    bx,dx
	shr    ax,cl
	shr    dx,cl
	neg    cl
	add    cl,10h
	shl    bx,cl
	or     ax,bx
	pop    cx
	pop    bp
	retf
LSR_14:
	sub    cl,10h
	xchg   dx,ax
	xor    dx,dx
	shr    ax,cl
	pop    cx
	pop    bp
	retf
SR_lmul:	; N_LXMUL@
SR_ulmul:
	; r = a * b
	push   bp
	push   si
	mov    bp,sp

	push   cx	; C86 doesn't expect use of cx or bx
	push   bx

        mov    bx, [bp+6]	; pop loword(a)
	mov    cx, [bp+8]	; pop hiword(a)
	mov    ax, [bp+10]	; pop loword(b)
	mov    dx, [bp+12]	; pop hiword(b)
	
	xchg   si,ax
	xchg   dx,ax
	test   ax,ax
	je     LSR_15
	mul    bx
LSR_15:
	jcxz   LSR_16
	xchg   cx,ax
	mul    si
	add    ax,cx
LSR_16:
	xchg   si,ax
	mul    bx
	add    dx,si
	pop    bx
	pop    cx
	pop    si
	pop    bp
	ret

; Generated by c86 (BYU-NASM) 5.1 (beta) from clib.c
	CPU	8086
	ALIGN	2
	jmp	main	; Jump to program start
new_line:
	db	13,10,36
	ALIGN	2
signalEOI:
	jmp	L_clib_1
L_clib_2:
	mov	al, 0x20
	out	0x20, al
	mov	sp, bp
	pop	bp
	ret
L_clib_1:
	push	bp
	mov	bp, sp
	jmp	L_clib_2
	ALIGN	2
exit:
	jmp	L_clib_4
L_clib_5:
	mov	ah, 4Ch
	mov	al, [bp+4]
	int	21h
	mov	sp, bp
	pop	bp
	ret
L_clib_4:
	push	bp
	mov	bp, sp
	jmp	L_clib_5
	ALIGN	2
print:
	jmp	L_clib_7
L_clib_8:
	mov	ah, 40h
	mov	bx, 1
	mov	cx, [bp+6]
	mov	dx, [bp+4]
	int	21h
	mov	sp, bp
	pop	bp
	ret
L_clib_7:
	push	bp
	mov	bp, sp
	jmp	L_clib_8
	ALIGN	2
printChar:
	jmp	L_clib_10
L_clib_11:
	mov	ah, 2
	mov	dl, [bp+4]
	int	21h
	mov	sp, bp
	pop	bp
	ret
L_clib_10:
	push	bp
	mov	bp, sp
	jmp	L_clib_11
	ALIGN	2
printNewLine:
	jmp	L_clib_13
L_clib_14:
	mov	ah, 9
	mov	dx, new_line
	int	21h
	mov	sp, bp
	pop	bp
	ret
L_clib_13:
	push	bp
	mov	bp, sp
	jmp	L_clib_14
	ALIGN	2
printString:
	jmp	L_clib_16
L_clib_17:
	xor	si,si
	mov	bx, [bp+4]
	jmp	printString2
	printString1:
	inc	si
	printString2:
	cmp	byte [bx+si],0
	jne	printString1
	mov	dx, bx
	mov	cx, si
	mov	ah, 40h
	mov	bx, 1
	int	21h
	mov	sp, bp
	pop	bp
	ret
L_clib_16:
	push	bp
	mov	bp, sp
	push	cx
	jmp	L_clib_17
	ALIGN	2
printInt:
	jmp	L_clib_19
L_clib_20:
	mov	word [bp-2], 0
	mov	word [bp-4], 10000
	cmp	word [bp+4], 0
	jge	L_clib_21
	mov	byte [bp-10], 45
	inc	word [bp-2]
	mov	ax, word [bp+4]
	neg	ax
	mov	word [bp+4], ax
L_clib_21:
	mov	ax, word [bp+4]
	test	ax, ax
	jne	L_clib_22
	mov	word [bp-4], 1
	jmp	L_clib_23
L_clib_22:
	jmp	L_clib_25
L_clib_24:
	mov	ax, word [bp-4]
	cwd
	mov	cx, 10
	idiv	cx
	mov	word [bp-4], ax
L_clib_25:
	mov	ax, word [bp+4]
	cwd
	idiv	word [bp-4]
	test	ax, ax
	je	L_clib_24
L_clib_26:
L_clib_23:
	jmp	L_clib_28
L_clib_27:
	mov	ax, word [bp+4]
	xor	dx, dx
	div	word [bp-4]
	add	al, 48
	mov	si, word [bp-2]
	lea	dx, [bp-10]
	add	si, dx
	mov	byte [si], al
	inc	word [bp-2]
	mov	ax, word [bp+4]
	xor	dx, dx
	div	word [bp-4]
	mov	ax, dx
	mov	word [bp+4], ax
	mov	ax, word [bp-4]
	cwd
	mov	cx, 10
	idiv	cx
	mov	word [bp-4], ax
	mov	ax, word [bp-4]
	mov	word [bp-4], ax
L_clib_28:
	cmp	word [bp-4], 0
	jg	L_clib_27
L_clib_29:
	push	word [bp-2]
	lea	ax, [bp-10]
	push	ax
	call	print
	add	sp, 4
	mov	sp, bp
	pop	bp
	ret
L_clib_19:
	push	bp
	mov	bp, sp
	sub	sp, 10
	jmp	L_clib_20
	ALIGN	2
printLong:
	jmp	L_clib_31
L_clib_32:
	mov	word [bp-2], 0
	mov	word [bp-6], 51712
	mov	word [bp-4], 15258
	cmp	word [bp+6], 0
	jg	L_clib_33
	jl	L_clib_34
	cmp	word [bp+4], 0
	jae	L_clib_33
L_clib_34:
	mov	byte [bp-17], 45
	inc	word [bp-2]
	mov	ax, word [bp+4]
	mov	dx, word [bp+6]
	neg	ax
	adc	dx, 0
	neg	dx
	mov	word [bp+4], ax
	mov	word [bp+6], dx
L_clib_33:
	mov	ax, word [bp+4]
	mov	dx, word [bp+6]
	or	dx, ax
	jne	L_clib_35
	mov	word [bp-6], 1
	mov	word [bp-4], 0
	jmp	L_clib_36
L_clib_35:
	jmp	L_clib_38
L_clib_37:
	mov	ax, 10
	xor	dx, dx
	push	dx
	push	ax
	lea	ax, [bp-6]
	push	ax
	call	SR_asldiv
L_clib_38:
	push	word [bp-4]
	push	word [bp-6]
	push	word [bp+6]
	push	word [bp+4]
	call	SR_ldiv
	or	dx, ax
	je	L_clib_37
L_clib_39:
L_clib_36:
	jmp	L_clib_41
L_clib_40:
	push	word [bp-4]
	push	word [bp-6]
	push	word [bp+6]
	push	word [bp+4]
	call	SR_uldiv
	add	al, 48
	mov	si, word [bp-2]
	lea	dx, [bp-17]
	add	si, dx
	mov	byte [si], al
	inc	word [bp-2]
	push	word [bp-4]
	push	word [bp-6]
	push	word [bp+6]
	push	word [bp+4]
	call	SR_lmod
	mov	word [bp+4], ax
	mov	word [bp+6], dx
	mov	ax, 10
	xor	dx, dx
	push	dx
	push	ax
	lea	ax, [bp-6]
	push	ax
	call	SR_asldiv
L_clib_41:
	cmp	word [bp-4], 0
	jg	L_clib_40
	jne	L_clib_43
	cmp	word [bp-6], 0
	ja	L_clib_40
L_clib_43:
L_clib_42:
	push	word [bp-2]
	lea	ax, [bp-17]
	push	ax
	call	print
	add	sp, 4
	mov	sp, bp
	pop	bp
	ret
L_clib_31:
	push	bp
	mov	bp, sp
	sub	sp, 18
	jmp	L_clib_32
	ALIGN	2
printUInt:
	jmp	L_clib_45
L_clib_46:
	mov	word [bp-2], 0
	mov	word [bp-4], 10000
	mov	ax, word [bp+4]
	test	ax, ax
	jne	L_clib_47
	mov	word [bp-4], 1
	jmp	L_clib_48
L_clib_47:
	jmp	L_clib_50
L_clib_49:
	mov	ax, word [bp-4]
	xor	dx, dx
	mov	cx, 10
	div	cx
	mov	word [bp-4], ax
L_clib_50:
	mov	ax, word [bp+4]
	xor	dx, dx
	div	word [bp-4]
	test	ax, ax
	je	L_clib_49
L_clib_51:
L_clib_48:
	jmp	L_clib_53
L_clib_52:
	mov	ax, word [bp+4]
	xor	dx, dx
	div	word [bp-4]
	add	al, 48
	mov	si, word [bp-2]
	lea	dx, [bp-10]
	add	si, dx
	mov	byte [si], al
	inc	word [bp-2]
	mov	ax, word [bp+4]
	xor	dx, dx
	div	word [bp-4]
	mov	word [bp+4], dx
	mov	ax, word [bp-4]
	xor	dx, dx
	mov	cx, 10
	div	cx
	mov	word [bp-4], ax
L_clib_53:
	mov	ax, word [bp-4]
	test	ax, ax
	jne	L_clib_52
L_clib_54:
	push	word [bp-2]
	lea	ax, [bp-10]
	push	ax
	call	print
	add	sp, 4
	mov	sp, bp
	pop	bp
	ret
L_clib_45:
	push	bp
	mov	bp, sp
	sub	sp, 10
	jmp	L_clib_46
	ALIGN	2
printULong:
	jmp	L_clib_56
L_clib_57:
	mov	word [bp-2], 0
	mov	word [bp-6], 51712
	mov	word [bp-4], 15258
	mov	ax, word [bp+4]
	mov	dx, word [bp+6]
	or	dx, ax
	jne	L_clib_58
	mov	word [bp-6], 1
	mov	word [bp-4], 0
	jmp	L_clib_59
L_clib_58:
	jmp	L_clib_61
L_clib_60:
	mov	ax, 10
	xor	dx, dx
	push	dx
	push	ax
	lea	ax, [bp-6]
	push	ax
	call	SR_asuldiv
L_clib_61:
	push	word [bp-4]
	push	word [bp-6]
	push	word [bp+6]
	push	word [bp+4]
	call	SR_uldiv
	or	dx, ax
	je	L_clib_60
L_clib_62:
L_clib_59:
	jmp	L_clib_64
L_clib_63:
	push	word [bp-4]
	push	word [bp-6]
	push	word [bp+6]
	push	word [bp+4]
	call	SR_uldiv
	add	al, 48
	mov	si, word [bp-2]
	lea	dx, [bp-17]
	add	si, dx
	mov	byte [si], al
	inc	word [bp-2]
	push	word [bp-4]
	push	word [bp-6]
	lea	ax, [bp+4]
	push	ax
	call	SR_asilmod
	mov	ax, 10
	xor	dx, dx
	push	dx
	push	ax
	lea	ax, [bp-6]
	push	ax
	call	SR_asuldiv
L_clib_64:
	mov	ax, word [bp-6]
	mov	dx, word [bp-4]
	or	dx, ax
	jne	L_clib_63
L_clib_65:
	push	word [bp-2]
	lea	ax, [bp-17]
	push	ax
	call	print
	add	sp, 4
	mov	sp, bp
	pop	bp
	ret
L_clib_56:
	push	bp
	mov	bp, sp
	sub	sp, 18
	jmp	L_clib_57
	ALIGN	2
printByte:
	jmp	L_clib_67
L_clib_68:
	mov	al, byte [bp+4]
	cbw
	mov	cx, 4
	sar	ax, cl
	and	ax, 15
	mov	byte [bp-1], al
	cmp	byte [bp-1], 9
	jle	L_clib_69
	mov	al, byte [bp-1]
	cbw
	sub	ax, 10
	add	ax, 65
	jmp	L_clib_70
L_clib_69:
	mov	al, byte [bp-1]
	cbw
	add	ax, 48
L_clib_70:
	mov	byte [bp-3], al
	mov	al, byte [bp+4]
	and	al, 15
	mov	byte [bp-1], al
	cmp	byte [bp-1], 9
	jle	L_clib_71
	mov	al, byte [bp-1]
	cbw
	sub	ax, 10
	add	ax, 65
	jmp	L_clib_72
L_clib_71:
	mov	al, byte [bp-1]
	cbw
	add	ax, 48
L_clib_72:
	mov	byte [bp-2], al
	mov	ax, 2
	push	ax
	lea	ax, [bp-3]
	push	ax
	call	print
	add	sp, 4
	mov	sp, bp
	pop	bp
	ret
L_clib_67:
	push	bp
	mov	bp, sp
	sub	sp, 4
	jmp	L_clib_68
	ALIGN	2
printWord:
	jmp	L_clib_74
L_clib_75:
	mov	word [bp-2], 3
	jmp	L_clib_77
L_clib_76:
	mov	ax, word [bp+4]
	and	ax, 15
	mov	byte [bp-3], al
	cmp	byte [bp-3], 9
	jle	L_clib_80
	mov	al, byte [bp-3]
	cbw
	sub	ax, 10
	add	ax, 65
	jmp	L_clib_81
L_clib_80:
	mov	al, byte [bp-3]
	cbw
	add	ax, 48
L_clib_81:
	mov	si, word [bp-2]
	lea	dx, [bp-7]
	add	si, dx
	mov	byte [si], al
	mov	ax, word [bp+4]
	mov	cx, 4
	sar	ax, cl
	mov	word [bp+4], ax
L_clib_79:
	dec	word [bp-2]
L_clib_77:
	cmp	word [bp-2], 0
	jge	L_clib_76
L_clib_78:
	mov	ax, 4
	push	ax
	lea	ax, [bp-7]
	push	ax
	call	print
	add	sp, 4
	mov	sp, bp
	pop	bp
	ret
L_clib_74:
	push	bp
	mov	bp, sp
	sub	sp, 8
	jmp	L_clib_75
	ALIGN	2
printDWord:
	jmp	L_clib_83
L_clib_84:
	lea	ax, [bp+4]
	mov	si, ax
	mov	ax, word [si]
	mov	word [bp-6], ax
	lea	ax, [bp+4]
	mov	si, ax
	add	si, 2
	mov	ax, word [si]
	mov	word [bp-8], ax
	mov	word [bp-2], 3
	jmp	L_clib_86
L_clib_85:
	mov	ax, word [bp-6]
	and	ax, 15
	mov	byte [bp-3], al
	cmp	byte [bp-3], 9
	jle	L_clib_89
	mov	al, byte [bp-3]
	cbw
	sub	ax, 10
	add	ax, 65
	jmp	L_clib_90
L_clib_89:
	mov	al, byte [bp-3]
	cbw
	add	ax, 48
L_clib_90:
	mov	dx, word [bp-2]
	add	dx, 4
	mov	si, dx
	lea	dx, [bp-16]
	add	si, dx
	mov	byte [si], al
	mov	ax, word [bp-6]
	mov	cx, 4
	sar	ax, cl
	mov	word [bp-6], ax
	mov	ax, word [bp-8]
	and	ax, 15
	mov	byte [bp-3], al
	cmp	byte [bp-3], 9
	jle	L_clib_91
	mov	al, byte [bp-3]
	cbw
	sub	ax, 10
	add	ax, 65
	jmp	L_clib_92
L_clib_91:
	mov	al, byte [bp-3]
	cbw
	add	ax, 48
L_clib_92:
	mov	si, word [bp-2]
	lea	dx, [bp-16]
	add	si, dx
	mov	byte [si], al
	mov	ax, word [bp-8]
	mov	cx, 4
	sar	ax, cl
	mov	word [bp-8], ax
L_clib_88:
	dec	word [bp-2]
L_clib_86:
	cmp	word [bp-2], 0
	jge	L_clib_85
L_clib_87:
	mov	ax, 8
	push	ax
	lea	ax, [bp-16]
	push	ax
	call	print
	add	sp, 4
	mov	sp, bp
	pop	bp
	ret
L_clib_83:
	push	bp
	mov	bp, sp
	sub	sp, 16
	jmp	L_clib_84


TickISR:
	cli				;this is atomic so no more interrupts for a bit
	;save context 
	;TODO: create a function that pushes and pops context in the same way
	pushf 			;pushes flags
	push ax
	push bx
	push dx
	push si
	push di
	push bp
	push es
	push ds
	sti;
	
	;call the tick handler to handle the interrupt
	call YKTickHandler 
	
	cli
	pop ds
	pop es
	pop bp
	pop di
	pop si
	pop dx
	pop bx	
	mov	al, 0x20	; Load nonspecific EOI value (0x20) into register al
	out	0x20, al	; Write EOI to PIC (port 0x20)
	pop ax;
	popf			; pops flags
	
	sti 	;return interrupts back on
	iret 	;return from interrupt
	
ResetISR:
	jmp main;
	

SwitchContext:
	;we put the address we need in a local variable in YKDispatch
	mov sp, [bp-2] ;this is the stack pointer
	mov bp, sp ;set the basepointer accordingly - we are going to pop it soon
	add bp, 18 ;for debugging purposes
	
	;next pop all the registers
	pop ds
	pop es
	pop bp
	pop di
	pop si
	pop dx
	pop bx
	pop ax
	;This will pop the next three registers: IP, CS, and flags
	iret;
	; Generated by c86 (BYU-NASM) 5.1 (beta) from YAKkernel.i
	CPU	8086
	ALIGN	2
	jmp	main	; Jump to program start
	ALIGN	2
YKInitialize:
	; >>>>> Line:	38
	; >>>>> void YKInitialize(){ 
	jmp	L_YAKkernel_1
L_YAKkernel_2:
	; >>>>> Line:	39
	; >>>>> YKEnterMutex(); 
	call	YKEnterMutex
	; >>>>> Line:	40
	; >>>>> YKIdleTask(){ 
	mov	word [YKCtxSwCount], 0
	; >>>>> Line:	41
	; >>>>> YKISRDepth = 0; 
	mov	word [YKISRDepth], 0
	; >>>>> Line:	42
	; >>>>> YKIdleCount = 0; 
	mov	word [YKIdleCount], 0
	; >>>>> Line:	43
	; >>>>> YKReadyTasks =  0 ; 
	mov	word [YKReadyTasks], 0
	; >>>>> Line:	44
	; >>>>> YKSuspendedTasks =  0 ; 
	mov	word [YKSuspendedTasks], 0
	; >>>>> Line:	45
	; >>>>> YKAllTasks =  0 ; 
	mov	word [YKAllTasks], 0
	; >>>>> Line:	46
	; >>>>> YKCurrentTask =  0 ; 
	mov	word [YKCurrentTask], 0
	; >>>>> Line:	47
	; >>>>> YKTCBMallocIndex = 0; 
	mov	word [YKTCBMallocIndex], 0
	; >>>>> Line:	51
	; >>>>> YKNewTask(YKIdleTask, &IdleStack[ 100 ],255); 
	mov	ax, 255
	push	ax
	mov	ax, (IdleStack+200)
	push	ax
	mov	ax, YKIdleTask
	push	ax
	call	YKNewTask
	add	sp, 6
	; >>>>> Line:	52
	; >>>>> YKExitMutex(); 
	call	YKExitMutex
	mov	sp, bp
	pop	bp
	ret
L_YAKkernel_1:
	push	bp
	mov	bp, sp
	jmp	L_YAKkernel_2
	ALIGN	2
YKEnterMutex:
	; >>>>> Line:	56
	; >>>>> void YKEnterMutex(){ 
	jmp	L_YAKkernel_4
L_YAKkernel_5:
	; >>>>> Line:	57
	; >>>>> asm("cli"); 
	cli
	mov	sp, bp
	pop	bp
	ret
L_YAKkernel_4:
	push	bp
	mov	bp, sp
	jmp	L_YAKkernel_5
	ALIGN	2
YKExitMutex:
	; >>>>> Line:	61
	; >>>>> void YKExitMutex(){ 
	jmp	L_YAKkernel_7
L_YAKkernel_8:
	; >>>>> Line:	62
	; >>>>> asm("sti"); 
	sti
	mov	sp, bp
	pop	bp
	ret
L_YAKkernel_7:
	push	bp
	mov	bp, sp
	jmp	L_YAKkernel_8
	ALIGN	2
YKEnterISR:
	; >>>>> Line:	66
	; >>>>> void YKEnterISR(){ 
	jmp	L_YAKkernel_10
L_YAKkernel_11:
	; >>>>> Line:	68
	; >>>>> YKEnterMutex(); 
	call	YKEnterMutex
	; >>>>> Line:	69
	; >>>>> ++YKISRDepth; 
	inc	word [YKISRDepth]
	; >>>>> Line:	70
	; >>>>> YKExitMutex(); 
	call	YKExitMutex
	mov	sp, bp
	pop	bp
	ret
L_YAKkernel_10:
	push	bp
	mov	bp, sp
	jmp	L_YAKkernel_11
	ALIGN	2
YKExitISR:
	; >>>>> Line:	74
	; >>>>> void YKExitISR(){ 
	jmp	L_YAKkernel_13
L_YAKkernel_14:
	; >>>>> Line:	75
	; >>>>> YKEnterMutex(); 
	call	YKEnterMutex
	; >>>>> Line:	76
	; >>>>> --YKISRDepth; 
	dec	word [YKISRDepth]
	; >>>>> Line:	79
	; >>>>> if (YKISRDepth == 0){ 
	mov	ax, word [YKISRDepth]
	test	ax, ax
	jne	L_YAKkernel_15
	; >>>>> Line:	81
	; >>>>> YKScheduler(); 
	call	YKScheduler
L_YAKkernel_15:
	; >>>>> Line:	84
	; >>>>> YKExitMutex(); 
	call	YKExitMutex
	mov	sp, bp
	pop	bp
	ret
L_YAKkernel_13:
	push	bp
	mov	bp, sp
	jmp	L_YAKkernel_14
	ALIGN	2
YKIdleTask:
	; >>>>> Line:	88
	; >>>>> void YKIdleTask(){ 
	jmp	L_YAKkernel_17
L_YAKkernel_18:
	; >>>>> Line:	90
	; >>>>> while(1){ 
	mov	word [bp-2], 0
	; >>>>> Line:	90
	; >>>>> while(1){ 
	jmp	L_YAKkernel_20
L_YAKkernel_19:
	; >>>>> Line:	91
	; >>>>> for (i = 0; i< 5000; i++); 
	mov	word [bp-2], 0
	jmp	L_YAKkernel_23
L_YAKkernel_22:
L_YAKkernel_25:
	inc	word [bp-2]
L_YAKkernel_23:
	cmp	word [bp-2], 5000
	jl	L_YAKkernel_22
L_YAKkernel_24:
	; >>>>> Line:	92
	; >>>>> ++YKIdleCount; 
	inc	word [YKIdleCount]
L_YAKkernel_20:
	jmp	L_YAKkernel_19
L_YAKkernel_21:
	mov	sp, bp
	pop	bp
	ret
L_YAKkernel_17:
	push	bp
	mov	bp, sp
	push	cx
	jmp	L_YAKkernel_18
	ALIGN	2
YKNewTask:
	; >>>>> Line:	97
	; >>>>> void YKNewTask(void* taskFunc, void* taskStack, int priority){ 
	jmp	L_YAKkernel_27
L_YAKkernel_28:
	; >>>>> Line:	100
	; >>>>> ++YKTCBMallocIndex; 
	mov	ax, word [YKTCBMallocIndex]
	mov	cx, 12
	imul	cx
	add	ax, YKTCBs
	mov	word [bp-2], ax
	mov	ax, word [bp+6]
	mov	word [bp-4], ax
	; >>>>> Line:	100
	; >>>>> ++YKTCBMallocIndex; 
	inc	word [YKTCBMallocIndex]
	; >>>>> Line:	106
	; >>>>> *(newStackSP) =  64 ; 
	mov	si, word [bp-4]
	mov	word [si], 64
	; >>>>> Line:	107
	; >>>>> newStackSP -= 2; 
	sub	word [bp-4], 4
	; >>>>> Line:	108
	; >>>>> *(newStackSP) = 0; 
	mov	si, word [bp-4]
	mov	word [si], 0
	; >>>>> Line:	109
	; >>>>> newStackSP -= 2; 
	sub	word [bp-4], 4
	; >>>>> Line:	110
	; >>>>> *(newStackSP) = (int)taskFunc; 
	mov	si, word [bp-4]
	mov	ax, word [bp+4]
	mov	word [si], ax
	; >>>>> Line:	111
	; >>>>> taskStack -= 18; 
	sub	word [bp+6], -18
	; >>>>> Line:	112
	; >>>>> newTask->stackPtr = (int)taskStack; 
	mov	si, word [bp-2]
	mov	ax, word [bp+6]
	mov	word [si], ax
	; >>>>> Line:	116
	; >>>>> newTask->priority = priority; 
	mov	si, word [bp-2]
	add	si, 4
	mov	ax, word [bp+8]
	mov	word [si], ax
	; >>>>> Line:	117
	; >>>>> newTask->next =  0 ; 
	mov	si, word [bp-2]
	add	si, 8
	mov	word [si], 0
	; >>>>> Line:	118
	; >>>>> newTask->prev =  0 ; 
	mov	si, word [bp-2]
	add	si, 10
	mov	word [si], 0
	; >>>>> Line:	121
	; >>>>> YKAddToReadyList(newTask); 
	push	word [bp-2]
	call	YKAddToReadyList
	add	sp, 2
	mov	sp, bp
	pop	bp
	ret
L_YAKkernel_27:
	push	bp
	mov	bp, sp
	sub	sp, 4
	jmp	L_YAKkernel_28
L_YAKkernel_30:
	DB	"Starting Yak OS (c) 2015",0xA,0
	ALIGN	2
YKRun:
	; >>>>> Line:	125
	; >>>>> TC 
	jmp	L_YAKkernel_31
L_YAKkernel_32:
	; >>>>> Line:	126
	; >>>>> printString("Starting Yak OS (c) 2015\n"); 
	mov	ax, L_YAKkernel_30
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	127
	; >>>>> YKScheduler(); 
	call	YKScheduler
	mov	sp, bp
	pop	bp
	ret
L_YAKkernel_31:
	push	bp
	mov	bp, sp
	jmp	L_YAKkernel_32
L_YAKkernel_34:
	DB	"Scheduler",0xA,0
	ALIGN	2
YKScheduler:
	; >>>>> Line:	131
	; >>>>> void YKScheduler(){ 
	jmp	L_YAKkernel_35
L_YAKkernel_36:
	; >>>>> Line:	132
	; >>>>> printString("Scheduler\n"); 
	mov	ax, L_YAKkernel_34
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	133
	; >>>>> printTCB(YKReadyTasks); 
	push	word [YKReadyTasks]
	call	printTCB
	add	sp, 2
	; >>>>> Line:	135
	; >>>>> if (YKReadyTasks != YKCurrentTask){ 
	mov	ax, word [YKCurrentTask]
	cmp	ax, word [YKReadyTasks]
	je	L_YAKkernel_37
	; >>>>> Line:	137
	; >>>>> YKCurrentTask = YKReadyTasks; 
	mov	ax, word [YKReadyTasks]
	mov	word [YKCurrentTask], ax
	; >>>>> Line:	138
	; >>>>> YKDispatcher(); 
	call	YKDispatcher
L_YAKkernel_37:
	mov	sp, bp
	pop	bp
	ret
L_YAKkernel_35:
	push	bp
	mov	bp, sp
	jmp	L_YAKkernel_36
	ALIGN	2
YKDispatcher:
	; >>>>> Line:	143
	; >>>>> void YKDispatcher(){ 
	jmp	L_YAKkernel_39
L_YAKkernel_40:
	; >>>>> Line:	146
	; >>>>> SwitchContext(); 
	mov	si, word [YKCurrentTask]
	mov	ax, word [si]
	mov	word [bp-2], ax
	; >>>>> Line:	146
	; >>>>> SwitchContext(); 
	call	SwitchContext
	mov	sp, bp
	pop	bp
	ret
L_YAKkernel_39:
	push	bp
	mov	bp, sp
	push	cx
	jmp	L_YAKkernel_40
	ALIGN	2
L_YAKkernel_42:
	DW	0
L_YAKkernel_43:
	DB	0xA,"Tick ",0
	ALIGN	2
YKTickHandler:
	; >>>>> Line:	151
	; >>>>> void YKTickHandler(){ 
	jmp	L_YAKkernel_44
L_YAKkernel_45:
	; >>>>> Line:	155
	; >>>>> ++tickCount; 
	mov	ax, word [YKSuspendedTasks]
	mov	word [bp-2], ax
	; >>>>> Line:	155
	; >>>>> ++tickCount; 
	inc	word [L_YAKkernel_42]
	; >>>>> Line:	156
	; >>>>> printString("\nTick "); 
	mov	ax, L_YAKkernel_43
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	157
	; >>>>> printInt(tickCount); 
	push	word [L_YAKkernel_42]
	call	printInt
	add	sp, 2
	; >>>>> Line:	158
	; >>>>> printString("\n"); 
	mov	ax, (L_YAKkernel_30+24)
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	160
	; >>>>> while (currTC 
	jmp	L_YAKkernel_47
L_YAKkernel_46:
	; >>>>> Line:	161
	; >>>>> --currTCB->delayTicks; 
	mov	si, word [bp-2]
	add	si, 6
	dec	word [si]
	; >>>>> Line:	163
	; >>>>> if (currTCB->delayTicks == 0){ 
	mov	si, word [bp-2]
	add	si, 6
	mov	ax, word [si]
	test	ax, ax
	jne	L_YAKkernel_49
	; >>>>> Line:	165
	; >>>>> YKRemoveFromList(currTCB); 
	push	word [bp-2]
	call	YKRemoveFromList
	add	sp, 2
	; >>>>> Line:	166
	; >>>>> YKAddToReadyList(currTCB); 
	push	word [bp-2]
	call	YKAddToReadyList
	add	sp, 2
L_YAKkernel_49:
	; >>>>> Line:	168
	; >>>>> currTCB = currTCB->next; 
	mov	si, word [bp-2]
	add	si, 8
	mov	ax, word [si]
	mov	word [bp-2], ax
L_YAKkernel_47:
	mov	ax, word [bp-2]
	test	ax, ax
	jne	L_YAKkernel_46
L_YAKkernel_48:
	mov	sp, bp
	pop	bp
	ret
L_YAKkernel_44:
	push	bp
	mov	bp, sp
	push	cx
	jmp	L_YAKkernel_45
	ALIGN	2
YKAddToReadyList:
	; >>>>> Line:	174
	; >>>>> void YKAddToReadyList(TCBp newTask){ 
	jmp	L_YAKkernel_51
L_YAKkernel_52:
	; >>>>> Line:	178
	; >>>>> if (YKReadyTasks ==  0 ) 
	mov	si, word [bp+4]
	add	si, 4
	mov	ax, word [si]
	mov	word [bp-2], ax
	mov	ax, word [YKReadyTasks]
	mov	word [bp-4], ax
	; >>>>> Line:	178
	; >>>>> if (YKReadyTasks ==  0 ) 
	mov	ax, word [YKReadyTasks]
	test	ax, ax
	jne	L_YAKkernel_53
	; >>>>> Line:	179
	; >>>>> YKReadyTasks = newTask; 
	mov	ax, word [bp+4]
	mov	word [YKReadyTasks], ax
	jmp	L_YAKkernel_54
L_YAKkernel_53:
	; >>>>> Line:	181
	; >>>>> else if (YKReadyTasks->priority > priority){ 
	mov	si, word [YKReadyTasks]
	add	si, 4
	mov	ax, word [bp-2]
	cmp	ax, word [si]
	jge	L_YAKkernel_55
	; >>>>> Line:	182
	; >>>>> newTask->next = YKReadyTasks; 
	mov	si, word [bp+4]
	add	si, 8
	mov	ax, word [YKReadyTasks]
	mov	word [si], ax
	; >>>>> Line:	183
	; >>>>> YKReadyTasks = newTask; 
	mov	ax, word [bp+4]
	mov	word [YKReadyTasks], ax
	jmp	L_YAKkernel_56
L_YAKkernel_55:
	; >>>>> Line:	188
	; >>>>> while (taskListPtr->next !=  0  && taskListPtr->next->priority > 
	jmp	L_YAKkernel_58
L_YAKkernel_57:
	; >>>>> Line:	189
	; >>>>> taskListPtr = taskListPtr -> next; 
	mov	si, word [bp-4]
	add	si, 8
	mov	ax, word [si]
	mov	word [bp-4], ax
L_YAKkernel_58:
	mov	si, word [bp-4]
	add	si, 8
	mov	ax, word [si]
	test	ax, ax
	je	L_YAKkernel_60
	mov	si, word [bp-4]
	add	si, 8
	mov	si, word [si]
	add	si, 4
	mov	ax, word [bp-2]
	cmp	ax, word [si]
	jl	L_YAKkernel_57
L_YAKkernel_60:
L_YAKkernel_59:
	; >>>>> Line:	192
	; >>>>> newTask-> next = taskListPtr -> next; 
	mov	si, word [bp-4]
	add	si, 8
	mov	di, word [bp+4]
	add	di, 8
	mov	ax, word [si]
	mov	word [di], ax
	; >>>>> Line:	193
	; >>>>> taskListPtr->next = newTask; 
	mov	si, word [bp-4]
	add	si, 8
	mov	ax, word [bp+4]
	mov	word [si], ax
L_YAKkernel_56:
L_YAKkernel_54:
	mov	sp, bp
	pop	bp
	ret
L_YAKkernel_51:
	push	bp
	mov	bp, sp
	sub	sp, 4
	jmp	L_YAKkernel_52
	ALIGN	2
YKAddToSuspendedList:
	; >>>>> Line:	197
	; >>>>> void YKAddToSuspendedList(TCBp task){ 
	jmp	L_YAKkernel_62
L_YAKkernel_63:
	; >>>>> Line:	199
	; >>>>> } 
	mov	sp, bp
	pop	bp
	ret
L_YAKkernel_62:
	push	bp
	mov	bp, sp
	jmp	L_YAKkernel_63
	ALIGN	2
YKRemoveFromList:
	; >>>>> Line:	202
	; >>>>> void YKRemoveFromList(TCBp task){ 
	jmp	L_YAKkernel_65
L_YAKkernel_66:
	; >>>>> Line:	203
	; >>>>> if (task->next !=  0 ){ 
	mov	si, word [bp+4]
	add	si, 8
	mov	ax, word [si]
	test	ax, ax
	je	L_YAKkernel_67
	; >>>>> Line:	204
	; >>>>> task->next->prev = task->prev; 
	mov	si, word [bp+4]
	add	si, 10
	mov	di, word [bp+4]
	add	di, 8
	mov	di, word [di]
	add	di, 10
	mov	ax, word [si]
	mov	word [di], ax
L_YAKkernel_67:
	; >>>>> Line:	206
	; >>>>> if (task->prev !=  0 ){ 
	mov	si, word [bp+4]
	add	si, 10
	mov	ax, word [si]
	test	ax, ax
	je	L_YAKkernel_68
	; >>>>> Line:	207
	; >>>>> task->prev->next = task->next; 
	mov	si, word [bp+4]
	add	si, 8
	mov	di, word [bp+4]
	add	di, 10
	mov	di, word [di]
	add	di, 8
	mov	ax, word [si]
	mov	word [di], ax
L_YAKkernel_68:
	mov	sp, bp
	pop	bp
	ret
L_YAKkernel_65:
	push	bp
	mov	bp, sp
	jmp	L_YAKkernel_66
L_YAKkernel_75:
	DB	" ",0xA,0
L_YAKkernel_74:
	DB	"->",0
L_YAKkernel_73:
	DB	")",0
L_YAKkernel_72:
	DB	":0x",0
L_YAKkernel_71:
	DB	"/",0
L_YAKkernel_70:
	DB	"TCB(",0
	ALIGN	2
printTCB:
	; >>>>> Line:	212
	; >>>>> void printTCB(void* ptcb){ 
	jmp	L_YAKkernel_76
L_YAKkernel_77:
	; >>>>> Line:	215
	; >>>>> printString("TCB("); 
	mov	ax, word [bp+4]
	mov	word [bp-2], ax
	; >>>>> Line:	215
	; >>>>> printString("TCB("); 
	mov	ax, L_YAKkernel_70
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	216
	; >>>>> printInt(tcb->priority); 
	mov	si, word [bp-2]
	add	si, 4
	push	word [si]
	call	printInt
	add	sp, 2
	; >>>>> Line:	217
	; >>>>> printString("/"); 
	mov	ax, L_YAKkernel_71
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	218
	; >>>>> printInt(tcb->delayTicks); 
	mov	si, word [bp-2]
	add	si, 6
	push	word [si]
	call	printInt
	add	sp, 2
	; >>>>> Line:	219
	; >>>>> printString(":0x"); 
	mov	ax, L_YAKkernel_72
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	220
	; >>>>> printWo 
	mov	si, word [bp-2]
	push	word [si]
	call	printWord
	add	sp, 2
	; >>>>> Line:	221
	; >>>>> printString(")"); 
	mov	ax, L_YAKkernel_73
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	222
	; >>>>> if (tcb->next !=  0 ){ 
	mov	si, word [bp-2]
	add	si, 8
	mov	ax, word [si]
	test	ax, ax
	je	L_YAKkernel_78
	; >>>>> Line:	223
	; >>>>> printString("->"); 
	mov	ax, L_YAKkernel_74
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	224
	; >>>>> printTCB(tcb->next); 
	mov	si, word [bp-2]
	add	si, 8
	push	word [si]
	call	printTCB
	add	sp, 2
	jmp	L_YAKkernel_79
L_YAKkernel_78:
	; >>>>> Line:	227
	; >>>>> printString(" \n"); 
	mov	ax, L_YAKkernel_75
	push	ax
	call	printString
	add	sp, 2
L_YAKkernel_79:
	mov	sp, bp
	pop	bp
	ret
L_YAKkernel_76:
	push	bp
	mov	bp, sp
	push	cx
	jmp	L_YAKkernel_77
	ALIGN	2
YKCtxSwCount:
	TIMES	2 db 0
YKIdleCount:
	TIMES	2 db 0
YKCurrentTask:
	TIMES	2 db 0
YKReadyTasks:
	TIMES	2 db 0
YKSuspendedTasks:
	TIMES	2 db 0
YKAllTasks:
	TIMES	2 db 0
YKTCBs:
	TIMES	72 db 0
YKTCBMallocIndex:
	TIMES	2 db 0
IdleStack:
	TIMES	200 db 0
YKISRDepth:
	TIMES	2 db 0
; Generated by c86 (BYU-NASM) 5.1 (beta) from app.i
	CPU	8086
	ALIGN	2
	jmp	main	; Jump to program start
L_app_2:
	DB	"Starting kernel...",0xA,0
L_app_1:
	DB	"Creating task A...",0xA,0
	ALIGN	2
main:
	; >>>>> Line:	23
	; >>>>> { 
	jmp	L_app_3
L_app_4:
	; >>>>> Line:	24
	; >>>>> YKInitialize(); 
	call	YKInitialize
	; >>>>> Line:	26
	; >>>>> printString("Creating task A...\n"); 
	mov	ax, L_app_1
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	27
	; >>>>> YKNewTask(ATask, (void *)&AStk[ 256 ], 5); 
	mov	ax, 5
	push	ax
	mov	ax, (AStk+512)
	push	ax
	mov	ax, ATask
	push	ax
	call	YKNewTask
	add	sp, 6
	; >>>>> Line:	29
	; >>>>> printString("Starting kernel...\n"); 
	mov	ax, L_app_2
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	30
	; >>>>> YKRun(); 
	call	YKRun
	mov	sp, bp
	pop	bp
	ret
L_app_3:
	push	bp
	mov	bp, sp
	jmp	L_app_4
L_app_9:
	DB	"Task A is still running! Oh no! Task A was supposed to stop.",0xA,0
L_app_8:
	DB	"Creating task C...",0xA,0
L_app_7:
	DB	"Creating low priority task B...",0xA,0
L_app_6:
	DB	"Task A started!",0xA,0
	ALIGN	2
ATask:
	; >>>>> Line:	34
	; >>>>> { 
	jmp	L_app_10
L_app_11:
	; >>>>> Line:	35
	; >>>>> printString("Task A started!\n"); 
	mov	ax, L_app_6
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	37
	; >>>>> printString("Creating low priority task B...\n"); 
	mov	ax, L_app_7
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	38
	; >>>>> YKNewTask(BTask, (void *)&BStk[ 256 ], 7); 
	mov	ax, 7
	push	ax
	mov	ax, (BStk+512)
	push	ax
	mov	ax, BTask
	push	ax
	call	YKNewTask
	add	sp, 6
	; >>>>> Line:	40
	; >>>>>  
	mov	ax, L_app_8
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	41
	; >>>>> YKNewTask(CTask, (void *)&CStk[ 256 ], 2); 
	mov	ax, 2
	push	ax
	mov	ax, (CStk+512)
	push	ax
	mov	ax, CTask
	push	ax
	call	YKNewTask
	add	sp, 6
	; >>>>> Line:	43
	; >>>>> printString("Task A is still running! Oh no! Task A was supposed to stop.\n"); 
	mov	ax, L_app_9
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	44
	; >>>>> exit(0); 
	xor	al, al
	push	ax
	call	exit
	add	sp, 2
	mov	sp, bp
	pop	bp
	ret
L_app_10:
	push	bp
	mov	bp, sp
	jmp	L_app_11
L_app_13:
	DB	"Task B started! Oh no! Task B wasn't supposed to run.",0xA,0
	ALIGN	2
BTask:
	; >>>>> Line:	48
	; >>>>> { 
	jmp	L_app_14
L_app_15:
	; >>>>> Line:	49
	; >>>>> printString("Task B started! Oh no! Task B wasn't supposed to run.\n"); 
	mov	ax, L_app_13
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	50
	; >>>>> exit(0); 
	xor	al, al
	push	ax
	call	exit
	add	sp, 2
	mov	sp, bp
	pop	bp
	ret
L_app_14:
	push	bp
	mov	bp, sp
	jmp	L_app_15
L_app_19:
	DB	"Executing in task C.",0xA,0
L_app_18:
	DB	" context switches!",0xA,0
L_app_17:
	DB	"Task C started after ",0
	ALIGN	2
CTask:
	; >>>>> Line:	54
	; >>>>> { 
	jmp	L_app_20
L_app_21:
	; >>>>> Line:	58
	; >>>>> YKEnterMutex(); 
	call	YKEnterMutex
	; >>>>> Line:	59
	; >>>>> numCtxSwitches = YKCtxSwCount; 
	mov	ax, word [YKCtxSwCount]
	mov	word [bp-4], ax
	; >>>>> Line:	60
	; >>>>> YKExitMutex(); 
	call	YKExitMutex
	; >>>>> Line:	62
	; >>>>> printString("Task C started after "); 
	mov	ax, L_app_17
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	63
	; >>>>> printUInt(numCtxSwitches); 
	push	word [bp-4]
	call	printUInt
	add	sp, 2
	; >>>>> Line:	64
	; >>>>>  
	mov	ax, L_app_18
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	66
	; >>>>> while (1) 
	jmp	L_app_23
L_app_22:
	; >>>>> Line:	68
	; >>>>> printString("Executing in task C.\n"); 
	mov	ax, L_app_19
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	69
	; >>>>> for(count = 0; count < 5000; count++); 
	mov	word [bp-2], 0
	jmp	L_app_26
L_app_25:
L_app_28:
	inc	word [bp-2]
L_app_26:
	cmp	word [bp-2], 5000
	jl	L_app_25
L_app_27:
L_app_23:
	jmp	L_app_22
L_app_24:
	mov	sp, bp
	pop	bp
	ret
L_app_20:
	push	bp
	mov	bp, sp
	sub	sp, 4
	jmp	L_app_21
	ALIGN	2
AStk:
	TIMES	512 db 0
BStk:
	TIMES	512 db 0
CStk:
	TIMES	512 db 0
