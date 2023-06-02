%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>

	#include "synt.tab.h"
	#include "ts.h"
	#include "quads.h"
	#include "var_stack.h"
	#include "state_stack.h"

	extern int nb_ligne;
	extern int Col;
	extern int current_line_indent;
	extern int indent_level; 
	extern int state;
	extern int isNewline;
	extern YYSTYPE yylval;

	extern char stack[500][100];   
	extern int stack2[500];
	extern int top; 
	extern int top2;
	
    #define YY_USER_INIT { \
        BEGIN(INDENT); \
    }
%}	

%x INDENT
%s NORMAL

lettreM [A-Z]
lettre [a-zA-Z]
chiffre [0-9]
idf {lettreM}({lettre}|{chiffre})*
int ("("[+-][1-9]{chiffre}*")"|[1-9]{chiffre}*|0)
float ("("[+-][1-9]{chiffre}+"."{chiffre}*[1-9]")"|[1-9]{chiffre}+"."{chiffre}*[1-9]|{chiffre}"."{chiffre}*[1-9])
char "\'"."\'"
bool (true|false)
comment ("#".*\n)

%%

<NORMAL>{comment}		{Col = 1; nb_ligne++;}

<NORMAL>{idf}			{	
							isNewline = 0;
							Col = Col + yyleng;
							if (yyleng>8) { 
								printf("Erreur Lexical, ligne %d, colonne %d, IDF trop long \n ",nb_ligne, Col);
								printf("- La longueur d'un IDF doit etre entre 1 et 8 caracteres \n");
							}
							else {
								yylval.STR = strdup(yytext);
								return idf;
							}
						}
<NORMAL>{int}			{	
							isNewline = 0;
							Col = Col + yyleng;
							char *num = yytext;
							if (yytext[0] == '('){
								num = split_string(yytext, 1, strlen(yytext)-2);
							}
							if ((atoi(num)>= -32768) && (atoi(num)<=32767)){
								yylval.INT = atoi(num);
								return v_int;
							}
							else {
								printf("Erreur lexicale (ligne : %d , colonne: %d)", nb_ligne, Col);
								printf("- La valeur d'un entier doit etre -32768 et 32767 \n");
							}
						}
<NORMAL>{float} 		{
							isNewline = 0;
							char *num = yytext;
							if (yytext[0] == '('){
								num = split_string(yytext, 1, strlen(yytext)-2);
							}	
							yylval.FLOAT = atof(num);
							Col = Col + yyleng;
							return v_float;
						}
<NORMAL>{char}  		{
							isNewline = 0; 
							yylval.CHAR = yytext[1];
							Col = Col + yyleng; 
							return v_char;
						}
<NORMAL>{bool}			{
							if (strcmp(yytext, "true") == 0){
								yylval.BOOL = 1;
							}
							else{
								yylval.BOOL = 0;
							}
							Col = Col + yyleng;
							isNewline = 0; return v_bool;
						}

<INDENT>{comment}		{Col = 1; nb_ligne++;}
<INDENT>"    "   		{Col = Col + 4; current_line_indent++;}
<INDENT>"\t"     		{Col = Col + 4; current_line_indent++;}
<INDENT>"\n"     		{current_line_indent = 0; isNewline = 1; Col= 1; nb_ligne++; }
	
<INDENT><<EOF>> { 
					if (isNewline == 0){
						isNewline = 1;
						return newline;
					}
					if (indent_level == 0){
						yyterminate();
					}
					else{
						for (indent_level; indent_level > 0; indent_level--){
							unput('@');
						}						
					}
				}
<INDENT>"   "   { printf("Lexical Error, Line %d, Column %d, Incorrect number of spaces\n", nb_ligne, Col);}
<INDENT>"  "    { printf("Lexical Error, Line %d, Column %d, Incorrect number of spaces\n", nb_ligne, Col);}
<INDENT>" "     { printf("Lexical Error, Line %d, Column %d, Incorrect number of spaces\n", nb_ligne, Col);}
<INDENT>.       {
					state = 0;
					isNewline = 0;
					yyless(0);
					if (current_line_indent > indent_level) {
						indent_level++;
						return indent;
					} else if (current_line_indent < indent_level) {
						indent_level--;
						return dedent;
					} else {
						BEGIN(NORMAL);
					}
                }
<NORMAL>"\n"    {
					current_line_indent = 0;
					isNewline = 1;
					if (state == 0){
						Col= 1;
						nb_ligne++; 
						state = 1;
						yyless(0);
						return newline;
					} 
					else{
						BEGIN(INDENT);
					}
				}
<NORMAL>"@"		{ return dedent;}
<NORMAL><<EOF>> { 

					if (isNewline == 0){
						isNewline = 1;
						return newline;
					}
					if (indent_level == 0){
						yyterminate();
					}
					else{
						for (indent_level; indent_level > 0; indent_level--){
							unput('@');
						}						
					}

				}
<NORMAL>" "		{Col = Col + 1;}
<NORMAL>"\t"	{Col = Col + 4;}

<NORMAL>"int"         	{inserer(yytext, "Keyword", "", 0, 0, 1); Col = Col + yyleng; 
						isNewline = 0; return mc_int;}
<NORMAL>"float"         {inserer(yytext, "Keyword", "", 0, 0, 1); Col = Col + yyleng; 
						isNewline = 0; return mc_float;}
<NORMAL>"char"          {inserer(yytext, "Keyword", "", 0, 0, 1); Col = Col + yyleng; 
						isNewline = 0; return mc_char;}
<NORMAL>"bool"          {inserer(yytext, "Keyword", "", 0, 0, 1); Col = Col + yyleng; 
						isNewline = 0; return mc_bool;}
<NORMAL>"if"			{inserer(yytext, "Keyword", "", 0, 0, 1); Col = Col + yyleng; 
						isNewline = 0; return mc_if;}
<NORMAL>"else"			{inserer(yytext, "Keyword", "", 0, 0, 1); Col = Col + yyleng; 
						isNewline = 0; return mc_else;}
<NORMAL>"for"			{inserer(yytext, "Keyword", "", 0, 0, 1); Col = Col + yyleng; 
						isNewline = 0; return mc_for;}
<NORMAL>"in"			{inserer(yytext, "Keyword", "", 0, 0, 1); Col = Col + yyleng; 
						isNewline = 0; return mc_in;}
<NORMAL>"range"			{inserer(yytext, "Keyword", "", 0, 0, 1); Col = Col + yyleng; 
						isNewline = 0; return mc_range;}
<NORMAL>"while"			{inserer(yytext, "Keyword", "", 0, 0, 1); Col = Col + yyleng; 
						isNewline = 0; return mc_while;}
<NORMAL>"import"        {inserer(yytext, "Keyword", "", 0, 0, 1); Col = Col + yyleng; 
						isNewline = 0; return mc_import;}
<NORMAL>"as"            {inserer(yytext, "Keyword", "", 0, 0, 1); Col = Col + yyleng; 
						isNewline = 0; return mc_as;}
<NORMAL>"numpy"         {inserer(yytext, "Keyword", "", 0, 0, 1); Col = Col + yyleng; 
						isNewline = 0; return mc_numpy;}
<NORMAL>"cv2"           {inserer(yytext, "Keyword", "", 0, 0, 1); Col = Col + yyleng; 
						isNewline = 0; return mc_cv2;}
<NORMAL>"imread"        {inserer(yytext, "Keyword", "", 0, 0, 1); Col = Col + yyleng; 
						isNewline = 0; return mc_imread;}
<NORMAL>"imwrite"       {inserer(yytext, "Keyword", "", 0, 0, 1); Col = Col + yyleng; 
						isNewline = 0; return mc_imwrite;}
<NORMAL>"jpg"       {inserer(yytext, "Keyword", "", 0, 0, 1); Col = Col + yyleng; 
						isNewline = 0; return mc_jpg;}						
<NORMAL>"png"       {inserer(yytext, "Keyword", "", 0, 0, 1); Col = Col + yyleng; 
						isNewline = 0; return mc_png;}

<NORMAL>"matplotlib.pyplot"     {inserer(yytext, "Keyword", "", 0, 0, 1); Col = Col + yyleng; 
						isNewline = 0; return mc_matplotlib;}						

<NORMAL>">"				{inserer(yytext, "Separator", "", 0, 0, 2); Col = Col + yyleng; 
						isNewline = 0; return g;}
<NORMAL>"<"				{inserer(yytext, "Separator", "", 0, 0, 2); Col = Col + yyleng; 
						isNewline = 0; return l;}
<NORMAL>">="			{inserer(yytext, "Separator", "", 0, 0, 2); Col = Col + yyleng; 
						isNewline = 0; return ge;}
<NORMAL>"<="			{inserer(yytext, "Separator", "", 0, 0, 2); Col = Col + yyleng; 
						isNewline = 0; return le;}
<NORMAL>"=="			{inserer(yytext, "Separator", "", 0, 0, 2); Col = Col + yyleng; 
						isNewline = 0; return eq;}
<NORMAL>"!="			{inserer(yytext, "Separator", "", 0, 0, 2); Col = Col + yyleng; 
						isNewline = 0; return dif;}
<NORMAL>"+"				{inserer(yytext, "Separator", "", 0, 0, 2); Col = Col + yyleng; 
						isNewline = 0; return add;}				  
<NORMAL>"-"				{inserer(yytext, "Separator", "", 0, 0, 2); Col = Col + yyleng; 
						isNewline = 0; return sub;}
<NORMAL>"*"				{inserer(yytext, "Separator", "", 0, 0, 2); Col = Col + yyleng; 
						isNewline = 0; return mul;}
<NORMAL>"/"				{inserer(yytext, "Separator", "", 0, 0, 2); Col = Col + yyleng; 
						isNewline = 0; return divv;}
<NORMAL>"="				{inserer(yytext, "Separator", "", 0, 0, 2); Col = Col + yyleng; 
						isNewline = 0; return aff;}
<NORMAL>","				{inserer(yytext, "Separator", "", 0, 0, 2); Col = Col + yyleng; 
						isNewline = 0; return vrg;}
<NORMAL>"["				{inserer(yytext, "Separator", "", 0, 0, 2); Col = Col + yyleng; 
						isNewline = 0; return lb;}
<NORMAL>"]"				{inserer(yytext, "Separator", "", 0, 0, 2); Col = Col + yyleng; 
						isNewline = 0; return rb;}
<NORMAL>"("				{inserer(yytext, "Separator", "", 0, 0, 2); Col = Col + yyleng; 
						isNewline = 0; return lp;}
<NORMAL>")"				{inserer(yytext, "Separator", "", 0, 0, 2); Col = Col + yyleng; 
						isNewline = 0; return rp;}
<NORMAL>":"				{inserer(yytext, "Separator", "", 0, 0, 2); Col = Col + yyleng; 
						isNewline = 0; return dd;}
<NORMAL>"and"			{inserer(yytext, "Separator", "", 0, 0, 2); Col = Col + yyleng; 
						isNewline = 0; return and;}
<NORMAL>"or"			{inserer(yytext, "Separator", "", 0, 0, 2); Col = Col + yyleng; 
						isNewline = 0; return or;}
<NORMAL>"not"			{inserer(yytext, "Separator", "", 0, 0, 2); Col = Col + yyleng; 
						isNewline = 0; return not;}
<NORMAL>"."			    {inserer(yytext, "Separator", "", 0, 0, 2); Col = Col + yyleng; 
						isNewline = 0; return point;}
<NORMAL>"'"			    {inserer(yytext, "Separator", "", 0, 0, 2); Col = Col + yyleng; 
						isNewline = 0; return tf;}						


<NORMAL>. 		{
					printf("Lexical Error, Line %d, Column %d, Unrecognized lexical entity '%s'\n", nb_ligne, Col, yytext);
					return err;
				}
%%
