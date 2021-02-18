part 2 - semantic Analayzer Mostly implemented in c .
check the language constraints and required rules. 

In Order to run this in your Linux Console:
1. lex compilation:  Lex scanner.l
2. Yacc compilation: YACC Parsser.y
3. C compilation : cc -o OUT_FILE_NAME y.tab.c ast.c scope.c -ll -Ly
