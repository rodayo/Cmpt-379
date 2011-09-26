%{

#define		T_COMMENT					16

//Boolean conditional operators
#define		T_AND							10
#define		T_OR							45
#define		T_NOT							43
#define		T_TRUE						55
#define		T_FALSE						25

//Arithmetic conditional operators 
#define		T_EQ							22
#define		T_NEQ							41
#define		T_GEQ							27
#define		T_LEQ							34
#define		T_GT							28
#define		T_LT							37

//Arithmetic operators
#define		T_ASSIGN					11
#define		T_PLUS						46
#define		T_MINUS						38
#define		T_MOD							39
#define		T_MULT						40
#define		T_DIV							19
#define		T_LEFTSHIFT				33
#define		T_RIGHTSHIFT			49

//Identifiers and instantiations
#define		T_ID							58
#define		T_NEW							42
#define		T_VOID						56
#define		T_RETURN					48
#define		T_NULL						44

//3 Basic typesgithub
#define		T_BOOLTYPE				12
#define		T_INTTYPE					31
#define		T_STRINGTYPE			53

//5 Basic constants
#define		T_STRINGCONSTANT	54
#define		T_CHARCONSTANT		14
#define		T_INTCONSTANT			30
#define		T_BREAK						13
#define		T_DOT							20

//Brackets
#define		T_LPAREN					35
#define		T_RPAREN					50
#define		T_LCB							32
#define		T_RCB							47
#define		T_LSB							36
#define		T_RSB							51
#define		T_SEMICOLON				52

//Loops and ifs
#define		T_WHILE						57
#define		T_FOR							26
#define		T_IF							29
#define		T_ELSE						21

//Misc.
#define		T_EXTENDS					23
#define		T_EXTERN					24
#define		T_WHITESPACE			59
#define		T_CLASS						15
#define		T_COMMA						17
#define		T_CONTINUE				18


#include <iostream>
#include <string>

extern "C"
{
	int yylex(void);
	int yywrap(void);
}

using namespace std;

int glo_pos;
int glo_line;

string str_const;
string str_comment;

%}

D			[0-9]
L			[a-zA-Z_]
H			[a-fA-F0-9]

%s STR_LITERAL
%s TYPE_INST
%%

\/\/.*\n {
	str_comment = string(yytext);
	str_comment.erase(str_comment.end() - 1);
	
	glo_line++;
	return T_COMMENT;
}

\( { glo_pos += yyleng; return T_LPAREN; }
\) { glo_pos += yyleng; return T_RPAREN; }
\{ { glo_pos += yyleng; return T_LCB; }
\} { glo_pos += yyleng; return T_RCB; }
\[ { glo_pos += yyleng; return T_LSB; }
\] { glo_pos += yyleng; return T_RSB; }
,  { glo_pos += yyleng; return T_COMMA; }
;	 { glo_pos += yyleng; return T_SEMICOLON; }

"="  { glo_pos += yyleng; return T_ASSIGN; }
"+" { glo_pos += yyleng; return T_PLUS; }
"-"  { glo_pos += yyleng; return T_MINUS; }
"%"  { glo_pos += yyleng; return T_MOD; }
"*" { glo_pos += yyleng; return T_MULT; }
"/"  { glo_pos += yyleng; return T_DIV; }
"<<" { glo_pos += yyleng; return T_LEFTSHIFT; }
">>" { glo_pos += yyleng; return T_RIGHTSHIFT; }

"==" { glo_pos += yyleng; return T_EQ; }
"!=" { glo_pos += yyleng; return T_NEQ; }
">=" { glo_pos += yyleng; return T_GEQ; }
"<=" { glo_pos += yyleng; return T_LEQ; }
">"  { glo_pos += yyleng; return T_GT; }
"<"  { glo_pos += yyleng; return T_LT; }

"&&" { glo_pos += yyleng; return T_AND; }
"||" { glo_pos += yyleng; return T_OR; }
"!"  { glo_pos += yyleng; return T_NOT; }
true { glo_pos += yyleng; return T_TRUE; }
false { glo_pos += yyleng; return T_FALSE; }

while { glo_pos += yyleng; return T_WHILE; }
for { glo_pos += yyleng; return T_FOR; }
if { glo_pos += yyleng; return T_IF; }
else { glo_pos += yyleng; return T_ELSE; }


continue { glo_pos += yyleng; return T_CONTINUE; }
return { glo_pos += yyleng; return T_RETURN; }
extends { glo_pos += yyleng; return T_EXTENDS; }

extern {
	glo_pos += yyleng;
	return T_EXTERN;
}

(class|int|void|bool|string) {
	//A variable is being instantiated and so an identifier should be expected
	BEGIN TYPE_INST;
	glo_pos += yyleng;
	string tok_type (yytext);
	
	if (tok_type.compare("void") == 0)
		return T_VOID;
	else if (tok_type.compare("string") == 0)
		return T_STRINGTYPE;
	else if (tok_type.compare("int") == 0)
		return T_INTTYPE;
	else if (tok_type.compare("bool") == 0)
		return T_BOOLTYPE;
	else if (tok_type.compare("class") == 0)
		return T_CLASS;
}

	/*
		The state conditions basically mean that an IDENTIFIER can be used for
		a extern prototype, a class instantiation or a type instantiation.
	*/
[a-zA-Z_]+[a-zA-Z0-9_]* {
	BEGIN 0;
	glo_pos += yyleng;
	return T_ID;
}

\"(\\.|[^\\"]|\n)*\" {
	str_const = string(yytext);
	str_const = str_const.substr(1, str_const.length() - 2);
	
	//Find any invalid escape sequences
	for (int i = 0; i < str_const.length(); i++)
	{
		if (str_const[i] == '\\' && string("tvrnafb\\\"").find(str_const[i + 1]) == string::npos)
		{
			cerr << "Error: Unrecognized escape sequence in string constant" << endl;
			cerr << "Lexical error: line " << glo_line << ", position " << (glo_pos + i) << endl;
		}
		if (str_const[i] == '\n')
		{
			glo_line++;
			cerr << "Error: Newline in string constant" << endl;
			cerr << "Lexical error: line " << glo_line << ", position " << glo_pos + i << endl;
		}
	}
	return T_STRINGCONSTANT;
}

\".*(\"|\\\").*\" {
	cerr << "Error: unterminated string constant" << endl;
	cerr << "Lexical error: line " << glo_line << ", position " << glo_pos << endl;
}

'(\\.|[^\\'])*' {
	string strchar = string(yytext);
	strchar = strchar.substr(1, strchar.length() - 2);

	if (strchar.length() > 1 && strchar[0] != '\\')
	{
		cerr << "Error: char constant length is greater than one" << endl;
		cerr << "Lexical error: line " << glo_line << ", position " << glo_pos << endl;
	}
	else if (strchar[0] == '\\' && string("tvrnafb\\\"").find(strchar[1]) == string::npos)
	{
		cerr << "Error: Unrecognized escape sequence in character constant" << endl;
		cerr << "Lexical error: line " << glo_line << ", position " << glo_pos << endl;
	}
	else if (strchar.length() == 0)
	{
		cerr << "Error: char constant has zero width" << endl;
		cerr << "Lexical error: line " << glo_line << ", position " << glo_pos << endl;
	}
	return T_CHARCONSTANT;
}

(0[xX]){H}{1,8} {
	glo_pos += yyleng;
	return T_INTCONSTANT;
}

{D}+ {
	glo_pos += yyleng;
	double num = atol(yytext);
	
	if (num > 2147483647 || num < -2147483647)
	{
		cerr << "Error: integer value out of range" << endl;
		cerr << "Lexical error: line " << glo_line << ", position " << glo_pos - yyleng + 1 << endl;
	}
	
	return T_INTCONSTANT;
}

[ \n]* { 
	string strws = string(yytext);
	cout << "T_WHITESPACE ";

	for (int i = 0; i < strws.length(); i++)
	{
		if (strws[i] == '\n')
		{
			cout << "\\n";
			glo_line++;
		}
		else 
			cout << strws[i];
	}
	cout << endl;
}

%%

int main()
{
	glo_pos = glo_line = 1;
	int token;
	while (token = yylex())
	{
		switch (token)
		{
			case T_EXTERN:
				cout << "T_EXTERN " << yytext << endl;
				break;
			case T_CLASS:
				cout << "T_CLASS " << yytext << endl;
				break;
			case T_VOID:
				cout << "T_VOID " << yytext << endl;
				break;
			case T_STRINGTYPE:
				cout << "T_STRINGTYPE " << yytext << endl;
				break;
			case T_INTTYPE:
				cout << "T_INTTYPE " << yytext << endl;
				break;
			case T_BOOLTYPE:
				cout << "T_BOOLTYPE " << yytext << endl;
				break;
			case T_ID:
				cout << "T_ID " << yytext << endl;
				break;
			case T_RETURN:
				cout << "T_RETURN " << yytext << endl;
				break;
			case T_LPAREN:
				cout << "T_LPAREN (" << endl;
				break;
			case T_RPAREN:
				cout << "T_RPAREN )" << endl;
				break;
			case T_LCB:
				cout << "T_LCB {" << endl;
				break;
			case T_RCB:
				cout << "T_RCB }" << endl;
				break;
			case T_LSB:
				cout << "T_LSB [" << endl;
				break;
			case T_RSB:
				cout << "T_RSB ]" << endl;
				break;
			case T_COMMA:
				cout << "T_COMMA ," << endl;
				break;
			case T_ASSIGN:
				cout << "T_ASSIGN =" << endl;
				break;
			case T_PLUS:
				cout << "T_PLUS +" << endl;
				break;
			case T_MINUS:
				cout << "T_MINUS -" << endl;
				break;
			case T_MULT:
				cout << "T_MULT *" << endl;
				break;
			case T_DIV:
				cout << "T_DIV /" << endl;
				break;
			case T_MOD:
				cout << "T_MOD %" << endl;
				break;
			case T_LEFTSHIFT:
				cout << "T_LEFTSHIFT <<" << endl;
				break;
			case T_RIGHTSHIFT:
				cout << "T_RIGHTSHIFT >>" << endl;
				break;
			case T_EQ:
				cout << "T_EQ ==" << endl;
				break;
			case T_NEQ:
				cout << "T_NEQ !=" << endl;
				break;
			case T_GEQ:
				cout << "T_GEQ >=" << endl;
				break;
			case T_LEQ:
				cout << "T_LEQ <=" << endl;
				break;
			case T_GT:
				cout << "T_GT >" << endl;
				break;
			case T_LT:
				cout << "T_LT <" << endl;
				break;
			case T_AND:
				cout << "T_AND &&" << endl;
				break;
			case T_OR:
				cout << "T_OR ||" << endl;
				break;
			case T_NOT:
				cout << "T_NOT !" << endl;
				break;
			case T_TRUE:
				cout << "T_TRUE true" << endl;
				break;
			case T_FALSE:
				cout << "T_FALSE false" << endl;
				break;
			case T_WHILE:
				cout << "T_WHILE while" << endl;
				break;
			case T_FOR:
				cout << "T_FOR for" << endl;
				break;
			case T_IF:
				cout << "T_IF if" << endl;
				break;
			case T_ELSE:
				cout << "T_ELSE else" << endl;
				break;
			case T_SEMICOLON:
				cout << "T_SEMICOLON ;" << endl;
				break;
			case T_COMMENT:
				cout << "T_COMMENT " << str_comment << "\\n\n";
				break;
			case T_STRINGCONSTANT:
				cout << "T_STRINGCONSTANT " << str_const << endl;
				str_const.clear();
				break;
			case T_CHARCONSTANT:
				cout << "T_CHARCONSTANT " << yytext << endl;
				break;
			case T_INTCONSTANT:
				cout << "T_INTCONSTANT " << yytext << endl;
				break;
		}
	}
	return 0;
}

















