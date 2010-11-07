// SELF-MODIFY
// Construct a method area on the stack and call the code

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
	ldc_w 0x0036 // istore 0, nop, nop // rebase returns the value of lv

	ldc_w 0x00b66e10 ldc_w 0xac00 // bipush 110 (objref)
	                              // invokevirtual getpc
	                              // ireturn, nopnop

// rebase to move pc into the stack, calling the code we've just specified
// dynamically
	bipush 120 // objref
	invokevirtual rebase

// vim:syn=bytecode:
