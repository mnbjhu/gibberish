keyword select;
keyword from;
keyword delete;

token NUM = "[0-9]+";
token WHITESPACE = "\s+";
token IDENT = "[_a-zA-Z]+";
token COLON = ":";
token COMMA = ",";
token SEMI = ";";

parser target = IDENT | NUM;
parser table = IDENT;

parser select_stmt = SELECT + target.sep_by(COMMA) + FROM + table;
parser delete_stmt = DELETE + FROM + IDENT;

parser _stmt = delete_stmt | select_stmt;
parser root = _stmt
  .sep_by(SEMI)
  .skip(WHITESPACE)
