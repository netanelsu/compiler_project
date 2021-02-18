part 1 is the Syntax Analyzer mostly implemented with Yacc and Lex to create the Structure of the Language.

In order to Run this part 3 steps are required in your Linux Console:
1. lex compilation:  Lex Project1.l
2. Yacc compilation: YACC Project1.y
3. C compilation : cc -o OUT_FILE_NAME y.tab.c -ll -Ly
