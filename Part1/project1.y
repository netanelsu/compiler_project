%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
typedef struct node {
    char *token; 
    struct node *left;
    struct node *right;
} node;
node *makeNode(char *token, node *left, node *right);
void printTree(node *tree, int tab);
void printTabs(int numOfTabs);
int yyerror(char *err);
%}

%union
{
    char *string;
    struct node *node;
}
                        /*values*/
%token <string> ID FUNC PROC TRUE_VAL FALSE_VAL
%token <string> DECIMAL_INT_NUMBER HEX_INT_NUMBER REAL_NUMBER CHAR_VAL STRING_VAL
                        /*types*/
%token <string> CHAR INT REAL STRING INTP CHARP REALP BOOL VAR 

                        /*STATEMENT*/
%token <string> ELSE IF PLUS MINUS MULT DIV WHILE RETURN NONE NOT
%token <string> OP_EQ OP_OR OP_AND OP_GT OP_GE OP_LE OP_LT ASSIGN OP_NOT_EQ ADDRESS DEREFERENCE DER_ID

%type <string> type premitiveValue unaryOp
%type <node> s initial code function procedure args_Id args body declaration stmt  math_expr addressOf bodyproc
%type <node> expr elementOfExpr assignment funcarguments ifStmt Block nestedStmt  whileStmt returnStmt  longdeclaration
%type <node> Procstmt ProcifStmt ProcwhileStmt funcstmt Blockproc ProcnestedStmt

%right UNARY
%left OP_OR
%left OP_AND
%left OP_EQ
%left OP_GT OP_GE OP_LE OP_LT
%left PLUS MINUS
%left MULT DIV
%left OP_NOT_EQ
%%

s: initial {
        printTree($1,0);
    };
initial: code { $$ = makeNode("CODE", $1, NULL); };

code:function code{ $$ = makeNode("FUNC",$1, $2);}
    |function { $$ = makeNode("FUNC",$1, NULL);}
    |procedure code{ $$ = makeNode("PROC",$1, $2);}
    |procedure { $$ = makeNode("PROC",$1, NULL); };

/*_____________ procedure / function ________________*/

function: FUNC ID  '(' args ')' RETURN type '{' body returnStmt '}' {$$ = makeNode($2,makeNode("ARGS", $4,makeNode("RET",makeNode($7,NULL,NULL),NULL)),makeNode("BODY",$9,$10));};

procedure: PROC ID '(' args ')' '{' bodyproc '}' {$$ = makeNode($2,makeNode("ARGS", $4,NULL),makeNode("BODY",$7,NULL)); };


args : args_Id type ';' args { $$ = makeNode($2, $1, $4); }
     | args_Id type { $$ = makeNode($2, $1, NULL); }
     | { $$ = makeNode("NONE",NULL, NULL); };
     
	
	
args_Id : ID ':' { $$ = makeNode($1, NULL,NULL); }
        | ID ',' args_Id { $$ = makeNode($1, NULL, $3); };
        

type :BOOL { $$ = "BOOL"; }
    | CHAR { $$ = "CHAR"; } 
    | INT  { $$ = "INT"; }
    | REAL { $$ = "REAL"; }
    | INTP { $$ = "INT_PTR"; }
    | CHARP { $$ = "CHAR_PTR"; }
    | REALP { $$ = "REAL_PTR"; };


body : code declaration nestedStmt { $$ = makeNode("",$1,makeNode("",$2,$3)); }
    | declaration nestedStmt  {$$ = makeNode("",$1,$2);};


bodyproc : code declaration ProcnestedStmt { $$ = makeNode("",$1,makeNode("", $2, $3)); }
    | declaration ProcnestedStmt { $$ = makeNode("", $1 ,$2); };


declaration: VAR longdeclaration ':' type ';' declaration { $$ = makeNode($4,$2,$6);}
           | VAR longdeclaration ':' STRING '[' DECIMAL_INT_NUMBER ']' ';' declaration {$$ = makeNode("STRING",$2,$9);}
           | { $$ = NULL; };

longdeclaration : ID ',' longdeclaration {$$ = makeNode($1,NULL,$3);}
                | ID { $$ = makeNode($1, NULL, NULL); };
    


nestedStmt : stmt { $$ = $1; }
           | stmt nestedStmt   { $1->right = $2;$$ = $1;};
           | { $$ = NULL;};

ProcnestedStmt : Procstmt { $$ = $1; }
    | Procstmt ProcnestedStmt { $1->right = $2; $$ = $1; };
    | {$$ = NULL;};

Procstmt : assignment ';' {$$ = $1;}
    | funcstmt {$$=$1;}
    | ProcifStmt {$$=$1;}
    | ProcwhileStmt { $$ = $1;}
    | Blockproc {$$ = $1;}
    
stmt : assignment ';' {$$ = $1;}
    | funcstmt {$$=$1;}
    | ifStmt {$$=$1;}
    | whileStmt { $$ = $1;}
    | Block { $$ = $1;}
    
    

funcstmt : ID ASSIGN ID '(' funcarguments ')' ';' { $$ = makeNode($2,makeNode($1,NULL,makeNode($3,$5,NULL)),NULL); }
    | ID '(' funcarguments ')' ';' {$$ = makeNode($1,$3,NULL);};

funcarguments : { $$ = NULL; }
    | math_expr ',' funcarguments {$1->right=$3;$$=$1;}
    | math_expr{ $$ = $1; } ;


assignment : ID ASSIGN math_expr { $$ = makeNode($2,makeNode($1,NULL, $3), NULL);}
    | ID ASSIGN expr { $$ = makeNode($2,makeNode($1,NULL, $3), NULL);}
    | ID ASSIGN addressOf { $$ = makeNode($2,makeNode($1,NULL, $3),NULL);}
    | ID ASSIGN STRING_VAL {$$ = makeNode($2, makeNode($1, makeNode($3,NULL, NULL), NULL), NULL);}
    | ID '[' math_expr ']' ASSIGN CHAR_VAL {$$ = makeNode($5, makeNode($1, makeNode("[]",$3,NULL),makeNode($6,NULL,NULL)),NULL);}
    | ID '[' math_expr ']' ASSIGN ID {$$ = makeNode($5, makeNode($1, makeNode("[]",$3,NULL),makeNode($6,NULL,NULL)),NULL);};



ifStmt : IF '(' expr ')' nestedStmt { $$ = makeNode("IF",makeNode("",$3,makeNode("",$5,NULL)),NULL);}
       | IF '(' expr ')' nestedStmt ELSE nestedStmt { $$ = makeNode("IF-ELSE", makeNode("", $3, makeNode("", $5,$7)), NULL); };
 
ProcifStmt : IF '(' expr ')' Procstmt { $$ = makeNode("IF",$3,$5);}
    | IF '(' expr ')' Procstmt ELSE Procstmt { $$ = makeNode("IF-ELSE", makeNode("", $3, makeNode("", $5,$7)), NULL); };

whileStmt : WHILE '(' expr ')' stmt { $$ = makeNode($1, makeNode("",$3,makeNode("",$5,NULL)),NULL); };

ProcwhileStmt : WHILE '(' expr ')' Procstmt { $$ = makeNode($1, $3, $5); };


Block : '{' '}' {$$ = makeNode("BLOCK",NULL, NULL);}
    | '{' declaration nestedStmt returnStmt '}' { $$ = makeNode("BLOCK", makeNode("", $2, $3),$4); };
    | '{' declaration nestedStmt '}' { $$ = makeNode("BLOCK", $2, $3); };
    

Blockproc : '{' '}' {$$ = makeNode("BLOCK",NULL, NULL);}
    | '{' declaration ProcnestedStmt '}' { $$ = makeNode("BLOCK", makeNode("", $2, $3),NULL);};
    
   

math_expr : elementOfExpr { $$ = $1;} 
    | math_expr PLUS math_expr {$1->right = $3; $$ = makeNode($2, $1 ,NULL);}
    | math_expr MINUS math_expr {$1->right = $3; $$ = makeNode($2, $1 ,NULL);} 
    | math_expr MULT math_expr {$1->right = $3; $$ = makeNode($2, $1 ,NULL);} 
    | math_expr DIV math_expr {$1->right = $3; $$ = makeNode($2, $1 ,NULL);};

expr : elementOfExpr {$$ = $1;}
    | '(' expr ')' {$$ = makeNode("",$2, NULL);}
    | expr OP_EQ expr {$1->right = $3; $$ = makeNode($2, $1 ,NULL);} 
    | MULT '(' expr ')' {$$ = makeNode("*",$3, NULL);}
    | expr OP_AND expr {$1->right = $3; $$ = makeNode($2, $1 ,NULL);} 
    | expr OP_OR expr {$1->right = $3; $$ = makeNode($2, $1 ,NULL);} 
    | expr OP_GT expr {$1->right = $3; $$ = makeNode($2, $1 ,NULL);} 
    | expr OP_GE expr {$1->right = $3; $$ = makeNode($2, $1 ,NULL);} 
    | expr OP_LE expr {$1->right = $3; $$ = makeNode($2, $1 ,NULL);} 
    | expr OP_LT expr {$1->right = $3; $$ = makeNode($2, $1 ,NULL);} 
    | expr OP_NOT_EQ expr {$1->right = $3; $$ = makeNode($2, $1 ,NULL);} 
    | expr PLUS expr {$1->right = $3; $$ = makeNode($2, $1 ,NULL);}
    | expr MINUS expr {$1->right = $3; $$ = makeNode($2, $1 ,NULL);} 
    | expr MULT expr {$1->right = $3; $$ = makeNode($2, $1 ,NULL);} 
    | unaryOp expr %prec UNARY { $$ = makeNode($1, $2, NULL); }
    | expr DIV expr {$1->right = $3; $$ = makeNode($2, $1 ,NULL);}
    | addressOf { $$ = $1; };


elementOfExpr : premitiveValue {$$ = makeNode($1,NULL, NULL); }
    | '|' ID '|' { $$ = makeNode("STR_LEN", makeNode($2, NULL, NULL), NULL); };


premitiveValue : CHAR_VAL { $$ = $1; }
    | HEX_INT_NUMBER { $$ = $1; }
    | DECIMAL_INT_NUMBER {$$ = $1; }
    | REAL_NUMBER { $$ = $1; }
    | ID { $$ = $1; }
    | TRUE_VAL { $$ = $1;}
    | NONE { $$ = $1; }
    | DER_ID { $$ = $1; }
    | FALSE_VAL { $$ = $1;};

addressOf : ADDRESS ID { $$ = makeNode($1, makeNode($2, NULL, NULL), NULL); }
    | ADDRESS ID '[' expr ']' { $$ = makeNode($1, makeNode($2, makeNode("[]", $4, NULL), NULL), NULL); };
    | DEREFERENCE ID { $$ = makeNode($1, makeNode($2, NULL, NULL), NULL); };
    
returnStmt : RETURN math_expr ';' { $$ = makeNode("RET", $2, NULL); } ;
           | RETURN ID ';' {$$ = makeNode("RET", makeNode($2,NULL,NULL), NULL);};

unaryOp : PLUS { $$ = $1; }
    | MINUS { $$ = $1; }
    | NOT {$$ = $1;};

%%
#include "lex.yy.c"
int main()
{
    return yyparse();
}
node *makeNode(char *token, node *left, node *right) {
    node *newnode = (node*)malloc(sizeof(node));
    char *newstr = (char*)malloc(sizeof(token) + 1);
    strcpy(newstr, token);
    newnode->left = left;
    newnode->right = right;
    newnode->token = newstr;
    return newnode;
}

void printTree (node *tree, int tab){
    int nextTab = tab;
    if (strlen(tree->token) > 0) {
    printTabs(tab);
    printf ("(%s", tree->token);
    if (tree->left != NULL) {
    printf("\n");
    }
    }
    if (tree->left) {
    if (strlen(tree->token) == 0) {
    nextTab = tab - 1;
    }
    printTree(tree->left, nextTab + 1);
    if (strlen(tree->token) > 0) {
    printTabs(tab);
    }
    }
    if (strlen(tree->token) > 0) {
    printf (")\n");
    }
    if (tree->right) {
    printTree (tree->right, tab);
    }
}

void printTabs(int numOfTabs) {
    int i;
    for (i = 0; i < numOfTabs; i++) {
    printf ("\t");
    }
}

int yyerror(char *err) {
    int yydebug = 1;
    fflush(stdout);
    fprintf(stderr, "Error: %s at line %d\n", err, yylineno);
    fprintf(stderr, "does not accept '%s'\n", yytext);
    return 0;
}