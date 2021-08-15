/*
 * generated by Xtext 2.25.0
 */
lexer grammar InternalErDslLexer;

@header {
package org.xtext.unipampa.erdsl.parser.antlr.lexer;

// Hack: Use our own Lexer superclass by means of import. 
// Currently there is no other way to specify the superclass for the lexer.
import org.eclipse.xtext.parser.antlr.Lexer;
}

PartialOverlapped : ('P'|'p')('A'|'a')('R'|'r')('T'|'t')('I'|'i')('A'|'a')('L'|'l')'/'('O'|'o')('V'|'v')('E'|'e')('R'|'r')('L'|'l')('A'|'a')('P'|'p')('P'|'p')('E'|'e')('D'|'d');

PartialDisjoint : ('P'|'p')('A'|'a')('R'|'r')('T'|'t')('I'|'i')('A'|'a')('L'|'l')'/'('D'|'d')('I'|'i')('S'|'s')('J'|'j')('O'|'o')('I'|'i')('N'|'n')('T'|'t');

TotalOverlapped : ('T'|'t')('O'|'o')('T'|'t')('A'|'a')('L'|'l')'/'('O'|'o')('V'|'v')('E'|'e')('R'|'r')('L'|'l')('A'|'a')('P'|'p')('P'|'p')('E'|'e')('D'|'d');

LogicalSchema : ('L'|'l')('O'|'o')('G'|'g')('I'|'i')('C'|'c')('A'|'a')('L'|'l')' '('S'|'s')('C'|'c')('H'|'h')('E'|'e')('M'|'m')('A'|'a');

TotalDisjoint : ('T'|'t')('O'|'o')('T'|'t')('A'|'a')('L'|'l')'/'('D'|'d')('I'|'i')('S'|'s')('J'|'j')('O'|'o')('I'|'i')('N'|'n')('T'|'t');

Relationships : ('R'|'r')('E'|'e')('L'|'l')('A'|'a')('T'|'t')('I'|'i')('O'|'o')('N'|'n')('S'|'s')('H'|'h')('I'|'i')('P'|'p')('S'|'s');

IsIdentifier : ('I'|'i')('S'|'s')('I'|'i')('D'|'d')('E'|'e')('N'|'n')('T'|'t')('I'|'i')('F'|'f')('I'|'i')('E'|'e')('R'|'r');

PostgreSQL : ('P'|'p')('O'|'o')('S'|'s')('T'|'t')('G'|'g')('R'|'r')('E'|'e')('S'|'s')('Q'|'q')('L'|'l');

Entities : ('E'|'e')('N'|'n')('T'|'t')('I'|'i')('T'|'t')('I'|'i')('E'|'e')('S'|'s');

Generate : ('G'|'g')('E'|'e')('N'|'n')('E'|'e')('R'|'r')('A'|'a')('T'|'t')('E'|'e');

Datetime : ('D'|'d')('A'|'a')('T'|'t')('E'|'e')('T'|'t')('I'|'i')('M'|'m')('E'|'e');

Boolean : ('B'|'b')('O'|'o')('O'|'o')('L'|'l')('E'|'e')('A'|'a')('N'|'n');

Relates : ('R'|'r')('E'|'e')('L'|'l')('A'|'a')('T'|'t')('E'|'e')('S'|'s');

Domain : ('D'|'d')('O'|'o')('M'|'m')('A'|'a')('I'|'i')('N'|'n');

Double : ('D'|'d')('O'|'o')('U'|'u')('B'|'b')('L'|'l')('E'|'e');

String : ('S'|'s')('T'|'t')('R'|'r')('I'|'i')('N'|'n')('G'|'g');

LeftParenthesisDigitZeroColonDigitOneRightParenthesis : '(''0'':''1'')';

N : '(''0'':'('N'|'n')')';

LeftParenthesisDigitOneColonDigitOneRightParenthesis : '(''1'':''1'')';

N_1 : '(''1'':'('N'|'n')')';

MySQL : ('M'|'m')('Y'|'y')('S'|'s')('Q'|'q')('L'|'l');

Money : ('M'|'m')('O'|'o')('N'|'n')('E'|'e')('Y'|'y');

File : ('F'|'f')('I'|'i')('L'|'l')('E'|'e');

All : ('A'|'a')('L'|'l')('L'|'l');

Int : ('I'|'i')('N'|'n')('T'|'t');

Is : ('I'|'i')('S'|'s');

Comma : ',';

Semicolon : ';';

LeftSquareBracket : '[';

RightSquareBracket : ']';

LeftCurlyBracket : '{';

RightCurlyBracket : '}';

RULE_ID : '^'? ('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'_'|'0'..'9')*;

RULE_INT : ('0'..'9')+;

RULE_STRING : ('"' ('\\' .|~(('\\'|'"')))* '"'|'\'' ('\\' .|~(('\\'|'\'')))* '\'');

RULE_ML_COMMENT : '/*' ( options {greedy=false;} : . )*'*/';

RULE_SL_COMMENT : '//' ~(('\n'|'\r'))* ('\r'? '\n')?;

RULE_WS : (' '|'\t'|'\r'|'\n')+;

RULE_ANY_OTHER : .;
