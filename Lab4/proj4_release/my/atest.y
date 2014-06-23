test2.j;
.class public test2
.super java/lang/Object
.field public static _sc Ljava/util/Scanner;
.field public static a I
.field public static b Z
.field public static c F
.field public static d F
.field public static e F

.method public static main([Ljava/lang/String;)V
	.limit stack 100
	.limit local 100
	new java/util/Scanner
	dup
	getstatic java/lang/System/in Ljava/io/InputStream;
	invokespecial java/util/Scanner/<init>(Ljava/io/InputStream;)V
	putstatic test2/_sc Ljava/util/Scanner;
	ldc 3
	istore 1
	ldc 1.230000
	fstore 6
	ldc 1.230000
	ldc 3
	fstore 6
	getstatic java/lang/System/out Ljava/io/PrintStream;
	fload 6 ; local variable number f
	invokevirtual java/io/PrintStream/print(F)V
	getstatic java/lang/System/out Ljava/io/PrintStream;
	ldc "\n"
	invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
	ldc 3
	ldc 1.230000
	fstore 6
	getstatic java/lang/System/out Ljava/io/PrintStream;
	fload 6 ; local variable number f
	invokevirtual java/io/PrintStream/print(F)V
	getstatic java/lang/System/out Ljava/io/PrintStream;
	ldc "\n"
	invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
	ldc 1
	ldc 100
	fstore 6
	getstatic java/lang/System/out Ljava/io/PrintStream;
	fload 6 ; local variable number f
	invokevirtual java/io/PrintStream/print(F)V
	getstatic java/lang/System/out Ljava/io/PrintStream;
	ldc "\n"
	invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
	ldc 100
	ldc 17
	istore 5
	getstatic java/lang/System/out Ljava/io/PrintStream;
	iload 5 ; local variable number e
	invokevirtual java/io/PrintStream/print(I)V
	getstatic java/lang/System/out Ljava/io/PrintStream;
	ldc "\n"
	invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
	ldc 1.230000
	ldc 3
	fstore 6
	getstatic java/lang/System/out Ljava/io/PrintStream;
	fload 6 ; local variable number f
	invokevirtual java/io/PrintStream/print(F)V
	getstatic java/lang/System/out Ljava/io/PrintStream;
	ldc "\n"
	invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
	getstatic java/lang/System/out Ljava/io/PrintStream;
	getstatic java/lang/System/out Ljava/io/PrintStream;
	ldc "\n"
	invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
	return
.end method
