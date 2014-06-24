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
	getstatic java/lang/System/out Ljava/io/PrintStream;
imul
	invokevirtual java/io/PrintStream/print(I)V
	getstatic java/lang/System/out Ljava/io/PrintStream;
	ldc "\n"
	invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
	return
.end method
