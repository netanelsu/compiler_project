part 3 - 3AC code genrtor .
if sytax and semantic analayzer is Ok part3 generates a 3AC code.
including Short Circut Evaluation

In Order to run this in your Linux Console:
1. lex compilation:  Lex scanner.l
2. Yacc compilation: YACC Parsser.y
3. C compilation : cc -o OUT_FILE_NAME y.tab.c ast.c scope.c -ll -Ly
