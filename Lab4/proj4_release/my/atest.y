test1.j;
.class public test1
.super java/lang/Object
.method public static main([Ljava/lang/String;)V
	.limit stack 100
	.limit local 100
iconst_1
iconst_0
sipush 1234567
ldc 2.860000
getstatic java/lang/System/out Ljava/io/PrintStream;
	iload 1 ; local variable number a
invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
getstatic java/lang/System/out Ljava/io/PrintStream;
	ldc "\n"
invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
getstatic java/lang/System/out Ljava/io/PrintStream;
	iload 6 ; local variable number f
invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
getstatic java/lang/System/out Ljava/io/PrintStream;
	ldc "\n"
invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
getstatic java/lang/System/out Ljava/io/PrintStream;
	fload 7 ; local variable number g
invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
getstatic java/lang/System/out Ljava/io/PrintStream;
	ldc "\n"
invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
getstatic java/lang/System/out Ljava/io/PrintStream;
	ldc "hello world!" ; local variable number h
invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
getstatic java/lang/System/out Ljava/io/PrintStream;
	ldc "\n"
invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
	return
.end method
