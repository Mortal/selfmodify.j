.method main
.args   1
.define linkptr = 0
.define callerspc = 1
.define callerslv = 2

// we want to keep tight control of the constant pool,
// so instead of using subroutines (aka methods), we call main.
// main checks the caller's pc to determine which subroutine is
// intended to be called. as a guide, the caller pushes an objref
// which indicates the subroutine intended to be called.
// (see comments below.) in the stack trace, whenever invokevirtual
// is called with an objref, we can see the value of caller's pc
// in the stack. this helps us to write the helper branching code
// right below.

// at pc 48 we intend to call GETPC
	iload 1
	bipush 48
	isub
	ifeq GETPC

// at pc 84 we intend to call REBASE
	iload 1
	bipush 84
	isub
	ifeq REBASE
	goto MAIN

// CONSTANT POOL - this code is never called. add ldc_w calls to
// manipulate the constant pool.
	//ldc_w 0x00010000
	//ldc_w 0x001000a7 // goto 16

// 110
GETPC:
	iload 1
	ireturn

// 120
REBASE:
	// we want the program counter to point into the stack of the caller
	iload 2 // get caller's lv (measured in words)
	bipush 3 iadd // add distance from lv to stack
	dup iadd dup iadd // multiply by 4 (convert to bytes)
	istore 1 // store as caller's pc

	// return the value that LV should hold
	iload 2
	bipush 1 iadd
	ireturn

MAIN:
// (1a) Call getpc to get the address of the line after this invokevirtual
	bipush 110 // objref
	invokevirtual main

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
	pop
// now our stack is clear

// construct new stack frame
	bipush 0 // lv - we get this from REBASE
	bipush 1 // caller's pc - default value for main
	bipush 0 // caller's lv - default value for main

// construct new method area
	//ldc_w 0xa7000036 ldc_w 0xff000500 // istore 0, nop, goto 5
	//ldc_w 0xac002a10 // bipush 42, nop, ireturn
	ldc_w -0x58FFFFCA ldc_w -0xFFFB00
	ldc_w -0x53FFD5F0

// rebase to move pc into the stack, calling the code we've just specified
// dynamically
	bipush 120 // objref
	invokevirtual main

// vim:syn=bytecode:
