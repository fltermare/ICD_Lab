/**
 * test.p: simple P language example
 */
//&T-
test;

var a: integer;		// global variable                                                      
var ac,ar,ct : array 2 to 3 of integer;

foo( a, b: integer ): integer;
begin
	begin
		var endif: integer;
		var a : array 2 to 3 of integer;
		return a*b;
	end
end
end foo

foo( a, b: integer ; a,b: array 2 to 3 of array 1 to 4 of integer ): integer;
begin
	var endif: integer;	
	return a*b;
end
end foo

foo( a , b: integer ; a,bcm,cc: array 2 to 3 of array 1 to 4 of integer ; abc : real ; a : string ; a : boolean );
begin
	var endif: integer;	
	return a*b;
end
end foo

foo();
begin
end
end foo

foo():array 2 to 3 of array 2 to 3 of array 2 to 3 of integer;
begin
end
end foo

// main block
begin
	A := B + C ;
	C := 2 * 4 ;
	print foo(2*4,3);
	print 2 * 4;
	print A * B;
	print A;
	print A[2][3];
	print foo(A[2]);
	print foo(foo(foo(A[2][3][4])));
	print 2;
	print true;
	print "hel""lo";
	print "hel""lo\n";
	
	begin
		A := A[-2*3];
		A := A[2*3];
		A[2*5] := 02;
		a := 2; 
		b := 3; 
		b := -52.3 + -5.4e+10;
		c := 52.4353454 ;
	end

	print 1+2*(3+4);
	print true;
	print -foo(true,foo(A[2]),false);
	A := foo(true,4,C*F);
	
	a := -2 ;
	a := -01*-4+5;
	a := 02 * 04;
	a := 02 * 04;
	b := true and not false ;
	
	if true+2 and false-true = true mod 2 then
	end if
	
	if a=b then 
	end if
	
	if 02=02 then 
	end if
	
	if 02=02 then
	else
		if 02=02 then
		a := 2;
			if 02=02 then
			a := 2;
			end if
		end if
	end if
	
	if -foo(-2,4,foo(A[2]),-a) <> -b*4 mod -123 then 
		print "test\n";
		print -foo(2,4);
	end if 
	
	while (a > b) do
	return 3*5 ;
	print "true false";
	end do
	
	for id :=0 to 10 do
	if  true and not false then
		print (a[5][6]);
	else
		foo(0+5);
	end if
	end do
	
end
end test


