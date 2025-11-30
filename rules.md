Parser Rules:

1. A parser will only start if one if it's start tokens matches the current token.
2. A parser will only stop if it completes fully or a 'break' is found
3. When a parser acts it effects the state and returns a int.

Ret:
0 -> the parser comsumed some input
1 -> first token didn't match any of the parsers start tokens
break -> first token is a 'break'
