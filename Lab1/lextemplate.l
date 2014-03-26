%{
#define LIST               strcat(buf, yytext)
#define token(t)           {LIST; if (Opt_T) printf("<%s>\n", #t);}
#define tokenInteger(t, i) {LIST; if (Opt_T) printf("<%s: %d>\n", #t, i);}
#define tokenString(t, s)  {LIST; if (Opt_T) printf("<%s: %s>\n", #t, s);}
#define MAX_LINE_LENG      256

int Opt_S = 1;
int Opt_T = 1;
int Opt_C = 1;
int linenum = 1;
char buf[MAX_LINE_LENG];
%}
letter  [a-zA-Z_]
digit   [0-9]
float   [0-9]+"."[0-9]*
space   [ \t]+

%Start COMMENT STRING ERROR
%%
<INITIAL>"/*"       {Opt_C = 0; LIST; BEGIN(COMMENT);}
<INITIAL>"//"       {Opt_C = 2; LIST; BEGIN(COMMENT);} 
<COMMENT>[^\n]      {LIST;} 
<COMMENT>"\n"       {
                    LIST;
                    if (Opt_S)
                        printf("%d: %s", linenum, buf);
                    if (Opt_C == 2) {
                        BEGIN(INITIAL);
                        Opt_C = 1;
                    }
                    linenum++;
                    buf[0] = '\0';
                    }

<COMMENT>"*/"       {Opt_C = 1; LIST; BEGIN(INITIAL);}

<INITIAL>"("|")"|","|";"|":"|"["|"]" {LIST; if (Opt_T) printf("<%s>\n",yytext);}

<INITIAL>"+"     {token(+);}
<INITIAL>"-"     {token(-);}
<INITIAL>"*"     {token(*);}
<INITIAL>"/"     {token(/);}
<INITIAL>"mod"   {token(mod);}
<INITIAL>":="    {token(:=);}
<INITIAL>"<"     {token(<);}
<INITIAL>"<="    {token(<=);}
<INITIAL>"<>"    {token(<>);}
<INITIAL>">="    {token(>=);}
<INITIAL>">"     {token(>);}
<INITIAL>"="     {token(=);}
<INITIAL>"and"   {token(and);}
<INITIAL>"or"    {token(or);}
<INITIAL>"not"   {token(not);}
 
<INITIAL>"array"     {token(KWarray);}
<INITIAL>"begin"     {token(KWbegin);}
<INITIAL>"boolean"   {token(KWboolean);}
<INITIAL>"def"       {token(KWdef);}
<INITIAL>"do"        {token(KWdo);}
<INITIAL>"else"      {token(KWelse);}
<INITIAL>"end"       {token(KWend);}
<INITIAL>"false"     {token(KWfalse);}
<INITIAL>"for"       {token(KWfor);}
<INITIAL>"integer"   {token(KWinteger);}
<INITIAL>"if"        {token(KWif);}
<INITIAL>"of"        {token(KWof);}
<INITIAL>"print"     {token(KWprint);}
<INITIAL>"read"      {token(KWread);}
<INITIAL>"real"      {token(KWreal);}
<INITIAL>"string"    {token(KWstring);}
<INITIAL>"then"      {token(KWthen);}
<INITIAL>"to"        {token(KWto);}
<INITIAL>"true"      {token(KWtrue);}
<INITIAL>"return"    {token(KWreturn);}
<INITIAL>"var"       {token(KWvar);}
<INITIAL>"while"     {token(KWwhile);}

<INITIAL>{letter}({letter}|{digit})*     {tokenString(id, yytext);}
<INITIAL>0|([1-9]{digit}*)               {tokenString(integer, yytext);}
<INITIAL>0{digit}{1,7}                   {tokenString(oct_integer, yytext);}
<INITIAL>{float}                         {tokenString(float, yytext);}
<INITIAL>({float}|(0|([1-9]{digit}*)))(e|E)(\+|\-)?[0-9]*      {tokenString(scientific, yytext);}

<INITIAL>"\""           {LIST; if (Opt_T) printf("<string: "); BEGIN(STRING);} 
<STRING>[^\"]*          {LIST; if (Opt_T) printf("%s",yytext);}
<STRING>"\"\""          {LIST; if (Opt_T) printf("\"");}
<STRING>"\""            {LIST; if (Opt_T) printf(">\n"); BEGIN INITIAL;}

<INITIAL>"//&S+"    {
                    Opt_S = 1;
                    Opt_C = 2;
                    LIST;
                    BEGIN(COMMENT);
                    }
<INITIAL>"//&S-"    {
                    Opt_S = 0;
                    Opt_C = 2;
                    LIST;
                    BEGIN(COMMENT);
                    }
<INITIAL>"//&T+"    {
                    Opt_T = 1;
                    Opt_C = 2;
                    LIST;
                    BEGIN(COMMENT);
                    }
<INITIAL>"//&T-"    {
                    Opt_T = 0;
                    Opt_C = 2;
                    LIST;
                    BEGIN(COMMENT);
                    }

<INITIAL>\n         {
                    LIST;
                    if (Opt_S)
                        printf("%d: %s", linenum, buf);
                    linenum++;
                    buf[0] = '\0';
                    }
<INITIAL>[ \t]*   {LIST;}
<INITIAL>.        {printf("error at line %d: bad character \"%s\"\n", linenum, yytext); BEGIN(ERROR);}
<ERROR>(.|"\n")*  {;}

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
