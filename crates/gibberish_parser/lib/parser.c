#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>

#ifdef _WIN32
#define EXPORT __declspec(dllexport)
#else
#define EXPORT __attribute__((visibility("default")))
#endif

typedef struct {
  uint32_t kind;
  uint32_t _padding;
  size_t start;
  size_t end;
} Token;

typedef struct {
  Token *data;
  size_t len;
  size_t cap;
} TokenVec;

typedef struct {
  uint32_t kind;
  uint32_t id;
} Expected;

typedef struct {
  Expected *data;
  size_t len;
  size_t cap;
} ExpectedVec;

typedef struct {
  uint32_t *data;
  size_t len;
  size_t cap;
} SkippedVec;

typedef struct Node Node;
typedef struct ParserState ParserState;

typedef struct {
  Node *data;
  size_t len;
  size_t cap;
} NodeVec;

struct Node {
  uint32_t kind;
  uint32_t group_kind;
  union {
    Token tok;
    NodeVec group;
    ExpectedVec missing;
    TokenVec unexpected;
  } as;
};

typedef bool (*PeakFunc)(ParserState *);

typedef struct {
  PeakFunc *data;
  size_t len;
  size_t cap;
} BreakStack;

struct ParserState {
  TokenVec tokens;
  NodeVec stack;
  size_t offset;
  BreakStack breaks;
  SkippedVec skipped;
};

typedef struct {
  char *data;
  size_t len;
  size_t offset;
  size_t group_offset;
} LexerState;

void vec_push(TokenVec *v, Token value) {
  if (v->len == v->cap) {
    size_t new_cap = v->cap ? v->cap * 2 : 4;
    void *new_data = realloc(v->data, new_cap * sizeof *v->data);
    if (!new_data) {
      abort();
    }
    v->data = new_data;
    v->cap = new_cap;
  }
  v->data[v->len++] = value;
}

static inline TokenVec token_vec_new(void) {
  return (TokenVec){.data = NULL, .len = 0, .cap = 0};
}

static inline void token_vec_push(TokenVec *v, Token value) {
  if (v->len == v->cap) {
    size_t new_cap = v->cap ? v->cap * 2 : 4;
    void *new_data = realloc(v->data, new_cap * sizeof *v->data);
    if (!new_data)
      abort();
    v->data = (Token *)new_data;
    v->cap = new_cap;
  }
  v->data[v->len++] = value;
}

static inline bool token_vec_pop(TokenVec *v, Token *out) {
  if (v->len == 0)
    return false;
  Token value = v->data[--v->len];
  if (out)
    *out = value;
  return true;
}

/* ---------------- ExpectedVec ---------------- */

static inline ExpectedVec expected_vec_new(void) {
  return (ExpectedVec){.data = NULL, .len = 0, .cap = 0};
}

static inline void expected_vec_push(ExpectedVec *v, Expected value) {
  if (v->len == v->cap) {
    size_t new_cap = v->cap ? v->cap * 2 : 4;
    void *new_data = realloc(v->data, new_cap * sizeof *v->data);
    if (!new_data)
      abort();
    v->data = (Expected *)new_data;
    v->cap = new_cap;
  }
  v->data[v->len++] = value;
}

static inline bool expected_vec_pop(ExpectedVec *v, Expected *out) {
  if (v->len == 0)
    return false;
  Expected value = v->data[--v->len];
  if (out)
    *out = value;
  return true;
}

/* ---------------- SkippedVec (uint32_t) ---------------- */

static inline SkippedVec skipped_vec_new(void) {
  return (SkippedVec){.data = NULL, .len = 0, .cap = 0};
}

static inline void skipped_vec_push(SkippedVec *v, uint32_t value) {
  if (v->len == v->cap) {
    size_t new_cap = v->cap ? v->cap * 2 : 4;
    void *new_data = realloc(v->data, new_cap * sizeof *v->data);
    if (!new_data)
      abort();
    v->data = (uint32_t *)new_data;
    v->cap = new_cap;
  }
  v->data[v->len++] = value;
}

static inline bool skipped_vec_pop(SkippedVec *v, uint32_t *out) {
  if (v->len == 0)
    return false;
  uint32_t value = v->data[--v->len];
  if (out)
    *out = value;
  return true;
}

/* ---------------- BreakStack ---------------- */

static inline BreakStack break_stack_new(void) {
  return (BreakStack){.data = NULL, .len = 0, .cap = 0};
}

static inline void break_stack_push(BreakStack *v, PeakFunc value) {
  if (v->len == v->cap) {
    size_t new_cap = v->cap ? v->cap * 2 : 4;
    void *new_data = realloc(v->data, new_cap * sizeof *v->data);
    if (!new_data)
      abort();
    v->data = (PeakFunc *)new_data;
    v->cap = new_cap;
  }
  v->data[v->len++] = value;
}

static inline bool break_stack_pop(BreakStack *v, PeakFunc *out) {
  if (v->len == 0)
    return false;
  PeakFunc value = v->data[--v->len];
  if (out)
    *out = value;
  return true;
}

/* ---------------- NodeVec ---------------- */

static inline NodeVec node_vec_new(void) {
  return (NodeVec){.data = NULL, .len = 0, .cap = 0};
}

static inline void node_vec_push(NodeVec *v, Node value) {
  if (v->len == v->cap) {
    size_t new_cap = v->cap ? v->cap * 2 : 4;
    void *new_data = realloc(v->data, new_cap * sizeof *v->data);
    if (!new_data)
      abort();
    v->data = (Node *)new_data;
    v->cap = new_cap;
  }
  v->data[v->len++] = value;
}

static inline bool node_vec_pop(NodeVec *v, Node *out) {
  if (v->len == 0)
    return false;
  Node value = v->data[--v->len];
  if (out)
    *out = value;
  return true;
}

static inline bool skipped_vec_contains(const SkippedVec *v, uint32_t value) {
  for (size_t i = 0; i < v->len; i++) {
    if (v->data[i] == value) {
      return true;
    }
  }
  return false;
}

static inline bool skipped_vec_remove(SkippedVec *v, uint32_t value) {
  for (size_t i = 0; i < v->len; i++) {
    if (v->data[i] == value) {
      for (size_t j = i + 1; j < v->len; j++) {
        v->data[j - 1] = v->data[j];
      }
      v->len--;
      return true;
    }
  }
  return false;
}

static inline Node new_token_node(Token token) {
  Node new = {.kind = 0, .as.tok = token};
  return new;
}

static inline Node new_group_node(uint32_t name) {
  NodeVec children = node_vec_new();
  Node new = {.kind = 1, .group_kind = name, .as.group = children};
  return new;
}

static inline Node new_unexpected_node(Token token) {
  TokenVec children = token_vec_new();
  token_vec_push(&children, token);
  Node new = {.kind = 2, .as.unexpected = children};
  return new;
}

static inline Node new_missing_node(ExpectedVec expected) {
  Node new = {.kind = 3, .as.missing = expected};
  return new;
}

static inline Node new_skipped_node(Token token) {
  Node new = {.kind = 4, .as.tok = token};
  return new;
}

static inline Token current_token(ParserState *state) {
  return state->tokens.data[state->offset];
}

static inline uint32_t current_kind(ParserState *state) {
  return state->tokens.data[state->offset].kind;
}

static inline Node *current_node(ParserState *state) {
  size_t last = state->stack.len - 1;
  return &state->stack.data[last];
}

static inline void bump(ParserState *state) {
  Token current = current_token(state);
  state->offset += 1;
  Node *current_group = current_node(state);
  node_vec_push(&current_group->as.group, new_token_node(current));
}

static inline void bump_skipped(ParserState *state) {
  Token current = current_token(state);
  state->offset += 1;
  Node *current_group = current_node(state);
  node_vec_push(&current_group->as.group, new_skipped_node(current));
}

static inline void bump_err(ParserState *state) {
  Token current = current_token(state);
  state->offset += 1;
  Node *current_group = current_node(state);
  size_t group_len = current_group->as.group.len;
  if (group_len != 0) {
    size_t last = group_len - 1;
    Node *last_elem = &current_group->as.group.data[last];
    if (last_elem->kind == 2) {
      token_vec_push(&last_elem->as.unexpected, current);
      return;
    }
  }
  node_vec_push(&current_group->as.group, new_unexpected_node(current));
}

static inline void enter_group(ParserState *state, uint32_t name) {
  node_vec_push(&state->stack, new_group_node(name));
}

static inline void exit_group(ParserState *state, uint32_t name) {
  Node node;
  bool popped = node_vec_pop(&state->stack, &node);
  if (popped) {
    Node *current_group = current_node(state);
    node_vec_push(&current_group->as.group, node);
  } else {
    exit(1);
  }
}

static inline bool skip(ParserState *state, uint32_t token) {
  if (skipped_vec_contains(&state->skipped, token)) {
    return false;
  } else {
    skipped_vec_push(&state->skipped, token);
    return true;
  }
}

static inline bool unskip(ParserState *state, uint32_t token) {
  if (skipped_vec_contains(&state->skipped, token)) {
    skipped_vec_remove(&state->skipped, token);
    return true;
  } else {
    return false;
  }
}

static inline void missing(ParserState *state, ExpectedVec expected) {
  if (expected.len != 0) {
    Node *current = current_node(state);
    node_vec_push(&current->as.group, new_missing_node(expected));
  }
}

static const Expected EXPECTED[] = {
    {.kind = 0, .id = 1},
};

static inline ExpectedVec get_expected() {
  Expected *data = malloc(1 * sizeof(Expected));
  memcpy(data, EXPECTED, 8);
  return (ExpectedVec){
      .data = data,
      .len = 1,
      .cap = 1,
  };
}

static size_t checkpoint(ParserState *state) {
  Node *current = current_node(state);
  return current->as.group.len;
}

static void group_at(ParserState *state, size_t checkpoint, size_t name) {
  if (state->stack.len == 0) {
    abort();
  }
  Node *current_group = current_node(state);
  NodeVec *children = &current_group->as.group;
  if (checkpoint > children->len) {
    return;
  }
  size_t moved = children->len - checkpoint;
  Node new_group = new_group_node(name);
  new_group.as.group = node_vec_new();

  if (moved != 0) {
    new_group.as.group.data = (Node *)malloc(moved * sizeof(Node));
    if (!new_group.as.group.data)
      abort();
    new_group.as.group.len = moved;
    new_group.as.group.cap = moved;

    memcpy(new_group.as.group.data, &children->data[checkpoint],
           moved * sizeof(Node));
  }

  children->len = checkpoint;

  node_vec_push(children, new_group);

  return;
}

static inline size_t push_break(ParserState *state, PeakFunc f) {
  break_stack_push(&state->breaks, f);
  return state->breaks.len + 2;
}
static const char *group_names[] = {
    "named",
    "bracketed",
    "_atom",
    "call_name",
    "args",
    "call",
    "member_call",
    "seq",
    "choice",
    "_expr",
    "kw_def",
    "token_def",
    "fold_stmt",
    "parser_def",
    "child_query",
    "group_query",
    "label",
    "labelled_query",
    "_query",
    "highlight_def",
    "_stmt",
    "root",
    "unmatched",
    "error",
};


EXPORT const char *group_name(uint32_t kind) {
    if (kind < (uint32_t)(sizeof(group_names) / sizeof(group_names[0]))) {
        return group_names[kind];
    }
    return "error";
}

static const char *label_names[] = {
    "expression",
    "token_name",
    "regex",
    "parser_name",
    "declaration",
    "error",
};


EXPORT const char *label_name(uint32_t kind) {
    if (kind < (uint32_t)(sizeof(label_names) / sizeof(label_names[0]))) {
        return label_names[kind];
    }
    return "error";
}

static const char *token_names[] = {
    "KEYWORD",
    "PARSER",
    "TOKEN",
    "HIGHTLIGHT",
    "FOLD",
    "comment",
    "whitespace",
    "int",
    "colon",
    "comma",
    "bar",
    "dot",
    "l_bracket",
    "r_bracket",
    "l_paren",
    "r_paren",
    "l_brace",
    "r_brace",
    "plus",
    "eq",
    "ident",
    "semi",
    "string",
    "at",
    "error",
};


EXPORT const char *token_name(uint32_t kind) {
    if (kind < (uint32_t)(sizeof(token_names) / sizeof(token_names[0]))) {
        return token_names[kind];
    }
    return "error";
}


/* Exact */
static bool lex_3(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (lexer_state->offset >= lexer_state->len) {
        lexer_state->offset = start;
        return false;
    }
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char)107) {
        lexer_state->offset = start;
        return false;
    }
    lexer_state->offset += 1;


    if (lexer_state->offset >= lexer_state->len) {
        lexer_state->offset = start;
        return false;
    }
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char)101) {
        lexer_state->offset = start;
        return false;
    }
    lexer_state->offset += 1;


    if (lexer_state->offset >= lexer_state->len) {
        lexer_state->offset = start;
        return false;
    }
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char)121) {
        lexer_state->offset = start;
        return false;
    }
    lexer_state->offset += 1;


    if (lexer_state->offset >= lexer_state->len) {
        lexer_state->offset = start;
        return false;
    }
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char)119) {
        lexer_state->offset = start;
        return false;
    }
    lexer_state->offset += 1;


    if (lexer_state->offset >= lexer_state->len) {
        lexer_state->offset = start;
        return false;
    }
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char)111) {
        lexer_state->offset = start;
        return false;
    }
    lexer_state->offset += 1;


    if (lexer_state->offset >= lexer_state->len) {
        lexer_state->offset = start;
        return false;
    }
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char)114) {
        lexer_state->offset = start;
        return false;
    }
    lexer_state->offset += 1;


    if (lexer_state->offset >= lexer_state->len) {
        lexer_state->offset = start;
        return false;
    }
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char)100) {
        lexer_state->offset = start;
        return false;
    }
    lexer_state->offset += 1;


    return true;
}


/* RegexSeq */
static bool lex_2(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (!lex_3(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    return true;
}


/* RegexGroup */
static bool lex_1(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    lexer_state->offset = start;
    if (lex_2(lexer_state)) {

        lexer_state->group_offset = lexer_state->offset;
        return true;
    }

    lexer_state->offset = start;
    return false;
}


/* RegexChar */
static bool lex_5(LexerState *lexer_state) {
    if (lexer_state->offset >= lexer_state->len) {
        return false; /* EOF */
    }

    if ((unsigned char)lexer_state->data[lexer_state->offset] == (unsigned char)95) {
        lexer_state->offset += 1;
        return true;
    }

    return false;
}


/* RegexRange */
static bool lex_6(LexerState *lexer_state) {
    if (lexer_state->offset >= lexer_state->len) {
        return false; /* EOF */
    }

    unsigned char current = (unsigned char)lexer_state->data[lexer_state->offset];
    if (current >= (unsigned char)97 && current <= (unsigned char)122) {
        lexer_state->offset += 1;
        return true;
    }

    return false;
}


/* RegexRange */
static bool lex_7(LexerState *lexer_state) {
    if (lexer_state->offset >= lexer_state->len) {
        return false; /* EOF */
    }

    unsigned char current = (unsigned char)lexer_state->data[lexer_state->offset];
    if (current >= (unsigned char)65 && current <= (unsigned char)90) {
        lexer_state->offset += 1;
        return true;
    }

    return false;
}


/* RegexNegatedChoice */
static bool lex_4(LexerState *lexer_state) {
    size_t len = lexer_state->len;
    size_t start = lexer_state->offset;


    if (lex_5(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }

    if (lex_6(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }

    if (lex_7(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    if (lexer_state->offset == len) {
        return true;
    }

    lexer_state->offset += 1;
    return true;
}


/* RegexSeq */
static bool lex_0(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (!lex_1(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    if (!lex_4(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    return true;
}


static size_t lex_KEYWORD(LexerState *lexer_state) {
    if (!lex_0(lexer_state)) {
        return 0;
    }

    if (lexer_state->group_offset != 0) {
        return lexer_state->group_offset;
    }
    return lexer_state->offset;
}


/* Exact */
static bool lex_11(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (lexer_state->offset >= lexer_state->len) {
        lexer_state->offset = start;
        return false;
    }
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char)112) {
        lexer_state->offset = start;
        return false;
    }
    lexer_state->offset += 1;


    if (lexer_state->offset >= lexer_state->len) {
        lexer_state->offset = start;
        return false;
    }
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char)97) {
        lexer_state->offset = start;
        return false;
    }
    lexer_state->offset += 1;


    if (lexer_state->offset >= lexer_state->len) {
        lexer_state->offset = start;
        return false;
    }
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char)114) {
        lexer_state->offset = start;
        return false;
    }
    lexer_state->offset += 1;


    if (lexer_state->offset >= lexer_state->len) {
        lexer_state->offset = start;
        return false;
    }
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char)115) {
        lexer_state->offset = start;
        return false;
    }
    lexer_state->offset += 1;


    if (lexer_state->offset >= lexer_state->len) {
        lexer_state->offset = start;
        return false;
    }
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char)101) {
        lexer_state->offset = start;
        return false;
    }
    lexer_state->offset += 1;


    if (lexer_state->offset >= lexer_state->len) {
        lexer_state->offset = start;
        return false;
    }
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char)114) {
        lexer_state->offset = start;
        return false;
    }
    lexer_state->offset += 1;


    return true;
}


/* RegexSeq */
static bool lex_10(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (!lex_11(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    return true;
}


/* RegexGroup */
static bool lex_9(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    lexer_state->offset = start;
    if (lex_10(lexer_state)) {

        lexer_state->group_offset = lexer_state->offset;
        return true;
    }

    lexer_state->offset = start;
    return false;
}


/* RegexChar */
static bool lex_13(LexerState *lexer_state) {
    if (lexer_state->offset >= lexer_state->len) {
        return false; /* EOF */
    }

    if ((unsigned char)lexer_state->data[lexer_state->offset] == (unsigned char)95) {
        lexer_state->offset += 1;
        return true;
    }

    return false;
}


/* RegexRange */
static bool lex_14(LexerState *lexer_state) {
    if (lexer_state->offset >= lexer_state->len) {
        return false; /* EOF */
    }

    unsigned char current = (unsigned char)lexer_state->data[lexer_state->offset];
    if (current >= (unsigned char)97 && current <= (unsigned char)122) {
        lexer_state->offset += 1;
        return true;
    }

    return false;
}


/* RegexRange */
static bool lex_15(LexerState *lexer_state) {
    if (lexer_state->offset >= lexer_state->len) {
        return false; /* EOF */
    }

    unsigned char current = (unsigned char)lexer_state->data[lexer_state->offset];
    if (current >= (unsigned char)65 && current <= (unsigned char)90) {
        lexer_state->offset += 1;
        return true;
    }

    return false;
}


/* RegexNegatedChoice */
static bool lex_12(LexerState *lexer_state) {
    size_t len = lexer_state->len;
    size_t start = lexer_state->offset;


    if (lex_13(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }

    if (lex_14(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }

    if (lex_15(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    if (lexer_state->offset == len) {
        return true;
    }

    lexer_state->offset += 1;
    return true;
}


/* RegexSeq */
static bool lex_8(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (!lex_9(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    if (!lex_12(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    return true;
}


static size_t lex_PARSER(LexerState *lexer_state) {
    if (!lex_8(lexer_state)) {
        return 0;
    }

    if (lexer_state->group_offset != 0) {
        return lexer_state->group_offset;
    }
    return lexer_state->offset;
}


/* Exact */
static bool lex_19(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (lexer_state->offset >= lexer_state->len) {
        lexer_state->offset = start;
        return false;
    }
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char)116) {
        lexer_state->offset = start;
        return false;
    }
    lexer_state->offset += 1;


    if (lexer_state->offset >= lexer_state->len) {
        lexer_state->offset = start;
        return false;
    }
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char)111) {
        lexer_state->offset = start;
        return false;
    }
    lexer_state->offset += 1;


    if (lexer_state->offset >= lexer_state->len) {
        lexer_state->offset = start;
        return false;
    }
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char)107) {
        lexer_state->offset = start;
        return false;
    }
    lexer_state->offset += 1;


    if (lexer_state->offset >= lexer_state->len) {
        lexer_state->offset = start;
        return false;
    }
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char)101) {
        lexer_state->offset = start;
        return false;
    }
    lexer_state->offset += 1;


    if (lexer_state->offset >= lexer_state->len) {
        lexer_state->offset = start;
        return false;
    }
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char)110) {
        lexer_state->offset = start;
        return false;
    }
    lexer_state->offset += 1;


    return true;
}


/* RegexSeq */
static bool lex_18(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (!lex_19(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    return true;
}


/* RegexGroup */
static bool lex_17(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    lexer_state->offset = start;
    if (lex_18(lexer_state)) {

        lexer_state->group_offset = lexer_state->offset;
        return true;
    }

    lexer_state->offset = start;
    return false;
}


/* RegexChar */
static bool lex_21(LexerState *lexer_state) {
    if (lexer_state->offset >= lexer_state->len) {
        return false; /* EOF */
    }

    if ((unsigned char)lexer_state->data[lexer_state->offset] == (unsigned char)95) {
        lexer_state->offset += 1;
        return true;
    }

    return false;
}


/* RegexRange */
static bool lex_22(LexerState *lexer_state) {
    if (lexer_state->offset >= lexer_state->len) {
        return false; /* EOF */
    }

    unsigned char current = (unsigned char)lexer_state->data[lexer_state->offset];
    if (current >= (unsigned char)97 && current <= (unsigned char)122) {
        lexer_state->offset += 1;
        return true;
    }

    return false;
}


/* RegexRange */
static bool lex_23(LexerState *lexer_state) {
    if (lexer_state->offset >= lexer_state->len) {
        return false; /* EOF */
    }

    unsigned char current = (unsigned char)lexer_state->data[lexer_state->offset];
    if (current >= (unsigned char)65 && current <= (unsigned char)90) {
        lexer_state->offset += 1;
        return true;
    }

    return false;
}


/* RegexNegatedChoice */
static bool lex_20(LexerState *lexer_state) {
    size_t len = lexer_state->len;
    size_t start = lexer_state->offset;


    if (lex_21(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }

    if (lex_22(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }

    if (lex_23(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    if (lexer_state->offset == len) {
        return true;
    }

    lexer_state->offset += 1;
    return true;
}


/* RegexSeq */
static bool lex_16(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (!lex_17(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    if (!lex_20(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    return true;
}


static size_t lex_TOKEN(LexerState *lexer_state) {
    if (!lex_16(lexer_state)) {
        return 0;
    }

    if (lexer_state->group_offset != 0) {
        return lexer_state->group_offset;
    }
    return lexer_state->offset;
}


/* Exact */
static bool lex_27(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (lexer_state->offset >= lexer_state->len) {
        lexer_state->offset = start;
        return false;
    }
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char)104) {
        lexer_state->offset = start;
        return false;
    }
    lexer_state->offset += 1;


    if (lexer_state->offset >= lexer_state->len) {
        lexer_state->offset = start;
        return false;
    }
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char)105) {
        lexer_state->offset = start;
        return false;
    }
    lexer_state->offset += 1;


    if (lexer_state->offset >= lexer_state->len) {
        lexer_state->offset = start;
        return false;
    }
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char)103) {
        lexer_state->offset = start;
        return false;
    }
    lexer_state->offset += 1;


    if (lexer_state->offset >= lexer_state->len) {
        lexer_state->offset = start;
        return false;
    }
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char)104) {
        lexer_state->offset = start;
        return false;
    }
    lexer_state->offset += 1;


    if (lexer_state->offset >= lexer_state->len) {
        lexer_state->offset = start;
        return false;
    }
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char)108) {
        lexer_state->offset = start;
        return false;
    }
    lexer_state->offset += 1;


    if (lexer_state->offset >= lexer_state->len) {
        lexer_state->offset = start;
        return false;
    }
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char)105) {
        lexer_state->offset = start;
        return false;
    }
    lexer_state->offset += 1;


    if (lexer_state->offset >= lexer_state->len) {
        lexer_state->offset = start;
        return false;
    }
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char)103) {
        lexer_state->offset = start;
        return false;
    }
    lexer_state->offset += 1;


    if (lexer_state->offset >= lexer_state->len) {
        lexer_state->offset = start;
        return false;
    }
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char)104) {
        lexer_state->offset = start;
        return false;
    }
    lexer_state->offset += 1;


    if (lexer_state->offset >= lexer_state->len) {
        lexer_state->offset = start;
        return false;
    }
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char)116) {
        lexer_state->offset = start;
        return false;
    }
    lexer_state->offset += 1;


    return true;
}


/* RegexSeq */
static bool lex_26(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (!lex_27(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    return true;
}


/* RegexGroup */
static bool lex_25(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    lexer_state->offset = start;
    if (lex_26(lexer_state)) {

        lexer_state->group_offset = lexer_state->offset;
        return true;
    }

    lexer_state->offset = start;
    return false;
}


/* RegexChar */
static bool lex_29(LexerState *lexer_state) {
    if (lexer_state->offset >= lexer_state->len) {
        return false; /* EOF */
    }

    if ((unsigned char)lexer_state->data[lexer_state->offset] == (unsigned char)95) {
        lexer_state->offset += 1;
        return true;
    }

    return false;
}


/* RegexRange */
static bool lex_30(LexerState *lexer_state) {
    if (lexer_state->offset >= lexer_state->len) {
        return false; /* EOF */
    }

    unsigned char current = (unsigned char)lexer_state->data[lexer_state->offset];
    if (current >= (unsigned char)97 && current <= (unsigned char)122) {
        lexer_state->offset += 1;
        return true;
    }

    return false;
}


/* RegexRange */
static bool lex_31(LexerState *lexer_state) {
    if (lexer_state->offset >= lexer_state->len) {
        return false; /* EOF */
    }

    unsigned char current = (unsigned char)lexer_state->data[lexer_state->offset];
    if (current >= (unsigned char)65 && current <= (unsigned char)90) {
        lexer_state->offset += 1;
        return true;
    }

    return false;
}


/* RegexNegatedChoice */
static bool lex_28(LexerState *lexer_state) {
    size_t len = lexer_state->len;
    size_t start = lexer_state->offset;


    if (lex_29(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }

    if (lex_30(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }

    if (lex_31(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    if (lexer_state->offset == len) {
        return true;
    }

    lexer_state->offset += 1;
    return true;
}


/* RegexSeq */
static bool lex_24(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (!lex_25(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    if (!lex_28(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    return true;
}


static size_t lex_HIGHTLIGHT(LexerState *lexer_state) {
    if (!lex_24(lexer_state)) {
        return 0;
    }

    if (lexer_state->group_offset != 0) {
        return lexer_state->group_offset;
    }
    return lexer_state->offset;
}


/* Exact */
static bool lex_35(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (lexer_state->offset >= lexer_state->len) {
        lexer_state->offset = start;
        return false;
    }
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char)102) {
        lexer_state->offset = start;
        return false;
    }
    lexer_state->offset += 1;


    if (lexer_state->offset >= lexer_state->len) {
        lexer_state->offset = start;
        return false;
    }
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char)111) {
        lexer_state->offset = start;
        return false;
    }
    lexer_state->offset += 1;


    if (lexer_state->offset >= lexer_state->len) {
        lexer_state->offset = start;
        return false;
    }
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char)108) {
        lexer_state->offset = start;
        return false;
    }
    lexer_state->offset += 1;


    if (lexer_state->offset >= lexer_state->len) {
        lexer_state->offset = start;
        return false;
    }
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char)100) {
        lexer_state->offset = start;
        return false;
    }
    lexer_state->offset += 1;


    return true;
}


/* RegexSeq */
static bool lex_34(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (!lex_35(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    return true;
}


/* RegexGroup */
static bool lex_33(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    lexer_state->offset = start;
    if (lex_34(lexer_state)) {

        lexer_state->group_offset = lexer_state->offset;
        return true;
    }

    lexer_state->offset = start;
    return false;
}


/* RegexChar */
static bool lex_37(LexerState *lexer_state) {
    if (lexer_state->offset >= lexer_state->len) {
        return false; /* EOF */
    }

    if ((unsigned char)lexer_state->data[lexer_state->offset] == (unsigned char)95) {
        lexer_state->offset += 1;
        return true;
    }

    return false;
}


/* RegexRange */
static bool lex_38(LexerState *lexer_state) {
    if (lexer_state->offset >= lexer_state->len) {
        return false; /* EOF */
    }

    unsigned char current = (unsigned char)lexer_state->data[lexer_state->offset];
    if (current >= (unsigned char)97 && current <= (unsigned char)122) {
        lexer_state->offset += 1;
        return true;
    }

    return false;
}


/* RegexRange */
static bool lex_39(LexerState *lexer_state) {
    if (lexer_state->offset >= lexer_state->len) {
        return false; /* EOF */
    }

    unsigned char current = (unsigned char)lexer_state->data[lexer_state->offset];
    if (current >= (unsigned char)65 && current <= (unsigned char)90) {
        lexer_state->offset += 1;
        return true;
    }

    return false;
}


/* RegexNegatedChoice */
static bool lex_36(LexerState *lexer_state) {
    size_t len = lexer_state->len;
    size_t start = lexer_state->offset;


    if (lex_37(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }

    if (lex_38(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }

    if (lex_39(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    if (lexer_state->offset == len) {
        return true;
    }

    lexer_state->offset += 1;
    return true;
}


/* RegexSeq */
static bool lex_32(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (!lex_33(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    if (!lex_36(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    return true;
}


static size_t lex_FOLD(LexerState *lexer_state) {
    if (!lex_32(lexer_state)) {
        return 0;
    }

    if (lexer_state->group_offset != 0) {
        return lexer_state->group_offset;
    }
    return lexer_state->offset;
}


/* Exact */
static bool lex_41(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (lexer_state->offset >= lexer_state->len) {
        lexer_state->offset = start;
        return false;
    }
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char)35) {
        lexer_state->offset = start;
        return false;
    }
    lexer_state->offset += 1;


    return true;
}


/* RegexChar */
static bool lex_43(LexerState *lexer_state) {
    if (lexer_state->offset >= lexer_state->len) {
        return false; /* EOF */
    }

    if ((unsigned char)lexer_state->data[lexer_state->offset] == (unsigned char)10) {
        lexer_state->offset += 1;
        return true;
    }

    return false;
}


/* RegexNegatedChoice */
static bool lex_42(LexerState *lexer_state) {
    size_t len = lexer_state->len;
    size_t start = lexer_state->offset;


    if (lex_43(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    if (lexer_state->offset == len) {
        return true;
    }

    lexer_state->offset += 1;
    return true;
}


/* Rep0Regex */
static bool lex_44(LexerState *lexer_state) {
    for (;;) {
        size_t before = lexer_state->offset;
        if (!lex_42(lexer_state)) {
            break;
        }
        if (lexer_state->offset == before) {
            break;
        }
        if (lexer_state->offset >= lexer_state->len) {
            break;
        }
    }
    return true;
}


/* RegexSeq */
static bool lex_40(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (!lex_41(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    if (!lex_44(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    return true;
}


static size_t lex_comment(LexerState *lexer_state) {
    if (!lex_40(lexer_state)) {
        return 0;
    }

    if (lexer_state->group_offset != 0) {
        return lexer_state->group_offset;
    }
    return lexer_state->offset;
}


/* Whitespace */
static bool lex_46(LexerState *lexer_state) {
    if (lexer_state->offset >= lexer_state->len) {
        return false;
    }

    unsigned char c = (unsigned char)lexer_state->data[lexer_state->offset];
    bool is_space = (c == 32);
    bool is_ctrl_ws = (c >= 9 && c <= 13);

    if (is_space || is_ctrl_ws) {
        lexer_state->offset += 1;
        return true;
    }

    return false;
}


/* Rep1Regex */
static bool lex_47(LexerState *lexer_state) {
    size_t start = lexer_state->offset;

    if (lexer_state->offset >= lexer_state->len) {
        return false;
    }
    if (!lex_46(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }

    for (;;) {
        size_t before = lexer_state->offset;
        if (!lex_46(lexer_state)) {
            break;
        }
        if (lexer_state->offset == before) {
            break;
        }
        if (lexer_state->offset >= lexer_state->len) {
            break;
        }
    }

    return true;
}


/* RegexSeq */
static bool lex_45(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (!lex_47(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    return true;
}


static size_t lex_whitespace(LexerState *lexer_state) {
    if (!lex_45(lexer_state)) {
        return 0;
    }

    if (lexer_state->group_offset != 0) {
        return lexer_state->group_offset;
    }
    return lexer_state->offset;
}


/* RegexRange */
static bool lex_50(LexerState *lexer_state) {
    if (lexer_state->offset >= lexer_state->len) {
        return false; /* EOF */
    }

    unsigned char current = (unsigned char)lexer_state->data[lexer_state->offset];
    if (current >= (unsigned char)48 && current <= (unsigned char)57) {
        lexer_state->offset += 1;
        return true;
    }

    return false;
}


/* RegexChoice */
static bool lex_49(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    lexer_state->offset = start;
    if (lex_50(lexer_state)) {
        return true;
    }


    lexer_state->offset = start;
    return false;
}


/* Rep1Regex */
static bool lex_51(LexerState *lexer_state) {
    size_t start = lexer_state->offset;

    if (lexer_state->offset >= lexer_state->len) {
        return false;
    }
    if (!lex_49(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }

    for (;;) {
        size_t before = lexer_state->offset;
        if (!lex_49(lexer_state)) {
            break;
        }
        if (lexer_state->offset == before) {
            break;
        }
        if (lexer_state->offset >= lexer_state->len) {
            break;
        }
    }

    return true;
}


/* RegexSeq */
static bool lex_48(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (!lex_51(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    return true;
}


static size_t lex_int(LexerState *lexer_state) {
    if (!lex_48(lexer_state)) {
        return 0;
    }

    if (lexer_state->group_offset != 0) {
        return lexer_state->group_offset;
    }
    return lexer_state->offset;
}


/* Exact */
static bool lex_53(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (lexer_state->offset >= lexer_state->len) {
        lexer_state->offset = start;
        return false;
    }
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char)58) {
        lexer_state->offset = start;
        return false;
    }
    lexer_state->offset += 1;


    return true;
}


/* RegexSeq */
static bool lex_52(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (!lex_53(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    return true;
}


static size_t lex_colon(LexerState *lexer_state) {
    if (!lex_52(lexer_state)) {
        return 0;
    }

    if (lexer_state->group_offset != 0) {
        return lexer_state->group_offset;
    }
    return lexer_state->offset;
}


/* Exact */
static bool lex_55(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (lexer_state->offset >= lexer_state->len) {
        lexer_state->offset = start;
        return false;
    }
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char)44) {
        lexer_state->offset = start;
        return false;
    }
    lexer_state->offset += 1;


    return true;
}


/* RegexSeq */
static bool lex_54(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (!lex_55(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    return true;
}


static size_t lex_comma(LexerState *lexer_state) {
    if (!lex_54(lexer_state)) {
        return 0;
    }

    if (lexer_state->group_offset != 0) {
        return lexer_state->group_offset;
    }
    return lexer_state->offset;
}


/* Exact */
static bool lex_57(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (lexer_state->offset >= lexer_state->len) {
        lexer_state->offset = start;
        return false;
    }
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char)124) {
        lexer_state->offset = start;
        return false;
    }
    lexer_state->offset += 1;


    return true;
}


/* RegexSeq */
static bool lex_56(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (!lex_57(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    return true;
}


static size_t lex_bar(LexerState *lexer_state) {
    if (!lex_56(lexer_state)) {
        return 0;
    }

    if (lexer_state->group_offset != 0) {
        return lexer_state->group_offset;
    }
    return lexer_state->offset;
}


/* Exact */
static bool lex_59(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (lexer_state->offset >= lexer_state->len) {
        lexer_state->offset = start;
        return false;
    }
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char)46) {
        lexer_state->offset = start;
        return false;
    }
    lexer_state->offset += 1;


    return true;
}


/* RegexSeq */
static bool lex_58(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (!lex_59(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    return true;
}


static size_t lex_dot(LexerState *lexer_state) {
    if (!lex_58(lexer_state)) {
        return 0;
    }

    if (lexer_state->group_offset != 0) {
        return lexer_state->group_offset;
    }
    return lexer_state->offset;
}


/* Exact */
static bool lex_61(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (lexer_state->offset >= lexer_state->len) {
        lexer_state->offset = start;
        return false;
    }
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char)91) {
        lexer_state->offset = start;
        return false;
    }
    lexer_state->offset += 1;


    return true;
}


/* RegexSeq */
static bool lex_60(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (!lex_61(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    return true;
}


static size_t lex_l_bracket(LexerState *lexer_state) {
    if (!lex_60(lexer_state)) {
        return 0;
    }

    if (lexer_state->group_offset != 0) {
        return lexer_state->group_offset;
    }
    return lexer_state->offset;
}


/* Exact */
static bool lex_63(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (lexer_state->offset >= lexer_state->len) {
        lexer_state->offset = start;
        return false;
    }
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char)93) {
        lexer_state->offset = start;
        return false;
    }
    lexer_state->offset += 1;


    return true;
}


/* RegexSeq */
static bool lex_62(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (!lex_63(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    return true;
}


static size_t lex_r_bracket(LexerState *lexer_state) {
    if (!lex_62(lexer_state)) {
        return 0;
    }

    if (lexer_state->group_offset != 0) {
        return lexer_state->group_offset;
    }
    return lexer_state->offset;
}


/* Exact */
static bool lex_65(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (lexer_state->offset >= lexer_state->len) {
        lexer_state->offset = start;
        return false;
    }
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char)40) {
        lexer_state->offset = start;
        return false;
    }
    lexer_state->offset += 1;


    return true;
}


/* RegexSeq */
static bool lex_64(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (!lex_65(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    return true;
}


static size_t lex_l_paren(LexerState *lexer_state) {
    if (!lex_64(lexer_state)) {
        return 0;
    }

    if (lexer_state->group_offset != 0) {
        return lexer_state->group_offset;
    }
    return lexer_state->offset;
}


/* Exact */
static bool lex_67(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (lexer_state->offset >= lexer_state->len) {
        lexer_state->offset = start;
        return false;
    }
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char)41) {
        lexer_state->offset = start;
        return false;
    }
    lexer_state->offset += 1;


    return true;
}


/* RegexSeq */
static bool lex_66(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (!lex_67(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    return true;
}


static size_t lex_r_paren(LexerState *lexer_state) {
    if (!lex_66(lexer_state)) {
        return 0;
    }

    if (lexer_state->group_offset != 0) {
        return lexer_state->group_offset;
    }
    return lexer_state->offset;
}


/* Exact */
static bool lex_69(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (lexer_state->offset >= lexer_state->len) {
        lexer_state->offset = start;
        return false;
    }
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char)123) {
        lexer_state->offset = start;
        return false;
    }
    lexer_state->offset += 1;


    return true;
}


/* RegexSeq */
static bool lex_68(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (!lex_69(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    return true;
}


static size_t lex_l_brace(LexerState *lexer_state) {
    if (!lex_68(lexer_state)) {
        return 0;
    }

    if (lexer_state->group_offset != 0) {
        return lexer_state->group_offset;
    }
    return lexer_state->offset;
}


/* Exact */
static bool lex_71(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (lexer_state->offset >= lexer_state->len) {
        lexer_state->offset = start;
        return false;
    }
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char)125) {
        lexer_state->offset = start;
        return false;
    }
    lexer_state->offset += 1;


    return true;
}


/* RegexSeq */
static bool lex_70(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (!lex_71(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    return true;
}


static size_t lex_r_brace(LexerState *lexer_state) {
    if (!lex_70(lexer_state)) {
        return 0;
    }

    if (lexer_state->group_offset != 0) {
        return lexer_state->group_offset;
    }
    return lexer_state->offset;
}


/* Exact */
static bool lex_73(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (lexer_state->offset >= lexer_state->len) {
        lexer_state->offset = start;
        return false;
    }
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char)43) {
        lexer_state->offset = start;
        return false;
    }
    lexer_state->offset += 1;


    return true;
}


/* RegexSeq */
static bool lex_72(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (!lex_73(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    return true;
}


static size_t lex_plus(LexerState *lexer_state) {
    if (!lex_72(lexer_state)) {
        return 0;
    }

    if (lexer_state->group_offset != 0) {
        return lexer_state->group_offset;
    }
    return lexer_state->offset;
}


/* Exact */
static bool lex_75(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (lexer_state->offset >= lexer_state->len) {
        lexer_state->offset = start;
        return false;
    }
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char)61) {
        lexer_state->offset = start;
        return false;
    }
    lexer_state->offset += 1;


    return true;
}


/* RegexSeq */
static bool lex_74(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (!lex_75(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    return true;
}


static size_t lex_eq(LexerState *lexer_state) {
    if (!lex_74(lexer_state)) {
        return 0;
    }

    if (lexer_state->group_offset != 0) {
        return lexer_state->group_offset;
    }
    return lexer_state->offset;
}


/* RegexChar */
static bool lex_78(LexerState *lexer_state) {
    if (lexer_state->offset >= lexer_state->len) {
        return false; /* EOF */
    }

    if ((unsigned char)lexer_state->data[lexer_state->offset] == (unsigned char)95) {
        lexer_state->offset += 1;
        return true;
    }

    return false;
}


/* RegexRange */
static bool lex_79(LexerState *lexer_state) {
    if (lexer_state->offset >= lexer_state->len) {
        return false; /* EOF */
    }

    unsigned char current = (unsigned char)lexer_state->data[lexer_state->offset];
    if (current >= (unsigned char)97 && current <= (unsigned char)122) {
        lexer_state->offset += 1;
        return true;
    }

    return false;
}


/* RegexRange */
static bool lex_80(LexerState *lexer_state) {
    if (lexer_state->offset >= lexer_state->len) {
        return false; /* EOF */
    }

    unsigned char current = (unsigned char)lexer_state->data[lexer_state->offset];
    if (current >= (unsigned char)65 && current <= (unsigned char)90) {
        lexer_state->offset += 1;
        return true;
    }

    return false;
}


/* RegexChoice */
static bool lex_77(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    lexer_state->offset = start;
    if (lex_78(lexer_state)) {
        return true;
    }


    lexer_state->offset = start;
    if (lex_79(lexer_state)) {
        return true;
    }


    lexer_state->offset = start;
    if (lex_80(lexer_state)) {
        return true;
    }


    lexer_state->offset = start;
    return false;
}


/* RegexChar */
static bool lex_82(LexerState *lexer_state) {
    if (lexer_state->offset >= lexer_state->len) {
        return false; /* EOF */
    }

    if ((unsigned char)lexer_state->data[lexer_state->offset] == (unsigned char)95) {
        lexer_state->offset += 1;
        return true;
    }

    return false;
}


/* RegexRange */
static bool lex_83(LexerState *lexer_state) {
    if (lexer_state->offset >= lexer_state->len) {
        return false; /* EOF */
    }

    unsigned char current = (unsigned char)lexer_state->data[lexer_state->offset];
    if (current >= (unsigned char)97 && current <= (unsigned char)122) {
        lexer_state->offset += 1;
        return true;
    }

    return false;
}


/* RegexRange */
static bool lex_84(LexerState *lexer_state) {
    if (lexer_state->offset >= lexer_state->len) {
        return false; /* EOF */
    }

    unsigned char current = (unsigned char)lexer_state->data[lexer_state->offset];
    if (current >= (unsigned char)65 && current <= (unsigned char)90) {
        lexer_state->offset += 1;
        return true;
    }

    return false;
}


/* RegexRange */
static bool lex_85(LexerState *lexer_state) {
    if (lexer_state->offset >= lexer_state->len) {
        return false; /* EOF */
    }

    unsigned char current = (unsigned char)lexer_state->data[lexer_state->offset];
    if (current >= (unsigned char)48 && current <= (unsigned char)57) {
        lexer_state->offset += 1;
        return true;
    }

    return false;
}


/* RegexChoice */
static bool lex_81(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    lexer_state->offset = start;
    if (lex_82(lexer_state)) {
        return true;
    }


    lexer_state->offset = start;
    if (lex_83(lexer_state)) {
        return true;
    }


    lexer_state->offset = start;
    if (lex_84(lexer_state)) {
        return true;
    }


    lexer_state->offset = start;
    if (lex_85(lexer_state)) {
        return true;
    }


    lexer_state->offset = start;
    return false;
}


/* Rep0Regex */
static bool lex_86(LexerState *lexer_state) {
    for (;;) {
        size_t before = lexer_state->offset;
        if (!lex_81(lexer_state)) {
            break;
        }
        if (lexer_state->offset == before) {
            break;
        }
        if (lexer_state->offset >= lexer_state->len) {
            break;
        }
    }
    return true;
}


/* RegexSeq */
static bool lex_76(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (!lex_77(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    if (!lex_86(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    return true;
}


static size_t lex_ident(LexerState *lexer_state) {
    if (!lex_76(lexer_state)) {
        return 0;
    }

    if (lexer_state->group_offset != 0) {
        return lexer_state->group_offset;
    }
    return lexer_state->offset;
}


/* Exact */
static bool lex_88(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (lexer_state->offset >= lexer_state->len) {
        lexer_state->offset = start;
        return false;
    }
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char)59) {
        lexer_state->offset = start;
        return false;
    }
    lexer_state->offset += 1;


    return true;
}


/* RegexSeq */
static bool lex_87(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (!lex_88(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    return true;
}


static size_t lex_semi(LexerState *lexer_state) {
    if (!lex_87(lexer_state)) {
        return 0;
    }

    if (lexer_state->group_offset != 0) {
        return lexer_state->group_offset;
    }
    return lexer_state->offset;
}


/* Exact */
static bool lex_90(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (lexer_state->offset >= lexer_state->len) {
        lexer_state->offset = start;
        return false;
    }
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char)34) {
        lexer_state->offset = start;
        return false;
    }
    lexer_state->offset += 1;


    return true;
}


/* Exact */
static bool lex_93(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (lexer_state->offset >= lexer_state->len) {
        lexer_state->offset = start;
        return false;
    }
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char)92) {
        lexer_state->offset = start;
        return false;
    }
    lexer_state->offset += 1;


    return true;
}


/* Any */
static bool lex_94(LexerState *lexer_state) {
    if (lexer_state->offset >= lexer_state->len) {
        return false;
    }
    lexer_state->offset += 1;
    return true;
}


/* RegexSeq */
static bool lex_92(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (!lex_93(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    if (!lex_94(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    return true;
}


/* RegexChar */
static bool lex_97(LexerState *lexer_state) {
    if (lexer_state->offset >= lexer_state->len) {
        return false; /* EOF */
    }

    if ((unsigned char)lexer_state->data[lexer_state->offset] == (unsigned char)34) {
        lexer_state->offset += 1;
        return true;
    }

    return false;
}


/* Exact */
static bool lex_99(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (lexer_state->offset >= lexer_state->len) {
        lexer_state->offset = start;
        return false;
    }
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char)92) {
        lexer_state->offset = start;
        return false;
    }
    lexer_state->offset += 1;


    return true;
}


/* RegexRegexOption */
static bool lex_98(LexerState *lexer_state) {
    return lex_99(lexer_state);
}


/* RegexNegatedChoice */
static bool lex_96(LexerState *lexer_state) {
    size_t len = lexer_state->len;
    size_t start = lexer_state->offset;


    if (lex_97(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }

    if (lex_98(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    if (lexer_state->offset == len) {
        return true;
    }

    lexer_state->offset += 1;
    return true;
}


/* RegexSeq */
static bool lex_95(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (!lex_96(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    return true;
}


/* RegexGroup */
static bool lex_91(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    lexer_state->offset = start;
    if (lex_92(lexer_state)) {

        return true;
    }

    lexer_state->offset = start;
    if (lex_95(lexer_state)) {

        return true;
    }

    lexer_state->offset = start;
    return false;
}


/* Rep0Regex */
static bool lex_100(LexerState *lexer_state) {
    for (;;) {
        size_t before = lexer_state->offset;
        if (!lex_91(lexer_state)) {
            break;
        }
        if (lexer_state->offset == before) {
            break;
        }
        if (lexer_state->offset >= lexer_state->len) {
            break;
        }
    }
    return true;
}


/* Exact */
static bool lex_101(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (lexer_state->offset >= lexer_state->len) {
        lexer_state->offset = start;
        return false;
    }
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char)34) {
        lexer_state->offset = start;
        return false;
    }
    lexer_state->offset += 1;


    return true;
}


/* RegexSeq */
static bool lex_89(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (!lex_90(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    if (!lex_100(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    if (!lex_101(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    return true;
}


static size_t lex_string(LexerState *lexer_state) {
    if (!lex_89(lexer_state)) {
        return 0;
    }

    if (lexer_state->group_offset != 0) {
        return lexer_state->group_offset;
    }
    return lexer_state->offset;
}


/* Exact */
static bool lex_103(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (lexer_state->offset >= lexer_state->len) {
        lexer_state->offset = start;
        return false;
    }
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char)64) {
        lexer_state->offset = start;
        return false;
    }
    lexer_state->offset += 1;


    return true;
}


/* RegexSeq */
static bool lex_102(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (!lex_103(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    return true;
}


static size_t lex_at(LexerState *lexer_state) {
    if (!lex_102(lexer_state)) {
        return 0;
    }

    if (lexer_state->group_offset != 0) {
        return lexer_state->group_offset;
    }
    return lexer_state->offset;
}


EXPORT TokenVec lex(char *ptr, size_t len) {
    LexerState st;
    st.data = ptr;
    st.len = len;
    st.offset = 0;
    st.group_offset = 0;

    TokenVec tokens = token_vec_new();

    bool last_was_error = false;
    size_t total_offset = 0;

    while (len != 0) {

        st.group_offset = 0;
        size_t res_0 = lex_KEYWORD(&st);
        if (res_0 != 0) {
            if (res_0 > len) {
                break;
            }

            size_t end = total_offset + res_0;
            Token tok = (Token){
                .kind = (uint32_t)0,
                ._padding = 0,
                .start = total_offset,
                .end = end,
            };
            token_vec_push(&tokens, tok);

            total_offset = end;

            ptr += res_0;
            len -= res_0;

            st.data = ptr;
            st.len = len;
            st.offset = 0;
            st.group_offset = 0;

            last_was_error = false;
            continue;
        }

        st.group_offset = 0;
        size_t res_1 = lex_PARSER(&st);
        if (res_1 != 0) {
            if (res_1 > len) {
                break;
            }

            size_t end = total_offset + res_1;
            Token tok = (Token){
                .kind = (uint32_t)1,
                ._padding = 0,
                .start = total_offset,
                .end = end,
            };
            token_vec_push(&tokens, tok);

            total_offset = end;

            ptr += res_1;
            len -= res_1;

            st.data = ptr;
            st.len = len;
            st.offset = 0;
            st.group_offset = 0;

            last_was_error = false;
            continue;
        }

        st.group_offset = 0;
        size_t res_2 = lex_TOKEN(&st);
        if (res_2 != 0) {
            if (res_2 > len) {
                break;
            }

            size_t end = total_offset + res_2;
            Token tok = (Token){
                .kind = (uint32_t)2,
                ._padding = 0,
                .start = total_offset,
                .end = end,
            };
            token_vec_push(&tokens, tok);

            total_offset = end;

            ptr += res_2;
            len -= res_2;

            st.data = ptr;
            st.len = len;
            st.offset = 0;
            st.group_offset = 0;

            last_was_error = false;
            continue;
        }

        st.group_offset = 0;
        size_t res_3 = lex_HIGHTLIGHT(&st);
        if (res_3 != 0) {
            if (res_3 > len) {
                break;
            }

            size_t end = total_offset + res_3;
            Token tok = (Token){
                .kind = (uint32_t)3,
                ._padding = 0,
                .start = total_offset,
                .end = end,
            };
            token_vec_push(&tokens, tok);

            total_offset = end;

            ptr += res_3;
            len -= res_3;

            st.data = ptr;
            st.len = len;
            st.offset = 0;
            st.group_offset = 0;

            last_was_error = false;
            continue;
        }

        st.group_offset = 0;
        size_t res_4 = lex_FOLD(&st);
        if (res_4 != 0) {
            if (res_4 > len) {
                break;
            }

            size_t end = total_offset + res_4;
            Token tok = (Token){
                .kind = (uint32_t)4,
                ._padding = 0,
                .start = total_offset,
                .end = end,
            };
            token_vec_push(&tokens, tok);

            total_offset = end;

            ptr += res_4;
            len -= res_4;

            st.data = ptr;
            st.len = len;
            st.offset = 0;
            st.group_offset = 0;

            last_was_error = false;
            continue;
        }

        st.group_offset = 0;
        size_t res_5 = lex_comment(&st);
        if (res_5 != 0) {
            if (res_5 > len) {
                break;
            }

            size_t end = total_offset + res_5;
            Token tok = (Token){
                .kind = (uint32_t)5,
                ._padding = 0,
                .start = total_offset,
                .end = end,
            };
            token_vec_push(&tokens, tok);

            total_offset = end;

            ptr += res_5;
            len -= res_5;

            st.data = ptr;
            st.len = len;
            st.offset = 0;
            st.group_offset = 0;

            last_was_error = false;
            continue;
        }

        st.group_offset = 0;
        size_t res_6 = lex_whitespace(&st);
        if (res_6 != 0) {
            if (res_6 > len) {
                break;
            }

            size_t end = total_offset + res_6;
            Token tok = (Token){
                .kind = (uint32_t)6,
                ._padding = 0,
                .start = total_offset,
                .end = end,
            };
            token_vec_push(&tokens, tok);

            total_offset = end;

            ptr += res_6;
            len -= res_6;

            st.data = ptr;
            st.len = len;
            st.offset = 0;
            st.group_offset = 0;

            last_was_error = false;
            continue;
        }

        st.group_offset = 0;
        size_t res_7 = lex_int(&st);
        if (res_7 != 0) {
            if (res_7 > len) {
                break;
            }

            size_t end = total_offset + res_7;
            Token tok = (Token){
                .kind = (uint32_t)7,
                ._padding = 0,
                .start = total_offset,
                .end = end,
            };
            token_vec_push(&tokens, tok);

            total_offset = end;

            ptr += res_7;
            len -= res_7;

            st.data = ptr;
            st.len = len;
            st.offset = 0;
            st.group_offset = 0;

            last_was_error = false;
            continue;
        }

        st.group_offset = 0;
        size_t res_8 = lex_colon(&st);
        if (res_8 != 0) {
            if (res_8 > len) {
                break;
            }

            size_t end = total_offset + res_8;
            Token tok = (Token){
                .kind = (uint32_t)8,
                ._padding = 0,
                .start = total_offset,
                .end = end,
            };
            token_vec_push(&tokens, tok);

            total_offset = end;

            ptr += res_8;
            len -= res_8;

            st.data = ptr;
            st.len = len;
            st.offset = 0;
            st.group_offset = 0;

            last_was_error = false;
            continue;
        }

        st.group_offset = 0;
        size_t res_9 = lex_comma(&st);
        if (res_9 != 0) {
            if (res_9 > len) {
                break;
            }

            size_t end = total_offset + res_9;
            Token tok = (Token){
                .kind = (uint32_t)9,
                ._padding = 0,
                .start = total_offset,
                .end = end,
            };
            token_vec_push(&tokens, tok);

            total_offset = end;

            ptr += res_9;
            len -= res_9;

            st.data = ptr;
            st.len = len;
            st.offset = 0;
            st.group_offset = 0;

            last_was_error = false;
            continue;
        }

        st.group_offset = 0;
        size_t res_10 = lex_bar(&st);
        if (res_10 != 0) {
            if (res_10 > len) {
                break;
            }

            size_t end = total_offset + res_10;
            Token tok = (Token){
                .kind = (uint32_t)10,
                ._padding = 0,
                .start = total_offset,
                .end = end,
            };
            token_vec_push(&tokens, tok);

            total_offset = end;

            ptr += res_10;
            len -= res_10;

            st.data = ptr;
            st.len = len;
            st.offset = 0;
            st.group_offset = 0;

            last_was_error = false;
            continue;
        }

        st.group_offset = 0;
        size_t res_11 = lex_dot(&st);
        if (res_11 != 0) {
            if (res_11 > len) {
                break;
            }

            size_t end = total_offset + res_11;
            Token tok = (Token){
                .kind = (uint32_t)11,
                ._padding = 0,
                .start = total_offset,
                .end = end,
            };
            token_vec_push(&tokens, tok);

            total_offset = end;

            ptr += res_11;
            len -= res_11;

            st.data = ptr;
            st.len = len;
            st.offset = 0;
            st.group_offset = 0;

            last_was_error = false;
            continue;
        }

        st.group_offset = 0;
        size_t res_12 = lex_l_bracket(&st);
        if (res_12 != 0) {
            if (res_12 > len) {
                break;
            }

            size_t end = total_offset + res_12;
            Token tok = (Token){
                .kind = (uint32_t)12,
                ._padding = 0,
                .start = total_offset,
                .end = end,
            };
            token_vec_push(&tokens, tok);

            total_offset = end;

            ptr += res_12;
            len -= res_12;

            st.data = ptr;
            st.len = len;
            st.offset = 0;
            st.group_offset = 0;

            last_was_error = false;
            continue;
        }

        st.group_offset = 0;
        size_t res_13 = lex_r_bracket(&st);
        if (res_13 != 0) {
            if (res_13 > len) {
                break;
            }

            size_t end = total_offset + res_13;
            Token tok = (Token){
                .kind = (uint32_t)13,
                ._padding = 0,
                .start = total_offset,
                .end = end,
            };
            token_vec_push(&tokens, tok);

            total_offset = end;

            ptr += res_13;
            len -= res_13;

            st.data = ptr;
            st.len = len;
            st.offset = 0;
            st.group_offset = 0;

            last_was_error = false;
            continue;
        }

        st.group_offset = 0;
        size_t res_14 = lex_l_paren(&st);
        if (res_14 != 0) {
            if (res_14 > len) {
                break;
            }

            size_t end = total_offset + res_14;
            Token tok = (Token){
                .kind = (uint32_t)14,
                ._padding = 0,
                .start = total_offset,
                .end = end,
            };
            token_vec_push(&tokens, tok);

            total_offset = end;

            ptr += res_14;
            len -= res_14;

            st.data = ptr;
            st.len = len;
            st.offset = 0;
            st.group_offset = 0;

            last_was_error = false;
            continue;
        }

        st.group_offset = 0;
        size_t res_15 = lex_r_paren(&st);
        if (res_15 != 0) {
            if (res_15 > len) {
                break;
            }

            size_t end = total_offset + res_15;
            Token tok = (Token){
                .kind = (uint32_t)15,
                ._padding = 0,
                .start = total_offset,
                .end = end,
            };
            token_vec_push(&tokens, tok);

            total_offset = end;

            ptr += res_15;
            len -= res_15;

            st.data = ptr;
            st.len = len;
            st.offset = 0;
            st.group_offset = 0;

            last_was_error = false;
            continue;
        }

        st.group_offset = 0;
        size_t res_16 = lex_l_brace(&st);
        if (res_16 != 0) {
            if (res_16 > len) {
                break;
            }

            size_t end = total_offset + res_16;
            Token tok = (Token){
                .kind = (uint32_t)16,
                ._padding = 0,
                .start = total_offset,
                .end = end,
            };
            token_vec_push(&tokens, tok);

            total_offset = end;

            ptr += res_16;
            len -= res_16;

            st.data = ptr;
            st.len = len;
            st.offset = 0;
            st.group_offset = 0;

            last_was_error = false;
            continue;
        }

        st.group_offset = 0;
        size_t res_17 = lex_r_brace(&st);
        if (res_17 != 0) {
            if (res_17 > len) {
                break;
            }

            size_t end = total_offset + res_17;
            Token tok = (Token){
                .kind = (uint32_t)17,
                ._padding = 0,
                .start = total_offset,
                .end = end,
            };
            token_vec_push(&tokens, tok);

            total_offset = end;

            ptr += res_17;
            len -= res_17;

            st.data = ptr;
            st.len = len;
            st.offset = 0;
            st.group_offset = 0;

            last_was_error = false;
            continue;
        }

        st.group_offset = 0;
        size_t res_18 = lex_plus(&st);
        if (res_18 != 0) {
            if (res_18 > len) {
                break;
            }

            size_t end = total_offset + res_18;
            Token tok = (Token){
                .kind = (uint32_t)18,
                ._padding = 0,
                .start = total_offset,
                .end = end,
            };
            token_vec_push(&tokens, tok);

            total_offset = end;

            ptr += res_18;
            len -= res_18;

            st.data = ptr;
            st.len = len;
            st.offset = 0;
            st.group_offset = 0;

            last_was_error = false;
            continue;
        }

        st.group_offset = 0;
        size_t res_19 = lex_eq(&st);
        if (res_19 != 0) {
            if (res_19 > len) {
                break;
            }

            size_t end = total_offset + res_19;
            Token tok = (Token){
                .kind = (uint32_t)19,
                ._padding = 0,
                .start = total_offset,
                .end = end,
            };
            token_vec_push(&tokens, tok);

            total_offset = end;

            ptr += res_19;
            len -= res_19;

            st.data = ptr;
            st.len = len;
            st.offset = 0;
            st.group_offset = 0;

            last_was_error = false;
            continue;
        }

        st.group_offset = 0;
        size_t res_20 = lex_ident(&st);
        if (res_20 != 0) {
            if (res_20 > len) {
                break;
            }

            size_t end = total_offset + res_20;
            Token tok = (Token){
                .kind = (uint32_t)20,
                ._padding = 0,
                .start = total_offset,
                .end = end,
            };
            token_vec_push(&tokens, tok);

            total_offset = end;

            ptr += res_20;
            len -= res_20;

            st.data = ptr;
            st.len = len;
            st.offset = 0;
            st.group_offset = 0;

            last_was_error = false;
            continue;
        }

        st.group_offset = 0;
        size_t res_21 = lex_semi(&st);
        if (res_21 != 0) {
            if (res_21 > len) {
                break;
            }

            size_t end = total_offset + res_21;
            Token tok = (Token){
                .kind = (uint32_t)21,
                ._padding = 0,
                .start = total_offset,
                .end = end,
            };
            token_vec_push(&tokens, tok);

            total_offset = end;

            ptr += res_21;
            len -= res_21;

            st.data = ptr;
            st.len = len;
            st.offset = 0;
            st.group_offset = 0;

            last_was_error = false;
            continue;
        }

        st.group_offset = 0;
        size_t res_22 = lex_string(&st);
        if (res_22 != 0) {
            if (res_22 > len) {
                break;
            }

            size_t end = total_offset + res_22;
            Token tok = (Token){
                .kind = (uint32_t)22,
                ._padding = 0,
                .start = total_offset,
                .end = end,
            };
            token_vec_push(&tokens, tok);

            total_offset = end;

            ptr += res_22;
            len -= res_22;

            st.data = ptr;
            st.len = len;
            st.offset = 0;
            st.group_offset = 0;

            last_was_error = false;
            continue;
        }

        st.group_offset = 0;
        size_t res_23 = lex_at(&st);
        if (res_23 != 0) {
            if (res_23 > len) {
                break;
            }

            size_t end = total_offset + res_23;
            Token tok = (Token){
                .kind = (uint32_t)23,
                ._padding = 0,
                .start = total_offset,
                .end = end,
            };
            token_vec_push(&tokens, tok);

            total_offset = end;

            ptr += res_23;
            len -= res_23;

            st.data = ptr;
            st.len = len;
            st.offset = 0;
            st.group_offset = 0;

            last_was_error = false;
            continue;
        }


        /* No token matched: produce/extend error token and consume one byte */
        if (!last_was_error) {
            size_t end = total_offset + 1;
            Token tok = (Token){
                .kind = (uint32_t)24,
                ._padding = 0,
                .start = total_offset,
                .end = end,
            };
            token_vec_push(&tokens, tok);
        } else {
            /* Extend the previous error token by 1 */
            if (tokens.len != 0) {
                tokens.data[tokens.len - 1].end += 1;
            }
        }

        total_offset += 1;
        ptr += 1;
        len -= 1;

        st.data = ptr;
        st.len = len;
        st.offset = 0;
        st.group_offset = 0;

        last_was_error = true;
    }

    return tokens;
}


ParserState default_state(char *ptr, size_t len) {
    Node root = new_group_node(21);

    NodeVec stack = node_vec_new();
    node_vec_push(&stack, root);

    TokenVec tokens = lex(ptr, len);

    return (ParserState){
        .tokens  = tokens,
        .stack   = stack,
        .offset  = 0,
        .breaks  = break_stack_new(),
        .skipped = skipped_vec_new(),
    };
}

static bool peak_0(ParserState *state, size_t offset, bool recover);
static size_t parse_0(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_0(void);
static bool peak_1(ParserState *state, size_t offset, bool recover);
static size_t parse_1(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_1(void);
static bool peak_2(ParserState *state, size_t offset, bool recover);
static size_t parse_2(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_2(void);
static bool peak_3(ParserState *state, size_t offset, bool recover);
static size_t parse_3(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_3(void);
static bool peak_4(ParserState *state, size_t offset, bool recover);
static size_t parse_4(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_4(void);
static bool peak_5(ParserState *state, size_t offset, bool recover);
static size_t parse_5(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_5(void);
static bool peak_6(ParserState *state, size_t offset, bool recover);
static size_t parse_6(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_6(void);
static bool peak_7(ParserState *state, size_t offset, bool recover);
static size_t parse_7(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_7(void);
static bool peak_8(ParserState *state, size_t offset, bool recover);
static size_t parse_8(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_8(void);
static bool peak_9(ParserState *state, size_t offset, bool recover);
static size_t parse_9(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_9(void);
static bool peak_10(ParserState *state, size_t offset, bool recover);
static size_t parse_10(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_10(void);
static bool peak_11(ParserState *state, size_t offset, bool recover);
static size_t parse_11(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_11(void);
static bool peak_12(ParserState *state, size_t offset, bool recover);
static size_t parse_12(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_12(void);
static bool peak_13(ParserState *state, size_t offset, bool recover);
static size_t parse_13(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_13(void);
static bool peak_14(ParserState *state, size_t offset, bool recover);
static size_t parse_14(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_14(void);
static bool peak_15(ParserState *state, size_t offset, bool recover);
static size_t parse_15(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_15(void);
static bool peak_16(ParserState *state, size_t offset, bool recover);
static size_t parse_16(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_16(void);
static bool peak_17(ParserState *state, size_t offset, bool recover);
static size_t parse_17(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_17(void);
static bool peak_18(ParserState *state, size_t offset, bool recover);
static size_t parse_18(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_18(void);
static bool peak_19(ParserState *state, size_t offset, bool recover);
static size_t parse_19(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_19(void);
static bool peak_20(ParserState *state, size_t offset, bool recover);
static size_t parse_20(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_20(void);
static bool peak_21(ParserState *state, size_t offset, bool recover);
static size_t parse_21(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_21(void);
static bool peak_22(ParserState *state, size_t offset, bool recover);
static size_t parse_22(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_22(void);
static bool peak_23(ParserState *state, size_t offset, bool recover);
static size_t parse_23(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_23(void);
static bool peak_24(ParserState *state, size_t offset, bool recover);
static size_t parse_24(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_24(void);
static bool peak_25(ParserState *state, size_t offset, bool recover);
static size_t parse_25(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_25(void);
static bool peak_26(ParserState *state, size_t offset, bool recover);
static size_t parse_26(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_26(void);
static bool peak_27(ParserState *state, size_t offset, bool recover);
static size_t parse_27(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_27(void);
static bool peak_28(ParserState *state, size_t offset, bool recover);
static size_t parse_28(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_28(void);
static bool peak_29(ParserState *state, size_t offset, bool recover);
static size_t parse_29(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_29(void);
static bool peak_30(ParserState *state, size_t offset, bool recover);
static size_t parse_30(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_30(void);
static bool peak_31(ParserState *state, size_t offset, bool recover);
static size_t parse_31(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_31(void);
static bool peak_32(ParserState *state, size_t offset, bool recover);
static size_t parse_32(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_32(void);
static bool peak_33(ParserState *state, size_t offset, bool recover);
static size_t parse_33(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_33(void);
static bool peak_34(ParserState *state, size_t offset, bool recover);
static size_t parse_34(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_34(void);
static bool peak_35(ParserState *state, size_t offset, bool recover);
static size_t parse_35(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_35(void);
static bool peak_36(ParserState *state, size_t offset, bool recover);
static size_t parse_36(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_36(void);
static bool peak_37(ParserState *state, size_t offset, bool recover);
static size_t parse_37(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_37(void);
static bool peak_38(ParserState *state, size_t offset, bool recover);
static size_t parse_38(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_38(void);
static bool peak_39(ParserState *state, size_t offset, bool recover);
static size_t parse_39(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_39(void);
static bool peak_40(ParserState *state, size_t offset, bool recover);
static size_t parse_40(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_40(void);
static bool peak_41(ParserState *state, size_t offset, bool recover);
static size_t parse_41(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_41(void);
static bool peak_42(ParserState *state, size_t offset, bool recover);
static size_t parse_42(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_42(void);
static bool peak_43(ParserState *state, size_t offset, bool recover);
static size_t parse_43(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_43(void);
static bool peak_44(ParserState *state, size_t offset, bool recover);
static size_t parse_44(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_44(void);
static bool peak_45(ParserState *state, size_t offset, bool recover);
static size_t parse_45(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_45(void);
static bool peak_46(ParserState *state, size_t offset, bool recover);
static size_t parse_46(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_46(void);
static bool peak_47(ParserState *state, size_t offset, bool recover);
static size_t parse_47(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_47(void);
static bool peak_48(ParserState *state, size_t offset, bool recover);
static size_t parse_48(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_48(void);
static bool peak_49(ParserState *state, size_t offset, bool recover);
static size_t parse_49(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_49(void);
static bool peak_50(ParserState *state, size_t offset, bool recover);
static size_t parse_50(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_50(void);
static bool peak_51(ParserState *state, size_t offset, bool recover);
static size_t parse_51(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_51(void);
static bool peak_52(ParserState *state, size_t offset, bool recover);
static size_t parse_52(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_52(void);
static bool peak_53(ParserState *state, size_t offset, bool recover);
static size_t parse_53(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_53(void);
static bool peak_54(ParserState *state, size_t offset, bool recover);
static size_t parse_54(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_54(void);
static bool peak_55(ParserState *state, size_t offset, bool recover);
static size_t parse_55(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_55(void);
static bool peak_56(ParserState *state, size_t offset, bool recover);
static size_t parse_56(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_56(void);
static bool peak_57(ParserState *state, size_t offset, bool recover);
static size_t parse_57(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_57(void);
static bool peak_58(ParserState *state, size_t offset, bool recover);
static size_t parse_58(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_58(void);
static bool peak_59(ParserState *state, size_t offset, bool recover);
static size_t parse_59(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_59(void);
static bool peak_60(ParserState *state, size_t offset, bool recover);
static size_t parse_60(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_60(void);
static bool peak_61(ParserState *state, size_t offset, bool recover);
static size_t parse_61(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_61(void);
static bool peak_62(ParserState *state, size_t offset, bool recover);
static size_t parse_62(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_62(void);
static bool peak_63(ParserState *state, size_t offset, bool recover);
static size_t parse_63(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_63(void);
static bool peak_64(ParserState *state, size_t offset, bool recover);
static size_t parse_64(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_64(void);
static bool peak_65(ParserState *state, size_t offset, bool recover);
static size_t parse_65(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_65(void);
static bool peak_66(ParserState *state, size_t offset, bool recover);
static size_t parse_66(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_66(void);
static bool peak_67(ParserState *state, size_t offset, bool recover);
static size_t parse_67(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_67(void);
static bool peak_68(ParserState *state, size_t offset, bool recover);
static size_t parse_68(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_68(void);
static bool peak_69(ParserState *state, size_t offset, bool recover);
static size_t parse_69(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_69(void);
static bool peak_70(ParserState *state, size_t offset, bool recover);
static size_t parse_70(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_70(void);
static bool peak_71(ParserState *state, size_t offset, bool recover);
static size_t parse_71(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_71(void);
static bool peak_72(ParserState *state, size_t offset, bool recover);
static size_t parse_72(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_72(void);
static bool peak_73(ParserState *state, size_t offset, bool recover);
static size_t parse_73(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_73(void);
static bool peak_74(ParserState *state, size_t offset, bool recover);
static size_t parse_74(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_74(void);
static bool peak_75(ParserState *state, size_t offset, bool recover);
static size_t parse_75(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_75(void);
static bool peak_76(ParserState *state, size_t offset, bool recover);
static size_t parse_76(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_76(void);
static bool peak_77(ParserState *state, size_t offset, bool recover);
static size_t parse_77(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_77(void);
static bool peak_78(ParserState *state, size_t offset, bool recover);
static size_t parse_78(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_78(void);
static bool peak_79(ParserState *state, size_t offset, bool recover);
static size_t parse_79(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_79(void);
static bool peak_80(ParserState *state, size_t offset, bool recover);
static size_t parse_80(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_80(void);
static bool peak_81(ParserState *state, size_t offset, bool recover);
static size_t parse_81(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_81(void);
static bool peak_82(ParserState *state, size_t offset, bool recover);
static size_t parse_82(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_82(void);
static bool peak_83(ParserState *state, size_t offset, bool recover);
static size_t parse_83(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_83(void);
static bool peak_84(ParserState *state, size_t offset, bool recover);
static size_t parse_84(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_84(void);
static bool peak_85(ParserState *state, size_t offset, bool recover);
static size_t parse_85(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_85(void);
static bool peak_86(ParserState *state, size_t offset, bool recover);
static size_t parse_86(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_86(void);
static bool peak_87(ParserState *state, size_t offset, bool recover);
static size_t parse_87(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_87(void);
static bool peak_88(ParserState *state, size_t offset, bool recover);
static size_t parse_88(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_88(void);
static bool peak_89(ParserState *state, size_t offset, bool recover);
static size_t parse_89(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_89(void);
static bool peak_90(ParserState *state, size_t offset, bool recover);
static size_t parse_90(ParserState *state, size_t unmatched_checkpoint);
static inline ExpectedVec expected_90(void);


/* Parse Just */
static size_t parse_10(ParserState *state, size_t unmatched_checkpoint) {
    (void)unmatched_checkpoint;

    for (;;) {
        /* EOF */
        if (state->offset >= state->tokens.len) {
            return 2;
        }

        uint32_t current = current_kind(state);
        if (current == (uint32_t)0) {
            bump(state);
            return 0;
        }
        if (skipped_vec_contains(&state->skipped, current)) {
            bump_skipped(state);
            continue;
        }
        break;
    }

    size_t index = state->breaks.len;
    while (index != 0) {
        index -= 1;
        PeakFunc pf = state->breaks.data[index];
        if (pf && pf(state)) {
            return index + 3;
        }
    }

    return 1;
}

/* peak_10 */
static bool peak_10(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)0) return true;
    return false;
}


/* expected_10 data */
static const Expected expected_10_data[] = {
    { .kind = 0u, .id = 0u },
};


/* expected_10: owning ExpectedVec copy */
static inline ExpectedVec expected_10(void) {
    size_t count = sizeof(expected_10_data) / sizeof(expected_10_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_10_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}



/* Parse Just */
static size_t parse_12(ParserState *state, size_t unmatched_checkpoint) {
    (void)unmatched_checkpoint;

    for (;;) {
        /* EOF */
        if (state->offset >= state->tokens.len) {
            return 2;
        }

        uint32_t current = current_kind(state);
        if (current == (uint32_t)20) {
            bump(state);
            return 0;
        }
        if (skipped_vec_contains(&state->skipped, current)) {
            bump_skipped(state);
            continue;
        }
        break;
    }

    size_t index = state->breaks.len;
    while (index != 0) {
        index -= 1;
        PeakFunc pf = state->breaks.data[index];
        if (pf && pf(state)) {
            return index + 3;
        }
    }

    return 1;
}

/* peak_12 */
static bool peak_12(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)20) return true;
    return false;
}


/* expected_12 data */
static const Expected expected_12_data[] = {
    { .kind = 0u, .id = 20u },
};


/* expected_12: owning ExpectedVec copy */
static inline ExpectedVec expected_12(void) {
    size_t count = sizeof(expected_12_data) / sizeof(expected_12_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_12_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}



/* Parse Label */
static size_t parse_11(ParserState *state, size_t unmatched_checkpoint) {
    return parse_12(state, unmatched_checkpoint);
}

/* peak_11 */
static bool peak_11(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)20) return true;
    return false;
}


/* expected_11 data */
static const Expected expected_11_data[] = {
    { .kind = 2u, .id = 1u },
};


/* expected_11: owning ExpectedVec copy */
static inline ExpectedVec expected_11(void) {
    size_t count = sizeof(expected_11_data) / sizeof(expected_11_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_11_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}


static bool break_pred_seq_9_1(ParserState *state) {
    return peak_11(state, 0, false);
}


/* Parse Seq */
static size_t parse_9(ParserState *state, size_t unmatched_checkpoint) {

    size_t brk_1 = push_break(state, break_pred_seq_9_1);

    size_t res;

    res = parse_10(state, unmatched_checkpoint);
    if (res != 0) {
        
        for(int i = 0; i < 1;i++) {
            (void)break_stack_pop(&state->breaks, NULL);
        }
        if (res >= brk_1) {
            return 1;
        }

            
        return res;
    }



    (void)break_stack_pop(&state->breaks, NULL);

    if (res >= 2 && res != brk_1) {
        ExpectedVec e = expected_11();
        missing(state, e);
    } else {
        for (;;) {
            res = parse_11(state, unmatched_checkpoint);
            if (res == 1) {
                bump_err(state);
                continue;
            }
            break;
        }
        if (res >= 2 && res != brk_1) {
            ExpectedVec e = expected_11();
            missing(state, e);
        }
    }



    return 0;
}


/* peak_9 */
static bool peak_9(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)0) return true;
    return false;
}


/* expected_9 data */
static const Expected expected_9_data[] = {
    { .kind = 0u, .id = 0u },
};


/* expected_9: owning ExpectedVec copy */
static inline ExpectedVec expected_9(void) {
    size_t count = sizeof(expected_9_data) / sizeof(expected_9_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_9_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}



/* Parse Named */
static size_t parse_7(ParserState *state, size_t unmatched_checkpoint) {
    for (;;) {
        if (state->offset >= state->tokens.len) {
            return 2; /* EOF */
        }

        if (peak_9(state, 0, false)) {
            break;
        }

        uint32_t k = current_kind(state);
        if (skipped_vec_contains(&state->skipped, k)) {
            bump_skipped(state);
            continue;
        }
        break;
    }
    size_t c = checkpoint(state);
    size_t res = parse_9(state, unmatched_checkpoint);
    if (res == 0) {
        group_at(state, c, 10);
    }
    return res;
}

/* peak_7 */
static bool peak_7(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)0) return true;
    return false;
}


/* expected_7 data */
static const Expected expected_7_data[] = {
    { .kind = 1u, .id = 10u },
};


/* expected_7: owning ExpectedVec copy */
static inline ExpectedVec expected_7(void) {
    size_t count = sizeof(expected_7_data) / sizeof(expected_7_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_7_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}



/* Parse Just */
static size_t parse_16(ParserState *state, size_t unmatched_checkpoint) {
    (void)unmatched_checkpoint;

    for (;;) {
        /* EOF */
        if (state->offset >= state->tokens.len) {
            return 2;
        }

        uint32_t current = current_kind(state);
        if (current == (uint32_t)2) {
            bump(state);
            return 0;
        }
        if (skipped_vec_contains(&state->skipped, current)) {
            bump_skipped(state);
            continue;
        }
        break;
    }

    size_t index = state->breaks.len;
    while (index != 0) {
        index -= 1;
        PeakFunc pf = state->breaks.data[index];
        if (pf && pf(state)) {
            return index + 3;
        }
    }

    return 1;
}

/* peak_16 */
static bool peak_16(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)2) return true;
    return false;
}


/* expected_16 data */
static const Expected expected_16_data[] = {
    { .kind = 0u, .id = 2u },
};


/* expected_16: owning ExpectedVec copy */
static inline ExpectedVec expected_16(void) {
    size_t count = sizeof(expected_16_data) / sizeof(expected_16_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_16_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}



/* Parse Just */
static size_t parse_17(ParserState *state, size_t unmatched_checkpoint) {
    (void)unmatched_checkpoint;

    for (;;) {
        /* EOF */
        if (state->offset >= state->tokens.len) {
            return 2;
        }

        uint32_t current = current_kind(state);
        if (current == (uint32_t)19) {
            bump(state);
            return 0;
        }
        if (skipped_vec_contains(&state->skipped, current)) {
            bump_skipped(state);
            continue;
        }
        break;
    }

    size_t index = state->breaks.len;
    while (index != 0) {
        index -= 1;
        PeakFunc pf = state->breaks.data[index];
        if (pf && pf(state)) {
            return index + 3;
        }
    }

    return 1;
}

/* peak_17 */
static bool peak_17(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)19) return true;
    return false;
}


/* expected_17 data */
static const Expected expected_17_data[] = {
    { .kind = 0u, .id = 19u },
};


/* expected_17: owning ExpectedVec copy */
static inline ExpectedVec expected_17(void) {
    size_t count = sizeof(expected_17_data) / sizeof(expected_17_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_17_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}



/* Parse Just */
static size_t parse_19(ParserState *state, size_t unmatched_checkpoint) {
    (void)unmatched_checkpoint;

    for (;;) {
        /* EOF */
        if (state->offset >= state->tokens.len) {
            return 2;
        }

        uint32_t current = current_kind(state);
        if (current == (uint32_t)22) {
            bump(state);
            return 0;
        }
        if (skipped_vec_contains(&state->skipped, current)) {
            bump_skipped(state);
            continue;
        }
        break;
    }

    size_t index = state->breaks.len;
    while (index != 0) {
        index -= 1;
        PeakFunc pf = state->breaks.data[index];
        if (pf && pf(state)) {
            return index + 3;
        }
    }

    return 1;
}

/* peak_19 */
static bool peak_19(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)22) return true;
    return false;
}


/* expected_19 data */
static const Expected expected_19_data[] = {
    { .kind = 0u, .id = 22u },
};


/* expected_19: owning ExpectedVec copy */
static inline ExpectedVec expected_19(void) {
    size_t count = sizeof(expected_19_data) / sizeof(expected_19_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_19_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}



/* Parse Label */
static size_t parse_18(ParserState *state, size_t unmatched_checkpoint) {
    return parse_19(state, unmatched_checkpoint);
}

/* peak_18 */
static bool peak_18(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)22) return true;
    return false;
}


/* expected_18 data */
static const Expected expected_18_data[] = {
    { .kind = 2u, .id = 2u },
};


/* expected_18: owning ExpectedVec copy */
static inline ExpectedVec expected_18(void) {
    size_t count = sizeof(expected_18_data) / sizeof(expected_18_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_18_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}


static bool break_pred_seq_15_1(ParserState *state) {
    return peak_11(state, 0, false);
}


static bool break_pred_seq_15_2(ParserState *state) {
    return peak_17(state, 0, false);
}


static bool break_pred_seq_15_3(ParserState *state) {
    return peak_18(state, 0, false);
}


/* Parse Seq */
static size_t parse_15(ParserState *state, size_t unmatched_checkpoint) {

    size_t brk_3 = push_break(state, break_pred_seq_15_3);
    size_t brk_2 = push_break(state, break_pred_seq_15_2);
    size_t brk_1 = push_break(state, break_pred_seq_15_1);

    size_t res;

    res = parse_16(state, unmatched_checkpoint);
    if (res != 0) {
        
        for(int i = 0; i < 3;i++) {
            (void)break_stack_pop(&state->breaks, NULL);
        }
        if (res >= brk_3) {
            return 1;
        }

            
        return res;
    }



    (void)break_stack_pop(&state->breaks, NULL);

    if (res >= 2 && res != brk_1) {
        ExpectedVec e = expected_11();
        missing(state, e);
    } else {
        for (;;) {
            res = parse_11(state, unmatched_checkpoint);
            if (res == 1) {
                bump_err(state);
                continue;
            }
            break;
        }
        if (res >= 2 && res != brk_1) {
            ExpectedVec e = expected_11();
            missing(state, e);
        }
    }



    (void)break_stack_pop(&state->breaks, NULL);

    if (res >= 2 && res != brk_2) {
        ExpectedVec e = expected_17();
        missing(state, e);
    } else {
        for (;;) {
            res = parse_17(state, unmatched_checkpoint);
            if (res == 1) {
                bump_err(state);
                continue;
            }
            break;
        }
        if (res >= 2 && res != brk_2) {
            ExpectedVec e = expected_17();
            missing(state, e);
        }
    }



    (void)break_stack_pop(&state->breaks, NULL);

    if (res >= 2 && res != brk_3) {
        ExpectedVec e = expected_18();
        missing(state, e);
    } else {
        for (;;) {
            res = parse_18(state, unmatched_checkpoint);
            if (res == 1) {
                bump_err(state);
                continue;
            }
            break;
        }
        if (res >= 2 && res != brk_3) {
            ExpectedVec e = expected_18();
            missing(state, e);
        }
    }



    return 0;
}


/* peak_15 */
static bool peak_15(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)2) return true;
    return false;
}


/* expected_15 data */
static const Expected expected_15_data[] = {
    { .kind = 0u, .id = 2u },
};


/* expected_15: owning ExpectedVec copy */
static inline ExpectedVec expected_15(void) {
    size_t count = sizeof(expected_15_data) / sizeof(expected_15_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_15_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}



/* Parse Named */
static size_t parse_13(ParserState *state, size_t unmatched_checkpoint) {
    for (;;) {
        if (state->offset >= state->tokens.len) {
            return 2; /* EOF */
        }

        if (peak_15(state, 0, false)) {
            break;
        }

        uint32_t k = current_kind(state);
        if (skipped_vec_contains(&state->skipped, k)) {
            bump_skipped(state);
            continue;
        }
        break;
    }
    size_t c = checkpoint(state);
    size_t res = parse_15(state, unmatched_checkpoint);
    if (res == 0) {
        group_at(state, c, 11);
    }
    return res;
}

/* peak_13 */
static bool peak_13(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)2) return true;
    return false;
}


/* expected_13 data */
static const Expected expected_13_data[] = {
    { .kind = 1u, .id = 11u },
};


/* expected_13: owning ExpectedVec copy */
static inline ExpectedVec expected_13(void) {
    size_t count = sizeof(expected_13_data) / sizeof(expected_13_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_13_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}



/* Parse Just */
static size_t parse_23(ParserState *state, size_t unmatched_checkpoint) {
    (void)unmatched_checkpoint;

    for (;;) {
        /* EOF */
        if (state->offset >= state->tokens.len) {
            return 2;
        }

        uint32_t current = current_kind(state);
        if (current == (uint32_t)1) {
            bump(state);
            return 0;
        }
        if (skipped_vec_contains(&state->skipped, current)) {
            bump_skipped(state);
            continue;
        }
        break;
    }

    size_t index = state->breaks.len;
    while (index != 0) {
        index -= 1;
        PeakFunc pf = state->breaks.data[index];
        if (pf && pf(state)) {
            return index + 3;
        }
    }

    return 1;
}

/* peak_23 */
static bool peak_23(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)1) return true;
    return false;
}


/* expected_23 data */
static const Expected expected_23_data[] = {
    { .kind = 0u, .id = 1u },
};


/* expected_23: owning ExpectedVec copy */
static inline ExpectedVec expected_23(void) {
    size_t count = sizeof(expected_23_data) / sizeof(expected_23_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_23_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}



/* Parse Label */
static size_t parse_24(ParserState *state, size_t unmatched_checkpoint) {
    return parse_12(state, unmatched_checkpoint);
}

/* peak_24 */
static bool peak_24(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)20) return true;
    return false;
}


/* expected_24 data */
static const Expected expected_24_data[] = {
    { .kind = 2u, .id = 3u },
};


/* expected_24: owning ExpectedVec copy */
static inline ExpectedVec expected_24(void) {
    size_t count = sizeof(expected_24_data) / sizeof(expected_24_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_24_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}



/* Parse Just */
static size_t parse_43(ParserState *state, size_t unmatched_checkpoint) {
    (void)unmatched_checkpoint;

    for (;;) {
        /* EOF */
        if (state->offset >= state->tokens.len) {
            return 2;
        }

        uint32_t current = current_kind(state);
        if (current == (uint32_t)14) {
            bump(state);
            return 0;
        }
        if (skipped_vec_contains(&state->skipped, current)) {
            bump_skipped(state);
            continue;
        }
        break;
    }

    size_t index = state->breaks.len;
    while (index != 0) {
        index -= 1;
        PeakFunc pf = state->breaks.data[index];
        if (pf && pf(state)) {
            return index + 3;
        }
    }

    return 1;
}

/* peak_43 */
static bool peak_43(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)14) return true;
    return false;
}


/* expected_43 data */
static const Expected expected_43_data[] = {
    { .kind = 0u, .id = 14u },
};


/* expected_43: owning ExpectedVec copy */
static inline ExpectedVec expected_43(void) {
    size_t count = sizeof(expected_43_data) / sizeof(expected_43_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_43_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}



/* Parse Just */
static size_t parse_44(ParserState *state, size_t unmatched_checkpoint) {
    (void)unmatched_checkpoint;

    for (;;) {
        /* EOF */
        if (state->offset >= state->tokens.len) {
            return 2;
        }

        uint32_t current = current_kind(state);
        if (current == (uint32_t)15) {
            bump(state);
            return 0;
        }
        if (skipped_vec_contains(&state->skipped, current)) {
            bump_skipped(state);
            continue;
        }
        break;
    }

    size_t index = state->breaks.len;
    while (index != 0) {
        index -= 1;
        PeakFunc pf = state->breaks.data[index];
        if (pf && pf(state)) {
            return index + 3;
        }
    }

    return 1;
}

/* peak_44 */
static bool peak_44(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)15) return true;
    return false;
}


/* expected_44 data */
static const Expected expected_44_data[] = {
    { .kind = 0u, .id = 15u },
};


/* expected_44: owning ExpectedVec copy */
static inline ExpectedVec expected_44(void) {
    size_t count = sizeof(expected_44_data) / sizeof(expected_44_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_44_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}


static bool break_pred_seq_42_1(ParserState *state) {
    return peak_27(state, 0, false);
}


static bool break_pred_seq_42_2(ParserState *state) {
    return peak_44(state, 0, false);
}


/* Parse Seq */
static size_t parse_42(ParserState *state, size_t unmatched_checkpoint) {

    size_t brk_2 = push_break(state, break_pred_seq_42_2);
    size_t brk_1 = push_break(state, break_pred_seq_42_1);

    size_t res;

    res = parse_43(state, unmatched_checkpoint);
    if (res != 0) {
        
        for(int i = 0; i < 2;i++) {
            (void)break_stack_pop(&state->breaks, NULL);
        }
        if (res >= brk_2) {
            return 1;
        }

            
        return res;
    }



    (void)break_stack_pop(&state->breaks, NULL);

    if (res >= 2 && res != brk_1) {
        ExpectedVec e = expected_27();
        missing(state, e);
    } else {
        for (;;) {
            res = parse_27(state, unmatched_checkpoint);
            if (res == 1) {
                bump_err(state);
                continue;
            }
            break;
        }
        if (res >= 2 && res != brk_1) {
            ExpectedVec e = expected_27();
            missing(state, e);
        }
    }



    (void)break_stack_pop(&state->breaks, NULL);

    if (res >= 2 && res != brk_2) {
        ExpectedVec e = expected_44();
        missing(state, e);
    } else {
        for (;;) {
            res = parse_44(state, unmatched_checkpoint);
            if (res == 1) {
                bump_err(state);
                continue;
            }
            break;
        }
        if (res >= 2 && res != brk_2) {
            ExpectedVec e = expected_44();
            missing(state, e);
        }
    }



    return 0;
}


/* peak_42 */
static bool peak_42(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)14) return true;
    return false;
}


/* expected_42 data */
static const Expected expected_42_data[] = {
    { .kind = 0u, .id = 14u },
};


/* expected_42: owning ExpectedVec copy */
static inline ExpectedVec expected_42(void) {
    size_t count = sizeof(expected_42_data) / sizeof(expected_42_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_42_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}



/* Parse Named */
static size_t parse_40(ParserState *state, size_t unmatched_checkpoint) {
    for (;;) {
        if (state->offset >= state->tokens.len) {
            return 2; /* EOF */
        }

        if (peak_42(state, 0, false)) {
            break;
        }

        uint32_t k = current_kind(state);
        if (skipped_vec_contains(&state->skipped, k)) {
            bump_skipped(state);
            continue;
        }
        break;
    }
    size_t c = checkpoint(state);
    size_t res = parse_42(state, unmatched_checkpoint);
    if (res == 0) {
        group_at(state, c, 1);
    }
    return res;
}

/* peak_40 */
static bool peak_40(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)14) return true;
    return false;
}


/* expected_40 data */
static const Expected expected_40_data[] = {
    { .kind = 1u, .id = 1u },
};


/* expected_40: owning ExpectedVec copy */
static inline ExpectedVec expected_40(void) {
    size_t count = sizeof(expected_40_data) / sizeof(expected_40_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_40_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}



/* Parse Named */
static size_t parse_45(ParserState *state, size_t unmatched_checkpoint) {
    for (;;) {
        if (state->offset >= state->tokens.len) {
            return 2; /* EOF */
        }

        if (peak_12(state, 0, false)) {
            break;
        }

        uint32_t k = current_kind(state);
        if (skipped_vec_contains(&state->skipped, k)) {
            bump_skipped(state);
            continue;
        }
        break;
    }
    size_t c = checkpoint(state);
    size_t res = parse_12(state, unmatched_checkpoint);
    if (res == 0) {
        group_at(state, c, 0);
    }
    return res;
}

/* peak_45 */
static bool peak_45(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)20) return true;
    return false;
}


/* expected_45 data */
static const Expected expected_45_data[] = {
    { .kind = 1u, .id = 0u },
};


/* expected_45: owning ExpectedVec copy */
static inline ExpectedVec expected_45(void) {
    size_t count = sizeof(expected_45_data) / sizeof(expected_45_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_45_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}


/* Build Choice */
static size_t parse_39(ParserState *state, size_t unmatched_checkpoint) {

    size_t res = 1;

    res = parse_40(state, unmatched_checkpoint);
    if (res == 0) {
        return 0;
    }


    res = parse_45(state, unmatched_checkpoint);
    if (res == 0) {
        return 0;
    }

    return res;
}


/* peak_39 */
static bool peak_39(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)14) return true;
    if (current == (uint32_t)20) return true;
    return false;
}


/* expected_39 data */
static const Expected expected_39_data[] = {
    { .kind = 1u, .id = 1u },
    { .kind = 1u, .id = 0u },
};


/* expected_39: owning ExpectedVec copy */
static inline ExpectedVec expected_39(void) {
    size_t count = sizeof(expected_39_data) / sizeof(expected_39_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_39_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}



/* Parse Label */
static size_t parse_37(ParserState *state, size_t unmatched_checkpoint) {
    return parse_39(state, unmatched_checkpoint);
}

/* peak_37 */
static bool peak_37(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)14) return true;
    if (current == (uint32_t)20) return true;
    return false;
}


/* expected_37 data */
static const Expected expected_37_data[] = {
    { .kind = 2u, .id = 0u },
};


/* expected_37: owning ExpectedVec copy */
static inline ExpectedVec expected_37(void) {
    size_t count = sizeof(expected_37_data) / sizeof(expected_37_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_37_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}



/* Parse Just */
static size_t parse_51(ParserState *state, size_t unmatched_checkpoint) {
    (void)unmatched_checkpoint;

    for (;;) {
        /* EOF */
        if (state->offset >= state->tokens.len) {
            return 2;
        }

        uint32_t current = current_kind(state);
        if (current == (uint32_t)11) {
            bump(state);
            return 0;
        }
        if (skipped_vec_contains(&state->skipped, current)) {
            bump_skipped(state);
            continue;
        }
        break;
    }

    size_t index = state->breaks.len;
    while (index != 0) {
        index -= 1;
        PeakFunc pf = state->breaks.data[index];
        if (pf && pf(state)) {
            return index + 3;
        }
    }

    return 1;
}

/* peak_51 */
static bool peak_51(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)11) return true;
    return false;
}


/* expected_51 data */
static const Expected expected_51_data[] = {
    { .kind = 0u, .id = 11u },
};


/* expected_51: owning ExpectedVec copy */
static inline ExpectedVec expected_51(void) {
    size_t count = sizeof(expected_51_data) / sizeof(expected_51_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_51_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}



/* Parse Named */
static size_t parse_52(ParserState *state, size_t unmatched_checkpoint) {
    for (;;) {
        if (state->offset >= state->tokens.len) {
            return 2; /* EOF */
        }

        if (peak_12(state, 0, false)) {
            break;
        }

        uint32_t k = current_kind(state);
        if (skipped_vec_contains(&state->skipped, k)) {
            bump_skipped(state);
            continue;
        }
        break;
    }
    size_t c = checkpoint(state);
    size_t res = parse_12(state, unmatched_checkpoint);
    if (res == 0) {
        group_at(state, c, 3);
    }
    return res;
}

/* peak_52 */
static bool peak_52(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)20) return true;
    return false;
}


/* expected_52 data */
static const Expected expected_52_data[] = {
    { .kind = 1u, .id = 3u },
};


/* expected_52: owning ExpectedVec copy */
static inline ExpectedVec expected_52(void) {
    size_t count = sizeof(expected_52_data) / sizeof(expected_52_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_52_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}



/* Parse Just */
static size_t parse_59(ParserState *state, size_t unmatched_checkpoint) {
    (void)unmatched_checkpoint;

    for (;;) {
        /* EOF */
        if (state->offset >= state->tokens.len) {
            return 2;
        }

        uint32_t current = current_kind(state);
        if (current == (uint32_t)9) {
            bump(state);
            return 0;
        }
        if (skipped_vec_contains(&state->skipped, current)) {
            bump_skipped(state);
            continue;
        }
        break;
    }

    size_t index = state->breaks.len;
    while (index != 0) {
        index -= 1;
        PeakFunc pf = state->breaks.data[index];
        if (pf && pf(state)) {
            return index + 3;
        }
    }

    return 1;
}

/* peak_59 */
static bool peak_59(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)9) return true;
    return false;
}


/* expected_59 data */
static const Expected expected_59_data[] = {
    { .kind = 0u, .id = 9u },
};


/* expected_59: owning ExpectedVec copy */
static inline ExpectedVec expected_59(void) {
    size_t count = sizeof(expected_59_data) / sizeof(expected_59_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_59_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}


static bool break_pred_sep_58_item(ParserState *state) {
    return peak_27(state, 0, false);
}

static bool break_pred_sep_58_sep(ParserState *state) {
    return peak_59(state, 0, false);
}


/* Parse Sep */
static size_t parse_58(ParserState *state, size_t unmatched_checkpoint) {
    size_t item_brk = push_break(state, break_pred_sep_58_item);
    size_t sep_brk  = push_break(state, break_pred_sep_58_sep);
    size_t res = 0;
    res = parse_27(state, unmatched_checkpoint);
    if (res != 0) {
        if (res == sep_brk) {
            return 1;
        }
        return res;
    }
    for (;;) {
        for (;;) {
            res = parse_59(state, unmatched_checkpoint);
            if (res == 1) {
                bump_err(state);
                continue;
            }
            break;
        }

        if (res != 0) {
            if (res == item_brk) {
                ExpectedVec e = expected_59();
                missing(state, e);
            } else {
                goto ret_ok;
            }
        }
        for (;;) {
            res = parse_27(state, unmatched_checkpoint);
            if (res == 1) {
                bump_err(state);
                continue;
            }
            break;
        }

        if (res == 0) {
            continue;
        }

        {
            ExpectedVec e = expected_27();
            missing(state, e);
            if (res == sep_brk) {
                continue;
            }
            goto ret_ok;
        }
    }

ret_ok:
    (void)break_stack_pop(&state->breaks, NULL);
    (void)break_stack_pop(&state->breaks, NULL);
    return 0;

ret_err:
    (void)break_stack_pop(&state->breaks, NULL);
    (void)break_stack_pop(&state->breaks, NULL);
    return res;
}


/* peak_58 */
static bool peak_58(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)14) return true;
    if (current == (uint32_t)20) return true;
    return false;
}


/* expected_58 data */
static const Expected expected_58_data[] = {
    { .kind = 2u, .id = 0u },
};


/* expected_58: owning ExpectedVec copy */
static inline ExpectedVec expected_58(void) {
    size_t count = sizeof(expected_58_data) / sizeof(expected_58_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_58_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}



/* Parse Optional */
static size_t parse_57(ParserState *state, size_t unmatched_checkpoint) {
    return parse_58(state, unmatched_checkpoint);
}

/* peak_57 */
static bool peak_57(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)14) return true;
    if (current == (uint32_t)20) return true;
    return false;
}


/* expected_57: optional => empty */
static inline ExpectedVec expected_57(void) {
    return (ExpectedVec){ .data = NULL, .len = 0, .cap = 0 };
}


static bool break_pred_seq_56_1(ParserState *state) {
    return peak_57(state, 0, false);
}


static bool break_pred_seq_56_2(ParserState *state) {
    return peak_44(state, 0, false);
}


/* Parse Seq */
static size_t parse_56(ParserState *state, size_t unmatched_checkpoint) {

    size_t brk_2 = push_break(state, break_pred_seq_56_2);
    size_t brk_1 = push_break(state, break_pred_seq_56_1);

    size_t res;

    res = parse_43(state, unmatched_checkpoint);
    if (res != 0) {
        
        for(int i = 0; i < 2;i++) {
            (void)break_stack_pop(&state->breaks, NULL);
        }
        if (res >= brk_2) {
            return 1;
        }

            
        return res;
    }



    (void)break_stack_pop(&state->breaks, NULL);

    if (res >= 2 && res != brk_1) {
        ExpectedVec e = expected_57();
        missing(state, e);
    } else {
        for (;;) {
            res = parse_57(state, unmatched_checkpoint);
            if (res == 1) {
                bump_err(state);
                continue;
            }
            break;
        }
        if (res >= 2 && res != brk_1) {
            ExpectedVec e = expected_57();
            missing(state, e);
        }
    }



    (void)break_stack_pop(&state->breaks, NULL);

    if (res >= 2 && res != brk_2) {
        ExpectedVec e = expected_44();
        missing(state, e);
    } else {
        for (;;) {
            res = parse_44(state, unmatched_checkpoint);
            if (res == 1) {
                bump_err(state);
                continue;
            }
            break;
        }
        if (res >= 2 && res != brk_2) {
            ExpectedVec e = expected_44();
            missing(state, e);
        }
    }



    return 0;
}


/* peak_56 */
static bool peak_56(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)14) return true;
    return false;
}


/* expected_56 data */
static const Expected expected_56_data[] = {
    { .kind = 0u, .id = 14u },
};


/* expected_56: owning ExpectedVec copy */
static inline ExpectedVec expected_56(void) {
    size_t count = sizeof(expected_56_data) / sizeof(expected_56_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_56_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}



/* Parse Named */
static size_t parse_54(ParserState *state, size_t unmatched_checkpoint) {
    for (;;) {
        if (state->offset >= state->tokens.len) {
            return 2; /* EOF */
        }

        if (peak_56(state, 0, false)) {
            break;
        }

        uint32_t k = current_kind(state);
        if (skipped_vec_contains(&state->skipped, k)) {
            bump_skipped(state);
            continue;
        }
        break;
    }
    size_t c = checkpoint(state);
    size_t res = parse_56(state, unmatched_checkpoint);
    if (res == 0) {
        group_at(state, c, 4);
    }
    return res;
}

/* peak_54 */
static bool peak_54(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)14) return true;
    return false;
}


/* expected_54 data */
static const Expected expected_54_data[] = {
    { .kind = 1u, .id = 4u },
};


/* expected_54: owning ExpectedVec copy */
static inline ExpectedVec expected_54(void) {
    size_t count = sizeof(expected_54_data) / sizeof(expected_54_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_54_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}


static bool break_pred_seq_50_1(ParserState *state) {
    return peak_52(state, 0, false);
}


static bool break_pred_seq_50_2(ParserState *state) {
    return peak_54(state, 0, false);
}


/* Parse Seq */
static size_t parse_50(ParserState *state, size_t unmatched_checkpoint) {

    size_t brk_2 = push_break(state, break_pred_seq_50_2);
    size_t brk_1 = push_break(state, break_pred_seq_50_1);

    size_t res;

    res = parse_51(state, unmatched_checkpoint);
    if (res != 0) {
        
        for(int i = 0; i < 2;i++) {
            (void)break_stack_pop(&state->breaks, NULL);
        }
        if (res >= brk_2) {
            return 1;
        }

            
        return res;
    }



    (void)break_stack_pop(&state->breaks, NULL);

    if (res >= 2 && res != brk_1) {
        ExpectedVec e = expected_52();
        missing(state, e);
    } else {
        for (;;) {
            res = parse_52(state, unmatched_checkpoint);
            if (res == 1) {
                bump_err(state);
                continue;
            }
            break;
        }
        if (res >= 2 && res != brk_1) {
            ExpectedVec e = expected_52();
            missing(state, e);
        }
    }



    (void)break_stack_pop(&state->breaks, NULL);

    if (res >= 2 && res != brk_2) {
        ExpectedVec e = expected_54();
        missing(state, e);
    } else {
        for (;;) {
            res = parse_54(state, unmatched_checkpoint);
            if (res == 1) {
                bump_err(state);
                continue;
            }
            break;
        }
        if (res >= 2 && res != brk_2) {
            ExpectedVec e = expected_54();
            missing(state, e);
        }
    }



    return 0;
}


/* peak_50 */
static bool peak_50(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)11) return true;
    return false;
}


/* expected_50 data */
static const Expected expected_50_data[] = {
    { .kind = 0u, .id = 11u },
};


/* expected_50: owning ExpectedVec copy */
static inline ExpectedVec expected_50(void) {
    size_t count = sizeof(expected_50_data) / sizeof(expected_50_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_50_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}



/* Parse Named */
static size_t parse_48(ParserState *state, size_t unmatched_checkpoint) {
    for (;;) {
        if (state->offset >= state->tokens.len) {
            return 2; /* EOF */
        }

        if (peak_50(state, 0, false)) {
            break;
        }

        uint32_t k = current_kind(state);
        if (skipped_vec_contains(&state->skipped, k)) {
            bump_skipped(state);
            continue;
        }
        break;
    }
    size_t c = checkpoint(state);
    size_t res = parse_50(state, unmatched_checkpoint);
    if (res == 0) {
        group_at(state, c, 5);
    }
    return res;
}

/* peak_48 */
static bool peak_48(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)11) return true;
    return false;
}


/* expected_48 data */
static const Expected expected_48_data[] = {
    { .kind = 1u, .id = 5u },
};


/* expected_48: owning ExpectedVec copy */
static inline ExpectedVec expected_48(void) {
    size_t count = sizeof(expected_48_data) / sizeof(expected_48_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_48_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}


static bool break_pred_rep0_47(ParserState *state) {
    return peak_48(state, 0, false);
}


/* Parse Rep0 */
static size_t parse_47(ParserState *state, size_t unmatched_checkpoint) {
    size_t brk = push_break(state, break_pred_rep0_47);
    size_t res = parse_48(state, unmatched_checkpoint);
    if(res != 0) {
        (void)break_stack_pop(&state->breaks, NULL);
        if (res == brk) {
            return 1;
        }
        return res;
    }
    for (;;) {
        size_t res = parse_48(state, unmatched_checkpoint);

        if (res == 0) {
            continue;
        }

        if (res == 1) {
            bump_err(state);
            continue;
        }

        if (res == brk) {
            continue;
        }
        break;
    }

    (void)break_stack_pop(&state->breaks, NULL);
    return 0;
}

/* peak_47 */
static bool peak_47(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)11) return true;
    return false;
}


/* expected_47: optional => empty */
static inline ExpectedVec expected_47(void) {
    return (ExpectedVec){ .data = NULL, .len = 0, .cap = 0 };
}


static bool break_pred_35(ParserState *state) {
    return peak_47(state, 0, false);
}


/* Parse Fold */
static size_t parse_35(ParserState *state, size_t unmatched_checkpoint) {
    for (;;) {
        if (state->offset >= state->tokens.len) {
            return 2; /* EOF */
        }

        if (peak_37(state, 0, false)) {
            break;
        }

        uint32_t k = current_kind(state);
        if (skipped_vec_contains(&state->skipped, k)) {
            bump_skipped(state);
            continue;
        }
        break;
    }

    size_t c = checkpoint(state);
    size_t break_code = push_break(state, break_pred_35);
    size_t res = parse_37(state, unmatched_checkpoint);
    (void)break_stack_pop(&state->breaks, NULL);
    if (res != 0) {
        if (res == break_code) {
            return 1;
        }
        return res;
    }
    for(;;){
        size_t res_next = parse_47(state, unmatched_checkpoint);
        if (res_next == 1) {
            bump_err(state);
            continue;
        }
        if (res_next != 0) {
            return 0;
        }
        (void)group_at(state, c, 6);
        return 0;
    }
}


/* peak_35 */
static bool peak_35(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)20) return true;
    if (current == (uint32_t)14) return true;
    return false;
}


/* expected_35 data */
static const Expected expected_35_data[] = {
    { .kind = 2u, .id = 0u },
};


/* expected_35: owning ExpectedVec copy */
static inline ExpectedVec expected_35(void) {
    size_t count = sizeof(expected_35_data) / sizeof(expected_35_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_35_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}



/* Parse Label */
static size_t parse_34(ParserState *state, size_t unmatched_checkpoint) {
    return parse_35(state, unmatched_checkpoint);
}

/* peak_34 */
static bool peak_34(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)20) return true;
    if (current == (uint32_t)14) return true;
    return false;
}


/* expected_34 data */
static const Expected expected_34_data[] = {
    { .kind = 2u, .id = 0u },
};


/* expected_34: owning ExpectedVec copy */
static inline ExpectedVec expected_34(void) {
    size_t count = sizeof(expected_34_data) / sizeof(expected_34_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_34_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}



/* Parse Just */
static size_t parse_62(ParserState *state, size_t unmatched_checkpoint) {
    (void)unmatched_checkpoint;

    for (;;) {
        /* EOF */
        if (state->offset >= state->tokens.len) {
            return 2;
        }

        uint32_t current = current_kind(state);
        if (current == (uint32_t)18) {
            bump(state);
            return 0;
        }
        if (skipped_vec_contains(&state->skipped, current)) {
            bump_skipped(state);
            continue;
        }
        break;
    }

    size_t index = state->breaks.len;
    while (index != 0) {
        index -= 1;
        PeakFunc pf = state->breaks.data[index];
        if (pf && pf(state)) {
            return index + 3;
        }
    }

    return 1;
}

/* peak_62 */
static bool peak_62(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)18) return true;
    return false;
}


/* expected_62 data */
static const Expected expected_62_data[] = {
    { .kind = 0u, .id = 18u },
};


/* expected_62: owning ExpectedVec copy */
static inline ExpectedVec expected_62(void) {
    size_t count = sizeof(expected_62_data) / sizeof(expected_62_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_62_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}


static bool break_pred_seq_61_1(ParserState *state) {
    return peak_34(state, 0, false);
}


/* Parse Seq */
static size_t parse_61(ParserState *state, size_t unmatched_checkpoint) {

    size_t brk_1 = push_break(state, break_pred_seq_61_1);

    size_t res;

    res = parse_62(state, unmatched_checkpoint);
    if (res != 0) {
        
        for(int i = 0; i < 1;i++) {
            (void)break_stack_pop(&state->breaks, NULL);
        }
        if (res >= brk_1) {
            return 1;
        }

            
        return res;
    }



    (void)break_stack_pop(&state->breaks, NULL);

    if (res >= 2 && res != brk_1) {
        ExpectedVec e = expected_34();
        missing(state, e);
    } else {
        for (;;) {
            res = parse_34(state, unmatched_checkpoint);
            if (res == 1) {
                bump_err(state);
                continue;
            }
            break;
        }
        if (res >= 2 && res != brk_1) {
            ExpectedVec e = expected_34();
            missing(state, e);
        }
    }



    return 0;
}


/* peak_61 */
static bool peak_61(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)18) return true;
    return false;
}


/* expected_61 data */
static const Expected expected_61_data[] = {
    { .kind = 0u, .id = 18u },
};


/* expected_61: owning ExpectedVec copy */
static inline ExpectedVec expected_61(void) {
    size_t count = sizeof(expected_61_data) / sizeof(expected_61_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_61_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}


static bool break_pred_rep0_60(ParserState *state) {
    return peak_61(state, 0, false);
}


/* Parse Rep0 */
static size_t parse_60(ParserState *state, size_t unmatched_checkpoint) {
    size_t brk = push_break(state, break_pred_rep0_60);
    size_t res = parse_61(state, unmatched_checkpoint);
    if(res != 0) {
        (void)break_stack_pop(&state->breaks, NULL);
        if (res == brk) {
            return 1;
        }
        return res;
    }
    for (;;) {
        size_t res = parse_61(state, unmatched_checkpoint);

        if (res == 0) {
            continue;
        }

        if (res == 1) {
            bump_err(state);
            continue;
        }

        if (res == brk) {
            continue;
        }
        break;
    }

    (void)break_stack_pop(&state->breaks, NULL);
    return 0;
}

/* peak_60 */
static bool peak_60(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)18) return true;
    return false;
}


/* expected_60: optional => empty */
static inline ExpectedVec expected_60(void) {
    return (ExpectedVec){ .data = NULL, .len = 0, .cap = 0 };
}


static bool break_pred_32(ParserState *state) {
    return peak_60(state, 0, false);
}


/* Parse Fold */
static size_t parse_32(ParserState *state, size_t unmatched_checkpoint) {
    for (;;) {
        if (state->offset >= state->tokens.len) {
            return 2; /* EOF */
        }

        if (peak_34(state, 0, false)) {
            break;
        }

        uint32_t k = current_kind(state);
        if (skipped_vec_contains(&state->skipped, k)) {
            bump_skipped(state);
            continue;
        }
        break;
    }

    size_t c = checkpoint(state);
    size_t break_code = push_break(state, break_pred_32);
    size_t res = parse_34(state, unmatched_checkpoint);
    (void)break_stack_pop(&state->breaks, NULL);
    if (res != 0) {
        if (res == break_code) {
            return 1;
        }
        return res;
    }
    for(;;){
        size_t res_next = parse_60(state, unmatched_checkpoint);
        if (res_next == 1) {
            bump_err(state);
            continue;
        }
        if (res_next != 0) {
            return 0;
        }
        (void)group_at(state, c, 7);
        return 0;
    }
}


/* peak_32 */
static bool peak_32(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)20) return true;
    if (current == (uint32_t)14) return true;
    return false;
}


/* expected_32 data */
static const Expected expected_32_data[] = {
    { .kind = 2u, .id = 0u },
};


/* expected_32: owning ExpectedVec copy */
static inline ExpectedVec expected_32(void) {
    size_t count = sizeof(expected_32_data) / sizeof(expected_32_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_32_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}



/* Parse Label */
static size_t parse_31(ParserState *state, size_t unmatched_checkpoint) {
    return parse_32(state, unmatched_checkpoint);
}

/* peak_31 */
static bool peak_31(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)20) return true;
    if (current == (uint32_t)14) return true;
    return false;
}


/* expected_31 data */
static const Expected expected_31_data[] = {
    { .kind = 2u, .id = 0u },
};


/* expected_31: owning ExpectedVec copy */
static inline ExpectedVec expected_31(void) {
    size_t count = sizeof(expected_31_data) / sizeof(expected_31_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_31_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}



/* Parse Just */
static size_t parse_65(ParserState *state, size_t unmatched_checkpoint) {
    (void)unmatched_checkpoint;

    for (;;) {
        /* EOF */
        if (state->offset >= state->tokens.len) {
            return 2;
        }

        uint32_t current = current_kind(state);
        if (current == (uint32_t)10) {
            bump(state);
            return 0;
        }
        if (skipped_vec_contains(&state->skipped, current)) {
            bump_skipped(state);
            continue;
        }
        break;
    }

    size_t index = state->breaks.len;
    while (index != 0) {
        index -= 1;
        PeakFunc pf = state->breaks.data[index];
        if (pf && pf(state)) {
            return index + 3;
        }
    }

    return 1;
}

/* peak_65 */
static bool peak_65(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)10) return true;
    return false;
}


/* expected_65 data */
static const Expected expected_65_data[] = {
    { .kind = 0u, .id = 10u },
};


/* expected_65: owning ExpectedVec copy */
static inline ExpectedVec expected_65(void) {
    size_t count = sizeof(expected_65_data) / sizeof(expected_65_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_65_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}


static bool break_pred_seq_64_1(ParserState *state) {
    return peak_31(state, 0, false);
}


/* Parse Seq */
static size_t parse_64(ParserState *state, size_t unmatched_checkpoint) {

    size_t brk_1 = push_break(state, break_pred_seq_64_1);

    size_t res;

    res = parse_65(state, unmatched_checkpoint);
    if (res != 0) {
        
        for(int i = 0; i < 1;i++) {
            (void)break_stack_pop(&state->breaks, NULL);
        }
        if (res >= brk_1) {
            return 1;
        }

            
        return res;
    }



    (void)break_stack_pop(&state->breaks, NULL);

    if (res >= 2 && res != brk_1) {
        ExpectedVec e = expected_31();
        missing(state, e);
    } else {
        for (;;) {
            res = parse_31(state, unmatched_checkpoint);
            if (res == 1) {
                bump_err(state);
                continue;
            }
            break;
        }
        if (res >= 2 && res != brk_1) {
            ExpectedVec e = expected_31();
            missing(state, e);
        }
    }



    return 0;
}


/* peak_64 */
static bool peak_64(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)10) return true;
    return false;
}


/* expected_64 data */
static const Expected expected_64_data[] = {
    { .kind = 0u, .id = 10u },
};


/* expected_64: owning ExpectedVec copy */
static inline ExpectedVec expected_64(void) {
    size_t count = sizeof(expected_64_data) / sizeof(expected_64_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_64_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}


static bool break_pred_rep0_63(ParserState *state) {
    return peak_64(state, 0, false);
}


/* Parse Rep0 */
static size_t parse_63(ParserState *state, size_t unmatched_checkpoint) {
    size_t brk = push_break(state, break_pred_rep0_63);
    size_t res = parse_64(state, unmatched_checkpoint);
    if(res != 0) {
        (void)break_stack_pop(&state->breaks, NULL);
        if (res == brk) {
            return 1;
        }
        return res;
    }
    for (;;) {
        size_t res = parse_64(state, unmatched_checkpoint);

        if (res == 0) {
            continue;
        }

        if (res == 1) {
            bump_err(state);
            continue;
        }

        if (res == brk) {
            continue;
        }
        break;
    }

    (void)break_stack_pop(&state->breaks, NULL);
    return 0;
}

/* peak_63 */
static bool peak_63(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)10) return true;
    return false;
}


/* expected_63: optional => empty */
static inline ExpectedVec expected_63(void) {
    return (ExpectedVec){ .data = NULL, .len = 0, .cap = 0 };
}


static bool break_pred_29(ParserState *state) {
    return peak_63(state, 0, false);
}


/* Parse Fold */
static size_t parse_29(ParserState *state, size_t unmatched_checkpoint) {
    for (;;) {
        if (state->offset >= state->tokens.len) {
            return 2; /* EOF */
        }

        if (peak_31(state, 0, false)) {
            break;
        }

        uint32_t k = current_kind(state);
        if (skipped_vec_contains(&state->skipped, k)) {
            bump_skipped(state);
            continue;
        }
        break;
    }

    size_t c = checkpoint(state);
    size_t break_code = push_break(state, break_pred_29);
    size_t res = parse_31(state, unmatched_checkpoint);
    (void)break_stack_pop(&state->breaks, NULL);
    if (res != 0) {
        if (res == break_code) {
            return 1;
        }
        return res;
    }
    for(;;){
        size_t res_next = parse_63(state, unmatched_checkpoint);
        if (res_next == 1) {
            bump_err(state);
            continue;
        }
        if (res_next != 0) {
            return 0;
        }
        (void)group_at(state, c, 8);
        return 0;
    }
}


/* peak_29 */
static bool peak_29(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)14) return true;
    if (current == (uint32_t)20) return true;
    return false;
}


/* expected_29 data */
static const Expected expected_29_data[] = {
    { .kind = 2u, .id = 0u },
};


/* expected_29: owning ExpectedVec copy */
static inline ExpectedVec expected_29(void) {
    size_t count = sizeof(expected_29_data) / sizeof(expected_29_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_29_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}



/* Parse Label */
static size_t parse_27(ParserState *state, size_t unmatched_checkpoint) {
    return parse_29(state, unmatched_checkpoint);
}

/* peak_27 */
static bool peak_27(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)20) return true;
    if (current == (uint32_t)14) return true;
    return false;
}


/* expected_27 data */
static const Expected expected_27_data[] = {
    { .kind = 2u, .id = 0u },
};


/* expected_27: owning ExpectedVec copy */
static inline ExpectedVec expected_27(void) {
    size_t count = sizeof(expected_27_data) / sizeof(expected_27_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_27_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}



/* Parse Just */
static size_t parse_67(ParserState *state, size_t unmatched_checkpoint) {
    (void)unmatched_checkpoint;

    for (;;) {
        /* EOF */
        if (state->offset >= state->tokens.len) {
            return 2;
        }

        uint32_t current = current_kind(state);
        if (current == (uint32_t)4) {
            bump(state);
            return 0;
        }
        if (skipped_vec_contains(&state->skipped, current)) {
            bump_skipped(state);
            continue;
        }
        break;
    }

    size_t index = state->breaks.len;
    while (index != 0) {
        index -= 1;
        PeakFunc pf = state->breaks.data[index];
        if (pf && pf(state)) {
            return index + 3;
        }
    }

    return 1;
}

/* peak_67 */
static bool peak_67(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)4) return true;
    return false;
}


/* expected_67 data */
static const Expected expected_67_data[] = {
    { .kind = 0u, .id = 4u },
};


/* expected_67: owning ExpectedVec copy */
static inline ExpectedVec expected_67(void) {
    size_t count = sizeof(expected_67_data) / sizeof(expected_67_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_67_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}


static bool break_pred_seq_66_1(ParserState *state) {
    return peak_27(state, 0, false);
}


/* Parse Seq */
static size_t parse_66(ParserState *state, size_t unmatched_checkpoint) {

    size_t brk_1 = push_break(state, break_pred_seq_66_1);

    size_t res;

    res = parse_67(state, unmatched_checkpoint);
    if (res != 0) {
        
        for(int i = 0; i < 1;i++) {
            (void)break_stack_pop(&state->breaks, NULL);
        }
        if (res >= brk_1) {
            return 1;
        }

            
        return res;
    }



    (void)break_stack_pop(&state->breaks, NULL);

    if (res >= 2 && res != brk_1) {
        ExpectedVec e = expected_27();
        missing(state, e);
    } else {
        for (;;) {
            res = parse_27(state, unmatched_checkpoint);
            if (res == 1) {
                bump_err(state);
                continue;
            }
            break;
        }
        if (res >= 2 && res != brk_1) {
            ExpectedVec e = expected_27();
            missing(state, e);
        }
    }



    return 0;
}


/* peak_66 */
static bool peak_66(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)4) return true;
    return false;
}


/* expected_66 data */
static const Expected expected_66_data[] = {
    { .kind = 0u, .id = 4u },
};


/* expected_66: owning ExpectedVec copy */
static inline ExpectedVec expected_66(void) {
    size_t count = sizeof(expected_66_data) / sizeof(expected_66_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_66_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}


static bool break_pred_25(ParserState *state) {
    return peak_66(state, 0, false);
}


/* Parse Fold */
static size_t parse_25(ParserState *state, size_t unmatched_checkpoint) {
    for (;;) {
        if (state->offset >= state->tokens.len) {
            return 2; /* EOF */
        }

        if (peak_27(state, 0, false)) {
            break;
        }

        uint32_t k = current_kind(state);
        if (skipped_vec_contains(&state->skipped, k)) {
            bump_skipped(state);
            continue;
        }
        break;
    }

    size_t c = checkpoint(state);
    size_t break_code = push_break(state, break_pred_25);
    size_t res = parse_27(state, unmatched_checkpoint);
    (void)break_stack_pop(&state->breaks, NULL);
    if (res != 0) {
        if (res == break_code) {
            return 1;
        }
        return res;
    }
    for(;;){
        size_t res_next = parse_66(state, unmatched_checkpoint);
        if (res_next == 1) {
            bump_err(state);
            continue;
        }
        if (res_next != 0) {
            return 0;
        }
        (void)group_at(state, c, 12);
        return 0;
    }
}


/* peak_25 */
static bool peak_25(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)14) return true;
    if (current == (uint32_t)20) return true;
    return false;
}


/* expected_25 data */
static const Expected expected_25_data[] = {
    { .kind = 2u, .id = 0u },
};


/* expected_25: owning ExpectedVec copy */
static inline ExpectedVec expected_25(void) {
    size_t count = sizeof(expected_25_data) / sizeof(expected_25_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_25_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}


static bool break_pred_seq_22_1(ParserState *state) {
    return peak_24(state, 0, false);
}


static bool break_pred_seq_22_2(ParserState *state) {
    return peak_17(state, 0, false);
}


static bool break_pred_seq_22_3(ParserState *state) {
    return peak_25(state, 0, false);
}


/* Parse Seq */
static size_t parse_22(ParserState *state, size_t unmatched_checkpoint) {

    size_t brk_3 = push_break(state, break_pred_seq_22_3);
    size_t brk_2 = push_break(state, break_pred_seq_22_2);
    size_t brk_1 = push_break(state, break_pred_seq_22_1);

    size_t res;

    res = parse_23(state, unmatched_checkpoint);
    if (res != 0) {
        
        for(int i = 0; i < 3;i++) {
            (void)break_stack_pop(&state->breaks, NULL);
        }
        if (res >= brk_3) {
            return 1;
        }

            
        return res;
    }



    (void)break_stack_pop(&state->breaks, NULL);

    if (res >= 2 && res != brk_1) {
        ExpectedVec e = expected_24();
        missing(state, e);
    } else {
        for (;;) {
            res = parse_24(state, unmatched_checkpoint);
            if (res == 1) {
                bump_err(state);
                continue;
            }
            break;
        }
        if (res >= 2 && res != brk_1) {
            ExpectedVec e = expected_24();
            missing(state, e);
        }
    }



    (void)break_stack_pop(&state->breaks, NULL);

    if (res >= 2 && res != brk_2) {
        ExpectedVec e = expected_17();
        missing(state, e);
    } else {
        for (;;) {
            res = parse_17(state, unmatched_checkpoint);
            if (res == 1) {
                bump_err(state);
                continue;
            }
            break;
        }
        if (res >= 2 && res != brk_2) {
            ExpectedVec e = expected_17();
            missing(state, e);
        }
    }



    (void)break_stack_pop(&state->breaks, NULL);

    if (res >= 2 && res != brk_3) {
        ExpectedVec e = expected_25();
        missing(state, e);
    } else {
        for (;;) {
            res = parse_25(state, unmatched_checkpoint);
            if (res == 1) {
                bump_err(state);
                continue;
            }
            break;
        }
        if (res >= 2 && res != brk_3) {
            ExpectedVec e = expected_25();
            missing(state, e);
        }
    }



    return 0;
}


/* peak_22 */
static bool peak_22(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)1) return true;
    return false;
}


/* expected_22 data */
static const Expected expected_22_data[] = {
    { .kind = 0u, .id = 1u },
};


/* expected_22: owning ExpectedVec copy */
static inline ExpectedVec expected_22(void) {
    size_t count = sizeof(expected_22_data) / sizeof(expected_22_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_22_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}



/* Parse Named */
static size_t parse_20(ParserState *state, size_t unmatched_checkpoint) {
    for (;;) {
        if (state->offset >= state->tokens.len) {
            return 2; /* EOF */
        }

        if (peak_22(state, 0, false)) {
            break;
        }

        uint32_t k = current_kind(state);
        if (skipped_vec_contains(&state->skipped, k)) {
            bump_skipped(state);
            continue;
        }
        break;
    }
    size_t c = checkpoint(state);
    size_t res = parse_22(state, unmatched_checkpoint);
    if (res == 0) {
        group_at(state, c, 13);
    }
    return res;
}

/* peak_20 */
static bool peak_20(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)1) return true;
    return false;
}


/* expected_20 data */
static const Expected expected_20_data[] = {
    { .kind = 1u, .id = 13u },
};


/* expected_20: owning ExpectedVec copy */
static inline ExpectedVec expected_20(void) {
    size_t count = sizeof(expected_20_data) / sizeof(expected_20_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_20_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}



/* Parse Just */
static size_t parse_71(ParserState *state, size_t unmatched_checkpoint) {
    (void)unmatched_checkpoint;

    for (;;) {
        /* EOF */
        if (state->offset >= state->tokens.len) {
            return 2;
        }

        uint32_t current = current_kind(state);
        if (current == (uint32_t)3) {
            bump(state);
            return 0;
        }
        if (skipped_vec_contains(&state->skipped, current)) {
            bump_skipped(state);
            continue;
        }
        break;
    }

    size_t index = state->breaks.len;
    while (index != 0) {
        index -= 1;
        PeakFunc pf = state->breaks.data[index];
        if (pf && pf(state)) {
            return index + 3;
        }
    }

    return 1;
}

/* peak_71 */
static bool peak_71(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)3) return true;
    return false;
}


/* expected_71 data */
static const Expected expected_71_data[] = {
    { .kind = 0u, .id = 3u },
};


/* expected_71: owning ExpectedVec copy */
static inline ExpectedVec expected_71(void) {
    size_t count = sizeof(expected_71_data) / sizeof(expected_71_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_71_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}



/* Parse Just */
static size_t parse_80(ParserState *state, size_t unmatched_checkpoint) {
    (void)unmatched_checkpoint;

    for (;;) {
        /* EOF */
        if (state->offset >= state->tokens.len) {
            return 2;
        }

        uint32_t current = current_kind(state);
        if (current == (uint32_t)8) {
            bump(state);
            return 0;
        }
        if (skipped_vec_contains(&state->skipped, current)) {
            bump_skipped(state);
            continue;
        }
        break;
    }

    size_t index = state->breaks.len;
    while (index != 0) {
        index -= 1;
        PeakFunc pf = state->breaks.data[index];
        if (pf && pf(state)) {
            return index + 3;
        }
    }

    return 1;
}

/* peak_80 */
static bool peak_80(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)8) return true;
    return false;
}


/* expected_80 data */
static const Expected expected_80_data[] = {
    { .kind = 0u, .id = 8u },
};


/* expected_80: owning ExpectedVec copy */
static inline ExpectedVec expected_80(void) {
    size_t count = sizeof(expected_80_data) / sizeof(expected_80_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_80_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}


static bool break_pred_sep_85_item(ParserState *state) {
    return peak_72(state, 0, false);
}

static bool break_pred_sep_85_sep(ParserState *state) {
    return peak_59(state, 0, false);
}


/* Parse Sep */
static size_t parse_85(ParserState *state, size_t unmatched_checkpoint) {
    size_t item_brk = push_break(state, break_pred_sep_85_item);
    size_t sep_brk  = push_break(state, break_pred_sep_85_sep);
    size_t res = 0;
    res = parse_72(state, unmatched_checkpoint);
    if (res != 0) {
        if (res == sep_brk) {
            return 1;
        }
        return res;
    }
    for (;;) {
        for (;;) {
            res = parse_59(state, unmatched_checkpoint);
            if (res == 1) {
                bump_err(state);
                continue;
            }
            break;
        }

        if (res != 0) {
            if (res == item_brk) {
                ExpectedVec e = expected_59();
                missing(state, e);
            } else {
                goto ret_ok;
            }
        }
        for (;;) {
            res = parse_72(state, unmatched_checkpoint);
            if (res == 1) {
                bump_err(state);
                continue;
            }
            break;
        }

        if (res == 0) {
            continue;
        }

        {
            ExpectedVec e = expected_72();
            missing(state, e);
            if (res == sep_brk) {
                continue;
            }
            goto ret_ok;
        }
    }

ret_ok:
    (void)break_stack_pop(&state->breaks, NULL);
    (void)break_stack_pop(&state->breaks, NULL);
    return 0;

ret_err:
    (void)break_stack_pop(&state->breaks, NULL);
    (void)break_stack_pop(&state->breaks, NULL);
    return res;
}


/* peak_85 */
static bool peak_85(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)20) return true;
    return false;
}


/* expected_85 data */
static const Expected expected_85_data[] = {
    { .kind = 1u, .id = 15u },
};


/* expected_85: owning ExpectedVec copy */
static inline ExpectedVec expected_85(void) {
    size_t count = sizeof(expected_85_data) / sizeof(expected_85_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_85_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}



/* Parse Optional */
static size_t parse_84(ParserState *state, size_t unmatched_checkpoint) {
    return parse_85(state, unmatched_checkpoint);
}

/* peak_84 */
static bool peak_84(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)20) return true;
    return false;
}


/* expected_84: optional => empty */
static inline ExpectedVec expected_84(void) {
    return (ExpectedVec){ .data = NULL, .len = 0, .cap = 0 };
}


static bool break_pred_seq_83_1(ParserState *state) {
    return peak_84(state, 0, false);
}


static bool break_pred_seq_83_2(ParserState *state) {
    return peak_44(state, 0, false);
}


/* Parse Seq */
static size_t parse_83(ParserState *state, size_t unmatched_checkpoint) {

    size_t brk_2 = push_break(state, break_pred_seq_83_2);
    size_t brk_1 = push_break(state, break_pred_seq_83_1);

    size_t res;

    res = parse_43(state, unmatched_checkpoint);
    if (res != 0) {
        
        for(int i = 0; i < 2;i++) {
            (void)break_stack_pop(&state->breaks, NULL);
        }
        if (res >= brk_2) {
            return 1;
        }

            
        return res;
    }



    (void)break_stack_pop(&state->breaks, NULL);

    if (res >= 2 && res != brk_1) {
        ExpectedVec e = expected_84();
        missing(state, e);
    } else {
        for (;;) {
            res = parse_84(state, unmatched_checkpoint);
            if (res == 1) {
                bump_err(state);
                continue;
            }
            break;
        }
        if (res >= 2 && res != brk_1) {
            ExpectedVec e = expected_84();
            missing(state, e);
        }
    }



    (void)break_stack_pop(&state->breaks, NULL);

    if (res >= 2 && res != brk_2) {
        ExpectedVec e = expected_44();
        missing(state, e);
    } else {
        for (;;) {
            res = parse_44(state, unmatched_checkpoint);
            if (res == 1) {
                bump_err(state);
                continue;
            }
            break;
        }
        if (res >= 2 && res != brk_2) {
            ExpectedVec e = expected_44();
            missing(state, e);
        }
    }



    return 0;
}


/* peak_83 */
static bool peak_83(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)14) return true;
    return false;
}


/* expected_83 data */
static const Expected expected_83_data[] = {
    { .kind = 0u, .id = 14u },
};


/* expected_83: owning ExpectedVec copy */
static inline ExpectedVec expected_83(void) {
    size_t count = sizeof(expected_83_data) / sizeof(expected_83_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_83_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}



/* Parse Named */
static size_t parse_81(ParserState *state, size_t unmatched_checkpoint) {
    for (;;) {
        if (state->offset >= state->tokens.len) {
            return 2; /* EOF */
        }

        if (peak_83(state, 0, false)) {
            break;
        }

        uint32_t k = current_kind(state);
        if (skipped_vec_contains(&state->skipped, k)) {
            bump_skipped(state);
            continue;
        }
        break;
    }
    size_t c = checkpoint(state);
    size_t res = parse_83(state, unmatched_checkpoint);
    if (res == 0) {
        group_at(state, c, 14);
    }
    return res;
}

/* peak_81 */
static bool peak_81(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)14) return true;
    return false;
}


/* expected_81 data */
static const Expected expected_81_data[] = {
    { .kind = 1u, .id = 14u },
};


/* expected_81: owning ExpectedVec copy */
static inline ExpectedVec expected_81(void) {
    size_t count = sizeof(expected_81_data) / sizeof(expected_81_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_81_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}


static bool break_pred_seq_79_1(ParserState *state) {
    return peak_81(state, 0, false);
}


/* Parse Seq */
static size_t parse_79(ParserState *state, size_t unmatched_checkpoint) {

    size_t brk_1 = push_break(state, break_pred_seq_79_1);

    size_t res;

    res = parse_80(state, unmatched_checkpoint);
    if (res != 0) {
        
        for(int i = 0; i < 1;i++) {
            (void)break_stack_pop(&state->breaks, NULL);
        }
        if (res >= brk_1) {
            return 1;
        }

            
        return res;
    }



    (void)break_stack_pop(&state->breaks, NULL);

    if (res >= 2 && res != brk_1) {
        ExpectedVec e = expected_81();
        missing(state, e);
    } else {
        for (;;) {
            res = parse_81(state, unmatched_checkpoint);
            if (res == 1) {
                bump_err(state);
                continue;
            }
            break;
        }
        if (res >= 2 && res != brk_1) {
            ExpectedVec e = expected_81();
            missing(state, e);
        }
    }



    return 0;
}


/* peak_79 */
static bool peak_79(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)8) return true;
    return false;
}


/* expected_79 data */
static const Expected expected_79_data[] = {
    { .kind = 0u, .id = 8u },
};


/* expected_79: owning ExpectedVec copy */
static inline ExpectedVec expected_79(void) {
    size_t count = sizeof(expected_79_data) / sizeof(expected_79_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_79_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}



/* Parse Optional */
static size_t parse_78(ParserState *state, size_t unmatched_checkpoint) {
    return parse_79(state, unmatched_checkpoint);
}

/* peak_78 */
static bool peak_78(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)8) return true;
    return false;
}


/* expected_78: optional => empty */
static inline ExpectedVec expected_78(void) {
    return (ExpectedVec){ .data = NULL, .len = 0, .cap = 0 };
}


static bool break_pred_seq_77_1(ParserState *state) {
    return peak_78(state, 0, false);
}


/* Parse Seq */
static size_t parse_77(ParserState *state, size_t unmatched_checkpoint) {

    size_t brk_1 = push_break(state, break_pred_seq_77_1);

    size_t res;

    res = parse_45(state, unmatched_checkpoint);
    if (res != 0) {
        
        for(int i = 0; i < 1;i++) {
            (void)break_stack_pop(&state->breaks, NULL);
        }
        if (res >= brk_1) {
            return 1;
        }

            
        return res;
    }



    (void)break_stack_pop(&state->breaks, NULL);

    if (res >= 2 && res != brk_1) {
        ExpectedVec e = expected_78();
        missing(state, e);
    } else {
        for (;;) {
            res = parse_78(state, unmatched_checkpoint);
            if (res == 1) {
                bump_err(state);
                continue;
            }
            break;
        }
        if (res >= 2 && res != brk_1) {
            ExpectedVec e = expected_78();
            missing(state, e);
        }
    }



    return 0;
}


/* peak_77 */
static bool peak_77(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)20) return true;
    return false;
}


/* expected_77 data */
static const Expected expected_77_data[] = {
    { .kind = 1u, .id = 0u },
};


/* expected_77: owning ExpectedVec copy */
static inline ExpectedVec expected_77(void) {
    size_t count = sizeof(expected_77_data) / sizeof(expected_77_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_77_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}



/* Parse Named */
static size_t parse_75(ParserState *state, size_t unmatched_checkpoint) {
    for (;;) {
        if (state->offset >= state->tokens.len) {
            return 2; /* EOF */
        }

        if (peak_77(state, 0, false)) {
            break;
        }

        uint32_t k = current_kind(state);
        if (skipped_vec_contains(&state->skipped, k)) {
            bump_skipped(state);
            continue;
        }
        break;
    }
    size_t c = checkpoint(state);
    size_t res = parse_77(state, unmatched_checkpoint);
    if (res == 0) {
        group_at(state, c, 15);
    }
    return res;
}

/* peak_75 */
static bool peak_75(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)20) return true;
    return false;
}


/* expected_75 data */
static const Expected expected_75_data[] = {
    { .kind = 1u, .id = 15u },
};


/* expected_75: owning ExpectedVec copy */
static inline ExpectedVec expected_75(void) {
    size_t count = sizeof(expected_75_data) / sizeof(expected_75_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_75_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}



/* Parse Just */
static size_t parse_89(ParserState *state, size_t unmatched_checkpoint) {
    (void)unmatched_checkpoint;

    for (;;) {
        /* EOF */
        if (state->offset >= state->tokens.len) {
            return 2;
        }

        uint32_t current = current_kind(state);
        if (current == (uint32_t)23) {
            bump(state);
            return 0;
        }
        if (skipped_vec_contains(&state->skipped, current)) {
            bump_skipped(state);
            continue;
        }
        break;
    }

    size_t index = state->breaks.len;
    while (index != 0) {
        index -= 1;
        PeakFunc pf = state->breaks.data[index];
        if (pf && pf(state)) {
            return index + 3;
        }
    }

    return 1;
}

/* peak_89 */
static bool peak_89(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)23) return true;
    return false;
}


/* expected_89 data */
static const Expected expected_89_data[] = {
    { .kind = 0u, .id = 23u },
};


/* expected_89: owning ExpectedVec copy */
static inline ExpectedVec expected_89(void) {
    size_t count = sizeof(expected_89_data) / sizeof(expected_89_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_89_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}


static bool break_pred_seq_88_1(ParserState *state) {
    return peak_19(state, 0, false);
}


/* Parse Seq */
static size_t parse_88(ParserState *state, size_t unmatched_checkpoint) {

    size_t brk_1 = push_break(state, break_pred_seq_88_1);

    size_t res;

    res = parse_89(state, unmatched_checkpoint);
    if (res != 0) {
        
        for(int i = 0; i < 1;i++) {
            (void)break_stack_pop(&state->breaks, NULL);
        }
        if (res >= brk_1) {
            return 1;
        }

            
        return res;
    }



    (void)break_stack_pop(&state->breaks, NULL);

    if (res >= 2 && res != brk_1) {
        ExpectedVec e = expected_19();
        missing(state, e);
    } else {
        for (;;) {
            res = parse_19(state, unmatched_checkpoint);
            if (res == 1) {
                bump_err(state);
                continue;
            }
            break;
        }
        if (res >= 2 && res != brk_1) {
            ExpectedVec e = expected_19();
            missing(state, e);
        }
    }



    return 0;
}


/* peak_88 */
static bool peak_88(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)23) return true;
    return false;
}


/* expected_88 data */
static const Expected expected_88_data[] = {
    { .kind = 0u, .id = 23u },
};


/* expected_88: owning ExpectedVec copy */
static inline ExpectedVec expected_88(void) {
    size_t count = sizeof(expected_88_data) / sizeof(expected_88_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_88_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}



/* Parse Named */
static size_t parse_86(ParserState *state, size_t unmatched_checkpoint) {
    for (;;) {
        if (state->offset >= state->tokens.len) {
            return 2; /* EOF */
        }

        if (peak_88(state, 0, false)) {
            break;
        }

        uint32_t k = current_kind(state);
        if (skipped_vec_contains(&state->skipped, k)) {
            bump_skipped(state);
            continue;
        }
        break;
    }
    size_t c = checkpoint(state);
    size_t res = parse_88(state, unmatched_checkpoint);
    if (res == 0) {
        group_at(state, c, 16);
    }
    return res;
}

/* peak_86 */
static bool peak_86(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)23) return true;
    return false;
}


/* expected_86 data */
static const Expected expected_86_data[] = {
    { .kind = 1u, .id = 16u },
};


/* expected_86: owning ExpectedVec copy */
static inline ExpectedVec expected_86(void) {
    size_t count = sizeof(expected_86_data) / sizeof(expected_86_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_86_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}


static bool break_pred_72(ParserState *state) {
    return peak_86(state, 0, false);
}


/* Parse Fold */
static size_t parse_72(ParserState *state, size_t unmatched_checkpoint) {
    for (;;) {
        if (state->offset >= state->tokens.len) {
            return 2; /* EOF */
        }

        if (peak_75(state, 0, false)) {
            break;
        }

        uint32_t k = current_kind(state);
        if (skipped_vec_contains(&state->skipped, k)) {
            bump_skipped(state);
            continue;
        }
        break;
    }

    size_t c = checkpoint(state);
    size_t break_code = push_break(state, break_pred_72);
    size_t res = parse_75(state, unmatched_checkpoint);
    (void)break_stack_pop(&state->breaks, NULL);
    if (res != 0) {
        if (res == break_code) {
            return 1;
        }
        return res;
    }
    for(;;){
        size_t res_next = parse_86(state, unmatched_checkpoint);
        if (res_next == 1) {
            bump_err(state);
            continue;
        }
        if (res_next != 0) {
            return 0;
        }
        (void)group_at(state, c, 17);
        return 0;
    }
}


/* peak_72 */
static bool peak_72(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)20) return true;
    return false;
}


/* expected_72 data */
static const Expected expected_72_data[] = {
    { .kind = 1u, .id = 15u },
};


/* expected_72: owning ExpectedVec copy */
static inline ExpectedVec expected_72(void) {
    size_t count = sizeof(expected_72_data) / sizeof(expected_72_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_72_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}


static bool break_pred_seq_70_1(ParserState *state) {
    return peak_72(state, 0, false);
}


/* Parse Seq */
static size_t parse_70(ParserState *state, size_t unmatched_checkpoint) {

    size_t brk_1 = push_break(state, break_pred_seq_70_1);

    size_t res;

    res = parse_71(state, unmatched_checkpoint);
    if (res != 0) {
        
        for(int i = 0; i < 1;i++) {
            (void)break_stack_pop(&state->breaks, NULL);
        }
        if (res >= brk_1) {
            return 1;
        }

            
        return res;
    }



    (void)break_stack_pop(&state->breaks, NULL);

    if (res >= 2 && res != brk_1) {
        ExpectedVec e = expected_72();
        missing(state, e);
    } else {
        for (;;) {
            res = parse_72(state, unmatched_checkpoint);
            if (res == 1) {
                bump_err(state);
                continue;
            }
            break;
        }
        if (res >= 2 && res != brk_1) {
            ExpectedVec e = expected_72();
            missing(state, e);
        }
    }



    return 0;
}


/* peak_70 */
static bool peak_70(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)3) return true;
    return false;
}


/* expected_70 data */
static const Expected expected_70_data[] = {
    { .kind = 0u, .id = 3u },
};


/* expected_70: owning ExpectedVec copy */
static inline ExpectedVec expected_70(void) {
    size_t count = sizeof(expected_70_data) / sizeof(expected_70_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_70_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}



/* Parse Named */
static size_t parse_68(ParserState *state, size_t unmatched_checkpoint) {
    for (;;) {
        if (state->offset >= state->tokens.len) {
            return 2; /* EOF */
        }

        if (peak_70(state, 0, false)) {
            break;
        }

        uint32_t k = current_kind(state);
        if (skipped_vec_contains(&state->skipped, k)) {
            bump_skipped(state);
            continue;
        }
        break;
    }
    size_t c = checkpoint(state);
    size_t res = parse_70(state, unmatched_checkpoint);
    if (res == 0) {
        group_at(state, c, 19);
    }
    return res;
}

/* peak_68 */
static bool peak_68(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)3) return true;
    return false;
}


/* expected_68 data */
static const Expected expected_68_data[] = {
    { .kind = 1u, .id = 19u },
};


/* expected_68: owning ExpectedVec copy */
static inline ExpectedVec expected_68(void) {
    size_t count = sizeof(expected_68_data) / sizeof(expected_68_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_68_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}


/* Build Choice */
static size_t parse_6(ParserState *state, size_t unmatched_checkpoint) {

    size_t res = 1;

    res = parse_7(state, unmatched_checkpoint);
    if (res == 0) {
        return 0;
    }


    res = parse_13(state, unmatched_checkpoint);
    if (res == 0) {
        return 0;
    }


    res = parse_20(state, unmatched_checkpoint);
    if (res == 0) {
        return 0;
    }


    res = parse_68(state, unmatched_checkpoint);
    if (res == 0) {
        return 0;
    }

    return res;
}


/* peak_6 */
static bool peak_6(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)1) return true;
    if (current == (uint32_t)0) return true;
    if (current == (uint32_t)2) return true;
    if (current == (uint32_t)3) return true;
    return false;
}


/* expected_6 data */
static const Expected expected_6_data[] = {
    { .kind = 1u, .id = 10u },
    { .kind = 1u, .id = 11u },
    { .kind = 1u, .id = 13u },
    { .kind = 1u, .id = 19u },
};


/* expected_6: owning ExpectedVec copy */
static inline ExpectedVec expected_6(void) {
    size_t count = sizeof(expected_6_data) / sizeof(expected_6_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_6_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}



/* Parse Just */
static size_t parse_90(ParserState *state, size_t unmatched_checkpoint) {
    (void)unmatched_checkpoint;

    for (;;) {
        /* EOF */
        if (state->offset >= state->tokens.len) {
            return 2;
        }

        uint32_t current = current_kind(state);
        if (current == (uint32_t)21) {
            bump(state);
            return 0;
        }
        if (skipped_vec_contains(&state->skipped, current)) {
            bump_skipped(state);
            continue;
        }
        break;
    }

    size_t index = state->breaks.len;
    while (index != 0) {
        index -= 1;
        PeakFunc pf = state->breaks.data[index];
        if (pf && pf(state)) {
            return index + 3;
        }
    }

    return 1;
}

/* peak_90 */
static bool peak_90(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)21) return true;
    return false;
}


/* expected_90 data */
static const Expected expected_90_data[] = {
    { .kind = 0u, .id = 21u },
};


/* expected_90: owning ExpectedVec copy */
static inline ExpectedVec expected_90(void) {
    size_t count = sizeof(expected_90_data) / sizeof(expected_90_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_90_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}


static bool break_pred_seq_4_1(ParserState *state) {
    return peak_90(state, 0, false);
}


/* Parse Seq */
static size_t parse_4(ParserState *state, size_t unmatched_checkpoint) {

    size_t brk_1 = push_break(state, break_pred_seq_4_1);

    size_t res;

    res = parse_6(state, unmatched_checkpoint);
    if (res != 0) {
        
        for(int i = 0; i < 1;i++) {
            (void)break_stack_pop(&state->breaks, NULL);
        }
        if (res >= brk_1) {
            return 1;
        }

            
        return res;
    }



    (void)break_stack_pop(&state->breaks, NULL);

    if (res >= 2 && res != brk_1) {
        ExpectedVec e = expected_90();
        missing(state, e);
    } else {
        for (;;) {
            res = parse_90(state, unmatched_checkpoint);
            if (res == 1) {
                bump_err(state);
                continue;
            }
            break;
        }
        if (res >= 2 && res != brk_1) {
            ExpectedVec e = expected_90();
            missing(state, e);
        }
    }



    return 0;
}


/* peak_4 */
static bool peak_4(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)0) return true;
    if (current == (uint32_t)3) return true;
    if (current == (uint32_t)1) return true;
    if (current == (uint32_t)2) return true;
    return false;
}


/* expected_4 data */
static const Expected expected_4_data[] = {
    { .kind = 1u, .id = 10u },
    { .kind = 1u, .id = 11u },
    { .kind = 1u, .id = 13u },
    { .kind = 1u, .id = 19u },
};


/* expected_4: owning ExpectedVec copy */
static inline ExpectedVec expected_4(void) {
    size_t count = sizeof(expected_4_data) / sizeof(expected_4_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_4_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}



/* Parse Label */
static size_t parse_3(ParserState *state, size_t unmatched_checkpoint) {
    return parse_4(state, unmatched_checkpoint);
}

/* peak_3 */
static bool peak_3(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)1) return true;
    if (current == (uint32_t)0) return true;
    if (current == (uint32_t)3) return true;
    if (current == (uint32_t)2) return true;
    return false;
}


/* expected_3 data */
static const Expected expected_3_data[] = {
    { .kind = 2u, .id = 4u },
};


/* expected_3: owning ExpectedVec copy */
static inline ExpectedVec expected_3(void) {
    size_t count = sizeof(expected_3_data) / sizeof(expected_3_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_3_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}


static bool break_pred_rep0_2(ParserState *state) {
    return peak_3(state, 0, false);
}


/* Parse Rep0 */
static size_t parse_2(ParserState *state, size_t unmatched_checkpoint) {
    size_t brk = push_break(state, break_pred_rep0_2);
    size_t res = parse_3(state, unmatched_checkpoint);
    if(res != 0) {
        (void)break_stack_pop(&state->breaks, NULL);
        if (res == brk) {
            return 1;
        }
        return res;
    }
    for (;;) {
        size_t res = parse_3(state, unmatched_checkpoint);

        if (res == 0) {
            continue;
        }

        if (res == 1) {
            bump_err(state);
            continue;
        }

        if (res == brk) {
            continue;
        }
        break;
    }

    (void)break_stack_pop(&state->breaks, NULL);
    return 0;
}

/* peak_2 */
static bool peak_2(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)2) return true;
    if (current == (uint32_t)3) return true;
    if (current == (uint32_t)1) return true;
    if (current == (uint32_t)0) return true;
    return false;
}


/* expected_2: optional => empty */
static inline ExpectedVec expected_2(void) {
    return (ExpectedVec){ .data = NULL, .len = 0, .cap = 0 };
}



/* Parse Skip */
static size_t parse_1(ParserState *state, size_t unmatched_checkpoint) {
    bool did_skip = skip(state, (uint32_t)6);
    size_t res = parse_2(state, unmatched_checkpoint);
    if (did_skip) {
        (void)unskip(state, (uint32_t)6);
    }
    return res;
}

/* peak_1 */
static bool peak_1(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)2) return true;
    if (current == (uint32_t)1) return true;
    if (current == (uint32_t)0) return true;
    if (current == (uint32_t)3) return true;
    return false;
}


/* expected_1: optional => empty */
static inline ExpectedVec expected_1(void) {
    return (ExpectedVec){ .data = NULL, .len = 0, .cap = 0 };
}



/* Parse Skip */
static size_t parse_0(ParserState *state, size_t unmatched_checkpoint) {
    bool did_skip = skip(state, (uint32_t)5);
    size_t res = parse_1(state, unmatched_checkpoint);
    if (did_skip) {
        (void)unskip(state, (uint32_t)5);
    }
    return res;
}

/* peak_0 */
static bool peak_0(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)0) return true;
    if (current == (uint32_t)1) return true;
    if (current == (uint32_t)2) return true;
    if (current == (uint32_t)3) return true;
    return false;
}


/* expected_0: optional => empty */
static inline ExpectedVec expected_0(void) {
    return (ExpectedVec){ .data = NULL, .len = 0, .cap = 0 };
}


enum { ROOT_GROUP_ID = 21 };

EXPORT Node parse(char *ptr, size_t len) {
    ParserState state = default_state(ptr, len);

    for (;;) {
        skip(&state, (uint32_t)5);
        skip(&state, (uint32_t)6);

        size_t res = parse_0(&state, 0);

        if (res != 0) {
            /* res == 2 => missing expected */
            if (res == 2) {
                ExpectedVec expected = expected_0();
                missing(&state, expected);
            } else {
                bump_err(&state);
                continue;
            }
        }

        break;
    }

    for (;;) {
        if (state.offset >= state.tokens.len) {
            break;
        }

        uint32_t k = current_kind(&state);
        if (skipped_vec_contains(&state.skipped, k)) {
            bump_skipped(&state);
            continue;
        }

        bump_err(&state);
    }

    if (state.stack.len != 1) {
        abort();
    }

    Node out;
    bool ok = node_vec_pop(&state.stack, &out);
    if (!ok) {
        abort();
    }

    return out;
}

