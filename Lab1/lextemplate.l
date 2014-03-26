%{
#define LIST               strcat(buf, yytext)
#define token(t)           {LIST; if (Opt_T) printf("<%s>\n", #t);}
#define tokenInteger(t, i) {LIST; if (Opt_T) printf("<%s: %d>\n", #t, i);}
#define tokenString(t, s)  {LIST; if (Opt_T) printf("<%s: %s>\n", #t, s);}
#define MAX_LINE_LENG      256

int Opt_S = 1;
int Opt_T = 1;
int linenum = 1;
char buf[MAX_LINE_LENG];
%}
letter  [a-zA-Z_]
digit   [0-9]
float   [0-9]+"."[0-9]*
space   [ \t]+

%Start COMMENT 
%%
"/*"            {ECHO; BEGIN(COMMENT);}
<COMMENT>.      {ECHO;}
<COMMENT>"*/"   {ECHO; BEGIN(INITIAL);}
"//".*          {ECHO;}

"("     {token('(');}
")"     {token(')');}
","     {token(',');}
";"     {token(';');}
":"     {token(':');}
"["     {token('[');}
"]"     {token(']');}


"+"     {token(+);}
"-"     {token(-);}
"*"     {token(*);}
"/"     {token(/);}
"mod"   {token(mod);}
":="    {token(:=);}
"<"     {token(<);}
"<="    {token(<=);}
"<>"    {token(<>);}
">="    {token(>=);}
">"     {token(>);}
"="     {token(=);}
"and"   {token(and);}
"or"    {token(or);}
"not"   {token(not);}

"array"     {token(KWarray);}
"begin"     {token(KWbegin);}
"boolean"   {token(KWboolean);}
"def"       {token(KWdef);}
"do"        {token(KWdo);}
"else"      {token(KWelse);}
"end"       {token(KWend);}
"false"     {token(KWfalse);}
"for"       {token(KWfor);}
"integer"   {token(KWinteger);}
"if"        {token(KWif);}
"of"        {token(KWof);}
"print"     {token(KWprint);}
"read"      {token(KWread);}
"real"      {token(KWreal);}
"string"    {token(KWstring);}
"then"      {token(KWthen);}
"to"        {token(KWto);}
"true"      {token(KWtrue);}
"return"    {token(KWreturn);}
"var"       {token(KWvar);}
"while"     {token(KWwhile);}
{letter}({letter}|{digit})*     {tokenString(id, yytext);}
{digit}*                        {tokenString(integer, yytext);}
{float}                         {tokenString(float, yytext);}
{float}(e|E)(\+|\-)?[0-9]*      {tokenString(scientific, yytext);}
"\"".*"\""                      {tokenString(string, yytext);}

\n      {
          LIST;
          if (Opt_S)
            printf("%d:%s", linenum, buf);
          linenum++;
          buf[0] = '\0';
        }
.       {}

%%
int main( int argc, char **argv ) {
  if( argc != 2 ) {
    fprintf( stderr, "Usage: ./scanner [filename]\n" );
    exit(0);
  }
	
  FILE *fp = fopen( argv[1], "r" );
  if( fp == NULL ) {
    fprintf( stderr, "Open file error\n" );
    exit(-1);
  }
	
  yyin = fp;

  yylex();

  exit(0);
}
