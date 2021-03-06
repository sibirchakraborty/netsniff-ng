/*
 * netsniff-ng - the packet sniffing beast
 * By Daniel Borkmann <daniel@netsniff-ng.org>
 * Copyright 2012 Daniel Borkmann <dborkma@tik.ee.ethz.ch>,
 * Swiss federal institute of technology (ETH Zurich)
 * Subject to the GPL, version 2.
 */

/* lex-func-prefix: yy */

%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#include "bpf_parser.tab.h"
#include "xmalloc.h"

extern void yyerror(const char *);

%}

%option align
%option nounput
%option noyywrap
%option noreject
%option 8bit
%option caseless
%option noinput
%option nodefault

digit		[0-9]
digit_s		[1-9]
digit_n		[0]
bindigit	[0-1]
bindigit_b	[b]
hex		[a-fA-F0-9]
hex_x		[x]

number_dec	{digit_n}|{digit_s}{digit}*
number_oct	{digit_n}{digit}+
number_hex	{digit_n}{hex_x}{hex}+
number_bin	{digit_n}{bindigit_b}{bindigit}+

label_s		[a-zA-Z_]
label_me	[a-zA-Z0-9_]
label		{label_s}{label_me}+

%%

"ldb"		{ return OP_LDB; }
"ldh"		{ return OP_LDH; }
"ld"		{ return OP_LD; }
"ldx"		{ return OP_LDX; }
"ldxb"		{ return OP_LDXB; }
"st"		{ return OP_ST; }
"stx"		{ return OP_STX; }
"jmp"|"ja"	{ return OP_JMP; }
"jeq"		{ return OP_JEQ; }
"jgt"		{ return OP_JGT; }
"jge"		{ return OP_JGE; }
"jset"		{ return OP_JSET; }
"add"		{ return OP_ADD; }
"sub"		{ return OP_SUB; }
"mul"		{ return OP_MUL; }
"div"		{ return OP_DIV; }
"mod"		{ return OP_MOD; }
"neg"		{ return OP_NEG; }
"and"		{ return OP_AND; }
"xor"		{ return OP_XOR; }
"or"		{ return OP_OR; }
"lsh"		{ return OP_LSH; }
"rsh"		{ return OP_RSH; }
"ret"		{ return OP_RET; }
"tax"		{ return OP_TAX; }
"txa"		{ return OP_TXA; }
"len"|"pktlen"	{ return K_PKT_LEN; }
"pto"|"proto"	{ return K_PROTO; }
"type"		{ return K_TYPE; }
"ifx"|"ifidx"	{ return K_IFIDX; }
"nla"		{ return K_NLATTR; }
"nlan"		{ return K_NLATTR_NEST; }
"mark"		{ return K_MARK; }
"que"|"queue"	{ return K_QUEUE; }
"hat"|"hatype"	{ return K_HATYPE; }
"rxh"|"rxhash"	{ return K_RXHASH; }
"cpu"		{ return K_CPU; }

":"		{ return ':'; }
","		{ return ','; }
"#"		{ return '#'; }
"["		{ return '['; }
"]"		{ return ']'; }
"("		{ return '('; }
")"		{ return ')'; }
"x"		{ return 'x'; }
"a"		{ return 'a'; }
"+"		{ return '+'; }
"M"		{ return 'M'; }
"*"		{ return '*'; }
"&"		{ return '&'; }

{number_hex}	{ yylval.number = strtoul(yytext, NULL, 16);
		  return number_hex; }

{number_dec}	{ yylval.number = strtol(yytext, NULL, 10);
		  return number_dec; }

{number_oct}	{ yylval.number = strtol(yytext, NULL, 8);
		  return number_oct; }

{number_bin}	{ yylval.number = strtol(yytext + 2, NULL, 2);
		  return number_bin; }

{label}		{ yylval.label = xstrdup(yytext);
		  return label; }

"/*"([^\*]|\*[^/])*"*/" { /* NOP */ }
";"[^\n]*	{/* NOP */}
"\n"		{ yylineno++; }
[ \t]+		{/* NOP */ }
.		{ printf("Unknown character '%s'", yytext);
		  yyerror("lex Unknown character"); }

%%
