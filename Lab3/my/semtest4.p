/*
 * semtest4.p : check variable declaration properties
 */
//&T-
semtest4;

var a,b : integer;
var c : boolean;

fun(a:integer) : integer;
begin
    var d, e : integer;
    var a: integer;     // error, a is redeclared (as parameter)
    var d : 25;         // error, d is redeclared (as local var.)
  
    c := a <> 10;   // ok, a is parameter
    c := b <= 10;   // ok, b is global var.
    c := d+1 >= 10; // ok, d is local var.

    c := f;         // error, f undeclared

end
end fun

// main program
begin

end
end semtest4

