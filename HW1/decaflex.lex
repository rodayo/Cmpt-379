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

int pos;
int line;
string str_const;
%}

T_AND 				&&
T_OR					||
T_NOT					!
T_TRUE				true
T_FALSE				false

T_EQ					==
T_NEQ					!=
T_GEQ					>=
T_LEQ					<=
T_GT					>
T_LT					<

T_ASSIGN			=
T_INTTYPE			int

T_INTCONSTANT [0-9]+|0x[0-9a-fA-F]+

%s STR_LITERAL
%s TYPE_INST
%%

[ \n]* { 
	if (*yytext = '\n')
		pos = 0;
	else
		pos += yyleng;
		
	return T_WHITESPACE; 
}
\( { pos++; return T_LPAREN; }
\) { pos++; return T_RPAREN; }
\{ { pos++; return T_LCB; }
\} { pos++; return T_RCB; }
\[ { pos++; return T_LSB; }
\] { pos++; return T_RSB; }
;	 { pos++; return T_SEMICOLON; }

extern {
	pos += yyleng;
	return T_EXTERN;
}

(int|void|bool) {
	//A variable is being instantiated and so an identifier should be expected
	BEGIN TYPE_INST;
	
	string tok_type (yytext);
	if (tok_type.compare("void") == 0)
	{
		pos += yyleng;
		return T_VOID;
	}
	else if (tok_type.compare("int") == 0)
	{
		pos += yyleng;
		return T_INTTYPE;
	}
	else if (tok_type.compare("bool") == 0)
	{
		pos += yyleng;
		return T_BOOLTYPE;
	}
}

	/*
		The state conditions basically mean that an IDENTIFIER can be used for
		a extern prototype, a class instantiation or a type instantiation.
	*/
<TYPE_INST>[a-zA-Z_]+[a-zA-Z0-9_]* {
	BEGIN 0;
	pos += yyleng;
	return T_ID;
}

\" {
	BEGIN STR_LITERAL;
}

<STR_LITERAL>[^\\]\" {
	BEGIN 0;
	return T_STRINGCONSTANT;
}

<STR_LITERAL>([^\"].)* {
	string str_const (yytext);
	/*If the user is trying to use an escape sequence make sure they're doing it right
		and scald them accordingly.
	*/
	cout << yytext << endl;
	for (int i = 0; i < str_const.length(); i++)
	{
		//TODO: for some reason a '\' is detected even when it's not present at all
		if (str_const[i] = '\\')
		{
			cout << "char " << i << " " << str_const[i] << endl;
			if(string("tvrafb\\\"").find(str_const[i + 1]) == string::npos)
			{
				cerr << "Error: Unrecognized escape sequence in string constant" << endl;
				cerr << "Lexical error: line " << yylineno << ", position " << (pos + i) << endl;
				yywrap();
			}
		}
		else if (str_const[i] == '\n')
		{
			cerr << "Error: Newline in string constant" << endl;
			cerr << "Lexical error: line " << yylineno << ", position " << pos << endl;
			yywrap();
		}
		else
		{
			str_const += *yytext;
		}
	}
}


	/* The state conditions basically mean that an identifier
		 should be expected next\
	*/
<INITIAL>class {
	BEGIN TYPE_INST;
	pos += yyleng;
	return T_CLASS;
}

%%

int main()
{
	pos = line = 1;
	int token;
	while (token = yylex())
	{
		switch (token)
		{
			case T_WHITESPACE:
				cout << "T_WHITESPACE ";
				while(*yytext != '\0')
				{
					if (*yytext == '\n')
						cout << "\\n";
					else 
						cout << " ";
					
					*yytext++;
				}
				cout << endl;
				break;
			case T_EXTERN:
				cout << "T_EXTERN " << yytext << endl;
				break;
			case T_VOID:
				cout << "T_VOID " << yytext << endl;
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
			case T_LPAREN:
				cout << "T_LPAREN (" << endl;
				break;
			case T_RPAREN:
				cout << "T_RPAREN )" << endl;
				break;
			case T_SEMICOLON:
				cout << "T_SEMICOLON ;" << endl;
				break;
			case T_STRINGCONSTANT:
				cout << "T_STRINGCONSTANT " << str_const << endl;
				str_const.clear();
				break;
		}
	}
	return 0;
}


















