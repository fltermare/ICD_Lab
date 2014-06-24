; test4.j
.class public test4
.super java/lang/Object
.field public static _sc Ljava/util/Scanner;

.method public static main([Ljava/lang/String;)V
	.limit stack 100
	.limit locals 100
	new java/util/Scanner
	dup
	getstatic java/lang/System/in Ljava/io/InputStream;
	invokespecial java/util/Scanner/<init>(Ljava/io/InputStream;)V
	putstatic test4/_sc Ljava/util/Scanner;
	ldc 1
	istore 1
Lbegin_0:
	iload 1
	sipush 10
	isub
	iflt Ltrue_1
	iconst_0
	goto Lfalse_1
Ltrue_1:
	iconst_1
Lfalse_1:
	ifeq Lexit_0
	ldc 1
	istore 2
Lbegin_2:
	iload 2
	sipush 10
	isub
	iflt Ltrue_3
	iconst_0
	goto Lfalse_3
Ltrue_3:
	iconst_1
Lfalse_3:
	ifeq Lexit_2
	getstatic java/lang/System/out Ljava/io/PrintStream;
	iload 1 ; local variable number i
	iload 2 ; local variable number k
imul
	invokevirtual java/io/PrintStream/print(I)V
	getstatic java/lang/System/out Ljava/io/PrintStream;
	ldc "\n"
	invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
	iload 2
	sipush 1
	iadd
	istore 2
	goto Lbegin_2
Lexit_2:
	iload 1
	sipush 1
	iadd
	istore 1
	goto Lbegin_0
Lexit_0:
	return
.end method
