grammar hpl;

prog: stmt*;

// expression

exp:
	'#'? Identifier			# varExpression
	| ';'					# emptyExpression
	| literalExp			# literalExpression
	| LBrace exp RBrace		# braceExpression
	| Identifier Dot exp	# memberExpression
	| exp '[' exp ']'		# indexExpression
	| Sub exp				# negativeExpression
	| exp (Mul | Div) exp	# multiplyExpression
	| exp IDiv exp			# intDivExpression
	| exp Mod exp			# modularExpression
	| exp (Add | Sub) exp	# addExpression
	| exp (
		Neq
		| Equ
		| Smaller
		| Larger
		| SmallerOrEqu
		| LargerOrEqu
		| Like
	) exp							# compareExpression
	| exp And exp					# andExpression
	| exp Or exp					# orExpression
	| exp Assign exp				# assignExpression
	| exp LBrace commaExps? RBrace	# callExpression
	| defExp						# definitionExpression; // for easy lambda

defExp: def;

commaExps: exp (Comma exp)*;

literalExp:
	StringLiteral		# leString
	| FloatLiteral		# leFloat
	| DecLiteral		# leInt
	| dateLiteral		# leDate
	| arrayLiteral		# leArray
	| pointerLiteral	# lePointer
	| (True | False)	# leBool;

dateLiteral: '[' datePart ']';
DateSep: '-' | '/';
yearSep: '年' | DateSep;
monthSep: '月' | DateSep;
daySep: '日' | DateSep;
hourSep: '\u65f6' | DateSep | ':';
minuteSep: '分' | DateSep | ':';
secondSep: '秒' | DateSep | ':';
ZeroStartedDateNum: '0' [0-9];
dateNum: ZeroStartedDateNum | DecLiteral;
datePart: // MMP
	DecLiteral (
		yearSep (
			dateNum (
				monthSep (
					dateNum (
						daySep (
							dateNum (
								hourSep (
									dateNum (
										minuteSep (
											dateNum secondSep?
										)
									)?
								)?
							)?
						)?
					)?
				)?
			)?
		)?
	)?;

arrayLiteral: '{' commaExps? '}';
pointerLiteral: '&' exp;

// definition

typeInfo:
	baseType												# tBase
	| typeInfo '[' DecLiteral? ']'							# tArray
	| typeInfo Array '[' DecLiteral (Comma DecLiteral)* ']'	# tArray
	| '*' typeInfo											# tPointer
	| typeInfo '指针'										# tPointer
	| typeInfo '引用'										# tRef
	| '&' typeInfo											# tRef;

typedIdentifier: Identifier typeInfo;

def: varDef | functionDef | dllImportDef | packageDef;

varDef: (Global | Package)? Static? Var typedIdentifier (
		Assign exp
	)?;

functionDef:
	Public? Function Identifier (LBrace functionParam? RBrace)? typeInfo stmt* FunctionEnd;
functionParam: typedIdentifier (Comma typedIdentifier)*;

dllImportDef:
	DllImport Identifier (LBrace functionParam? RBrace)? typeInfo DllFrom (
		Identifier
		| StringLiteral
	) (Dot Identifier)?;

packageDef: Package Identifier;

useDef: Use Identifier (Item arrayLiteral)? (As Identifier)?;

// statement
bracePair: LBrace RBrace;

stmt:
	ifStmt
	| whileStmt
	| forStmt
	| foriStmt
	| breakStmt
	| continueStmt
	| returnStmt
	| expStmt;

expStmt: exp;

// HPL: modified syntax
ifStmt: ifPart elsePart? endIfPart?;

ifPart: If LBrace exp RBrace exp*;
elsePart: Else bracePair? exp*;
endIfPart: IfEnd bracePair?;

whileStmt: While LBrace exp? RBrace exp* WhileEnd bracePair?;

forStmt:
	For LBrace DecLiteral Comma DecLiteral Comma DecLiteral (
		Comma Identifier
	)? RBrace exp* ForEnd bracePair?;

foriStmt:
	ForI LBrace DecLiteral (Comma Identifier)? RBrace exp* ForIEnd bracePair?;

breakStmt: Break bracePair?;
continueStmt: Continue bracePair?;
returnStmt: Return (LBrace exp? RBrace | exp)?;

baseType:
	Any
	| Byte
	| Int
	| Short
	| Long
	| Float
	| Double
	| Bool
	| Date
	| String
	| ByteArray
	| FuncPtr;

// base type

Any: '通用型' | 'any';
Byte: '字节型' | 'byte';
Int: '整数型' | 'int';
Short: '短整数型' | 'short';
Long: '长整数型' | 'long';
Float: '小数型' | 'float';
Double: '双精度小数型' | 'double';
Bool: '逻辑型' | 'bool';
Date: '日期型' | 'date';
String: '文本型' | 'string';
ByteArray: '字节集' | 'buffer';
FuncPtr: '子程序指针' | 'funcptr';

LBrace: '\uff08' | '(';
RBrace: '\uff09' | ')';
Comma: ',' | '\uff0c';
Dot: '.' | '\uff0e' | '\u3002';

If: '如果' | '如果真' | '判断' | 'if';
// HPL: 如果真 的行为与 如果 一致
Else: '否则' | 'else';
// HPL: EPL没有else
IfEnd: '好了' | 'endif';
// HPL: 也没有endif
While: '判断循环首' | 'while';
WhileEnd: '判断循环尾' | 'endwhile';
DoWhile: '循环判断首' | 'do';
DoWhileEnd: '循环判断尾' | 'enddo';
For: '变量循环首' | 'for';
ForEnd: '变量循环尾' | 'endfor';
ForI: '计次循环首' | 'foreach';
ForIEnd: '计次循环尾' | 'endforeach';
Continue: '到循环尾' | 'continue';
Break: '跳出循环' | 'break';
Return: '返回' | 'return';
// arthmethic

Mul: '*' | '\u00d7';
Div: '/' | '\uff0f' | '\u00f7';
IDiv: '\\';
// Emmmm.... Kirikiri TPV Javascript?😕
Mod: '%' | '\uff05' | 'mod';
Add: '+' | '\uff0b';
Sub: '-' | '\uff0d';
// HPL: also Neg

// compare

fragment ZhEqu: '\uff1d';
fragment ZhSmall: '\uff1c';
fragment ZhLarge: '\uff1e';

Equ: '==' | ZhEqu ZhEqu;
Assign: '=' | ZhEqu;
Neq: '!=' | '\uff01' ZhEqu | '\u2260' | ZhSmall ZhLarge | '<>';
Smaller: '<' | ZhSmall;
Larger: '>' | ZhLarge;
SmallerOrEqu: '<=' | ZhSmall ZhEqu | '\u2264' | '\u2266';
LargerOrEqu: '>=' | ZhLarge ZhEqu | '\u2265' | '\u2267';
Like: '?=' | '\u2248' | '\uff1f' ZhEqu;

// logic

And: '&&' | 'and' | '且';
Or: '||' | 'or' | '或';

Public: '公开' | 'public';
Function: '子程序' | '子程序头' | '子程序名' | '函数' | 'function';
FunctionEnd: '子程序尾' | '函数尾' | 'functionend';
Array: '数组' | 'array';
Ref: '传址' | 'ref';

Global: '全局' | 'global';
Static: '静态' | 'static';
Var: '变量' | 'var';

// 库函数 示例（参数）返回值类型 来自 'user32.dll'.GetWindowLongA
DllImport: '库函数' | 'dll';

DllFrom: '来自' | 'from';

Package: '程序集' | 'package';

Use: '使用' | 'use'; // HPL: js style import
Item: '项目' | 'item';
As: '作为' | 'as';

Class: '类'|'class';
Extends:'基于'|'extends';

// literal
True: '是' | 'true' | '真';
False: '否' | 'false' | '假';

StringLiteral:
	'\u2018' ~[\u2019]* '\u2019'
	| '\u201c' ~[\u201d]* '\u201d'
	| '"' ~["]* '"'
	| '\'' ~[']* '\'';

fragment HexChar: [0-9a-zA-Z];
fragment HexCharNoZero: [1-9a-zA-Z];

DecLiteral: [1-9][0-9]*;
//HexLiteral: '0' [xX] HexChar+; OctLiteral: [1-7][0-7]*;

fragment FloatDecimalI: '0' | [1-9][0-9]*;
fragment FloatDecimalF: [0-9]*;

FloatLiteral:
	FloatDecimalI ('.' FloatDecimalF)? ([eE] [+-]? FloatDecimalI)?;

Identifier: [_\p{L}] [_\p{L}\p{N}]*;
LineComment: ('※' | '//') ~[\r\n\u2028\u2029]* -> channel(HIDDEN);
Space: [\p{Z}\r\n] -> channel(HIDDEN);
