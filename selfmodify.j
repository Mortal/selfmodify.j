// SELF-MODIFY
// Construct a method area on the stack and call the code
// static method area = 197 bytes = 50 words
// constant pool = 25 words
// dynamic method area = 20 words

.method getpc
.args   1
	iload 1
	ireturn

.method rebase
.args   1
	// we want the program counter to point into the stack of the caller
	iload 2 // get caller's lv (measured in words)
	bipush 3 iadd // add distance from lv to stack
	dup iadd dup iadd // multiply by 4 (convert to bytes)
	istore 1 // store as caller's pc

	// return the value that LV should hold
	iload 2
	bipush 1 iadd
	ireturn

.method main
.args   1
.define linkptr = 0
.define callerspc = 1
.define callerslv = 2

// (1a) Call getpc to get the address of the line after this invokevirtual
	bipush 110 // objref
	invokevirtual getpc

// (1b) add number of operations until after the ireturn below
	bipush 15
	iadd

// (1c) Store this value as the caller's pc
	istore callerspc

// (2) get our LV by subtracting some words from the address of the "callers
// pc" cell
	iload linkptr // points to address of "callers pc"
	bipush callerspc // index of "callers pc" rel to our lv
	isub // now points to our lv
	istore callerslv // set callers lv to be our lv

// (3) now that caller's lv and caller's pc are set, return
	bipush 0
	ireturn

// (4) ireturn goes to here
// stack contains return value from above (0)
// construct new stack frame
	bipush 1 // caller's pc - default value for main
	bipush 0 // caller's lv - default value for main

// construct new method area
// 0
	ldc_w 0x0036 // istore 0, nop, nop // rebase returns the value of lv
// 4
	ldc_w 0

// 8
	ldc_w 0x01360110 // bipush 1 istore 1 (n)
// C
	ldc_w 0

	ldc_w 20 // constant 5
	pop

// 10
while:
	ldc_w 0x050013 // ldc_w 5 (k), nop
// 14
	ldc_w 0
// 18
	ldc_w 0x01100115 // iload 1 bipush 1
// 1C
	ldc_w 0
// 20
	ldc_w 0x01365960 // iadd dup istore 1 // ++n

// 24
	ldc_w 0
// 28
	    // 0xDF009964 // isub ifeq (endwhile)
	ldc_w -0x20FF669C // isub ifeq (endwhile)
// 2C
	ldc_w 0

// 30
	ldc_w 0x7f100115 // iload 1, bipush 127
// 34
	ldc_w 0
// 38
	ldc_w 0x36c45960 // iadd dup wide istore
// 3C
	ldc_w 0x1001 // 0x0110
// 40
	ldc_w 0
// 44
	ldc_w 0x15cf // wide iload
// 48
	ldc_w 0xff7f // 0x7FFF
// 4C
	ldc_w 0
// 50
	ldc_w 0xc0ff9b // iflt (while)

// 54
	ldc_w 0
// 58
	ldc_w 0x0115 // iload 1

// 5C
	ldc_w 0
// 60
	ldc_w 0
// 64
while2:
	ldc_w 0x36c45900 // nop, dup, wide istore
// 68
	ldc_w 0x8000 // 0x0080
// 6C
	ldc_w 0
// 70
	ldc_w 0
// 74
	ldc_w 0x36c4ff10 // bipush -1, wide istore
// 78
	ldc_w 0xFF7F // 0x7FFF
// 7C
	ldc_w 0
// 80
	ldc_w 0x59600115 // iload 1, iadd, dup
// 84
	ldc_w 0
// 88
	ldc_w 0x050013 // ldc_w 5 (k), nop
// 8C
	ldc_w 0
// 90
	ldc_w 0x06009b64 // isub, iflt 0x06
// 94
	ldc_w 0
// 98
	ldc_w 0xeaffa7 // goto 0xFFEA
// 9C
	ldc_w 0
// 100
endwhile2:
	ldc_w 0xc5ffa7 // goto 0xFFC5

// 104
	ldc_w 0

// 108
endwhile:
	ldc_w 0x00b66e10 ldc_w 0xac00 // bipush 110 (objref)
	                              // invokevirtual getpc
	                              // ireturn, nopnop

// rebase to move pc into the stack, calling the code we've just specified
// dynamically
	bipush 120 // objref
	invokevirtual rebase

//	bipush 1
//	istore 1 // n
//while3:
//	ldc_w 20 // k
//	iload 1 // n
//	bipush 1 iadd dup istore 1 // ++n
//	isub
//	ifeq endwhile // if (k-n==0) break;
//
//	iload 1 // n
//	bipush 127
//	iadd
//	dup
//	istore 0x7FFF
//	iload 0x7FFF // argument overwritten
//	iflt while
//
//	iload 1 // n
//while4:
//	dup
//	istore 0x7FFF
//	bipush -1
//	istore 0x7FFF // argument overwritten
//
//	iload 1 // n
//	iadd
//	dup // m+=n
//	ldc_w 20 // k
//	isub
//	iflt endwhile2
//	goto while2
//
//endwhile4:
//	goto while
//
//endwhile3:

// vim:syn=bytecode:
