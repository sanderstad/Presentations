// TenantDSL.g4
// Language specification for the SQL Server tenant deployment DSL.
// This grammar is the authoritative design document.
// The PowerShell parser in src/Invoke-Parse.ps1 implements this grammar rule for rule.
//
// If you want to generate a parser from this grammar (e.g. for a C# or Java target):
//   java -jar antlr-4.13.2-complete.jar -Dlanguage=CSharp TenantDSL.g4

grammar TenantDSL;

// -- Parser rules ---------------------------------------------------------------
// -- The parser string of symbols to determine its grammatical structure
// -- according to a formal grammar
file
    : tenantBlock+ EOF
    ;

tenantBlock
    : 'tenant' STRING '{' property+ '}'
    ;

property
    : ID '=' value
    ;

value
    : STRING
    | NUMBER
    | list
    ;

list
    : '[' (STRING (',' STRING)*)? ']'
    ;

// -- Lexer rules ----------------------------------------------------------------
// -- Converts a sequence of characters into a sequence of tokens that
// -- represent basic syntactic units like keywords, operators and identiefiers

STRING
    : '"' (~["\r\n\\] | '\\' .)* '"'
    ;

NUMBER
    : [0-9]+
    ;

ID
    : [a-zA-Z_][a-zA-Z0-9_\-]*
    ;

WS
    : [ \t\r\n]+ -> skip
    ;

LINE_COMMENT
    : '//' ~[\r\n]* -> skip
    ;
