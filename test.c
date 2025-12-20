#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>

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
  u_int32_t kind;
  u_int32_t id;
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
      /* handle allocation failure however you prefer */
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
      /* shift elements left */
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
  Node *current = current_node(state);
  node_vec_push(&current->as.group, new_missing_node(expected));
}

static const Expected EXPECTED[] = {
    (Expected){.kind = 0, .id = 1},
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
    "atom",
    "mul",
    "sum",
    "_expr",
    "param",
    "items",
    "_brackets",
    "root",
    "unmatched",
    "error",
};


const char *group_name(uint32_t kind) {
    if (kind < (uint32_t)(sizeof(group_names) / sizeof(group_names[0]))) {
        return group_names[kind];
    }
    return "error";
}

static const char *label_names[] = {
    "error",
};


const char *label_name(uint32_t kind) {
    if (kind < (uint32_t)(sizeof(label_names) / sizeof(label_names[0]))) {
        return label_names[kind];
    }
    return "error";
}

static const char *token_names[] = {
    "num",
    "whitespace",
    "comma",
    "plus",
    "star",
    "l_bracket",
    "r_bracket",
    "eq",
    "ident",
    "error",
};


const char *token_name(uint32_t kind) {
    if (kind < (uint32_t)(sizeof(token_names) / sizeof(token_names[0]))) {
        return token_names[kind];
    }
    return "error";
}


/* RegexRange */
static bool lex_2(LexerState *lexer_state) {
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
static bool lex_1(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    lexer_state->offset = start;
    if (lex_2(lexer_state)) {
        return true;
    }


    lexer_state->offset = start;
    return false;
}


/* Rep1Regex */
static bool lex_3(LexerState *lexer_state) {
    size_t start = lexer_state->offset;

    if (lexer_state->offset >= lexer_state->len) {
        return false;
    }
    if (!lex_1(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }

    for (;;) {
        size_t before = lexer_state->offset;
        if (!lex_1(lexer_state)) {
            break;
        }
        if (lexer_state->offset == before) {
            /* Prevent infinite loop if inner matches empty */
            break;
        }
        if (lexer_state->offset >= lexer_state->len) {
            break;
        }
    }

    return true;
}


/* RegexSeq */
static bool lex_0(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (!lex_3(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    return true;
}


/* Token wrapper: lex_num */
static size_t lex_num(LexerState *lexer_state) {
    if (!lex_0(lexer_state)) {
        return 0;
    }

    /* If group_offset was set by a capturing group, prefer it; else use offset. */
    if (lexer_state->group_offset != 0) {
        return lexer_state->group_offset;
    }
    return lexer_state->offset;
}


/* Whitespace */
static bool lex_5(LexerState *lexer_state) {
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
static bool lex_6(LexerState *lexer_state) {
    size_t start = lexer_state->offset;

    if (lexer_state->offset >= lexer_state->len) {
        return false;
    }
    if (!lex_5(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }

    for (;;) {
        size_t before = lexer_state->offset;
        if (!lex_5(lexer_state)) {
            break;
        }
        if (lexer_state->offset == before) {
            /* Prevent infinite loop if inner matches empty */
            break;
        }
        if (lexer_state->offset >= lexer_state->len) {
            break;
        }
    }

    return true;
}


/* RegexSeq */
static bool lex_4(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (!lex_6(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    return true;
}


/* Token wrapper: lex_whitespace */
static size_t lex_whitespace(LexerState *lexer_state) {
    if (!lex_4(lexer_state)) {
        return 0;
    }

    /* If group_offset was set by a capturing group, prefer it; else use offset. */
    if (lexer_state->group_offset != 0) {
        return lexer_state->group_offset;
    }
    return lexer_state->offset;
}


/* Exact */
static bool lex_8(LexerState *lexer_state) {
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
static bool lex_7(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (!lex_8(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    return true;
}


/* Token wrapper: lex_comma */
static size_t lex_comma(LexerState *lexer_state) {
    if (!lex_7(lexer_state)) {
        return 0;
    }

    /* If group_offset was set by a capturing group, prefer it; else use offset. */
    if (lexer_state->group_offset != 0) {
        return lexer_state->group_offset;
    }
    return lexer_state->offset;
}


/* Exact */
static bool lex_10(LexerState *lexer_state) {
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
static bool lex_9(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (!lex_10(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    return true;
}


/* Token wrapper: lex_plus */
static size_t lex_plus(LexerState *lexer_state) {
    if (!lex_9(lexer_state)) {
        return 0;
    }

    /* If group_offset was set by a capturing group, prefer it; else use offset. */
    if (lexer_state->group_offset != 0) {
        return lexer_state->group_offset;
    }
    return lexer_state->offset;
}


/* Exact */
static bool lex_12(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (lexer_state->offset >= lexer_state->len) {
        lexer_state->offset = start;
        return false;
    }
    if ((unsigned char)lexer_state->data[lexer_state->offset] != (unsigned char)42) {
        lexer_state->offset = start;
        return false;
    }
    lexer_state->offset += 1;


    return true;
}


/* RegexSeq */
static bool lex_11(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (!lex_12(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    return true;
}


/* Token wrapper: lex_star */
static size_t lex_star(LexerState *lexer_state) {
    if (!lex_11(lexer_state)) {
        return 0;
    }

    /* If group_offset was set by a capturing group, prefer it; else use offset. */
    if (lexer_state->group_offset != 0) {
        return lexer_state->group_offset;
    }
    return lexer_state->offset;
}


/* Exact */
static bool lex_14(LexerState *lexer_state) {
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
static bool lex_13(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (!lex_14(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    return true;
}


/* Token wrapper: lex_l_bracket */
static size_t lex_l_bracket(LexerState *lexer_state) {
    if (!lex_13(lexer_state)) {
        return 0;
    }

    /* If group_offset was set by a capturing group, prefer it; else use offset. */
    if (lexer_state->group_offset != 0) {
        return lexer_state->group_offset;
    }
    return lexer_state->offset;
}


/* Exact */
static bool lex_16(LexerState *lexer_state) {
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
static bool lex_15(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (!lex_16(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    return true;
}


/* Token wrapper: lex_r_bracket */
static size_t lex_r_bracket(LexerState *lexer_state) {
    if (!lex_15(lexer_state)) {
        return 0;
    }

    /* If group_offset was set by a capturing group, prefer it; else use offset. */
    if (lexer_state->group_offset != 0) {
        return lexer_state->group_offset;
    }
    return lexer_state->offset;
}


/* Exact */
static bool lex_18(LexerState *lexer_state) {
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
static bool lex_17(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (!lex_18(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    return true;
}


/* Token wrapper: lex_eq */
static size_t lex_eq(LexerState *lexer_state) {
    if (!lex_17(lexer_state)) {
        return 0;
    }

    /* If group_offset was set by a capturing group, prefer it; else use offset. */
    if (lexer_state->group_offset != 0) {
        return lexer_state->group_offset;
    }
    return lexer_state->offset;
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


/* RegexChoice */
static bool lex_20(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    lexer_state->offset = start;
    if (lex_21(lexer_state)) {
        return true;
    }


    lexer_state->offset = start;
    if (lex_22(lexer_state)) {
        return true;
    }


    lexer_state->offset = start;
    if (lex_23(lexer_state)) {
        return true;
    }


    lexer_state->offset = start;
    return false;
}


/* RegexChar */
static bool lex_25(LexerState *lexer_state) {
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
static bool lex_26(LexerState *lexer_state) {
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
static bool lex_27(LexerState *lexer_state) {
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
static bool lex_28(LexerState *lexer_state) {
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
static bool lex_24(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    lexer_state->offset = start;
    if (lex_25(lexer_state)) {
        return true;
    }


    lexer_state->offset = start;
    if (lex_26(lexer_state)) {
        return true;
    }


    lexer_state->offset = start;
    if (lex_27(lexer_state)) {
        return true;
    }


    lexer_state->offset = start;
    if (lex_28(lexer_state)) {
        return true;
    }


    lexer_state->offset = start;
    return false;
}


/* Rep0Regex */
static bool lex_29(LexerState *lexer_state) {
    for (;;) {
        size_t before = lexer_state->offset;
        if (!lex_24(lexer_state)) {
            break;
        }
        if (lexer_state->offset == before) {
            /* Prevent infinite loop if inner matches empty */
            break;
        }
        if (lexer_state->offset >= lexer_state->len) {
            break;
        }
    }
    return true;
}


/* RegexSeq */
static bool lex_19(LexerState *lexer_state) {
    size_t start = lexer_state->offset;


    if (!lex_20(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    if (!lex_29(lexer_state)) {
        lexer_state->offset = start;
        return false;
    }


    return true;
}


/* Token wrapper: lex_ident */
static size_t lex_ident(LexerState *lexer_state) {
    if (!lex_19(lexer_state)) {
        return 0;
    }

    /* If group_offset was set by a capturing group, prefer it; else use offset. */
    if (lexer_state->group_offset != 0) {
        return lexer_state->group_offset;
    }
    return lexer_state->offset;
}


/* Main lexer entrypoint */
TokenVec lex(char *ptr, size_t len) {
    LexerState st;
    st.data = ptr;
    st.len = len;
    st.offset = 0;
    st.group_offset = 0;

    TokenVec tokens = token_vec_new();

    bool last_was_error = false;
    size_t total_offset = 0;

    while (len != 0) {
        /* Try token lexers in order */

        st.group_offset = 0;
        size_t res_0 = lex_num(&st);
        if (res_0 != 0) {
            /* Guard against pathological over-consumption */
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

            /* Advance the input window by res bytes */
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
        size_t res_1 = lex_whitespace(&st);
        if (res_1 != 0) {
            /* Guard against pathological over-consumption */
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

            /* Advance the input window by res bytes */
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
        size_t res_2 = lex_comma(&st);
        if (res_2 != 0) {
            /* Guard against pathological over-consumption */
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

            /* Advance the input window by res bytes */
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
        size_t res_3 = lex_plus(&st);
        if (res_3 != 0) {
            /* Guard against pathological over-consumption */
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

            /* Advance the input window by res bytes */
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
        size_t res_4 = lex_star(&st);
        if (res_4 != 0) {
            /* Guard against pathological over-consumption */
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

            /* Advance the input window by res bytes */
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
        size_t res_5 = lex_l_bracket(&st);
        if (res_5 != 0) {
            /* Guard against pathological over-consumption */
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

            /* Advance the input window by res bytes */
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
        size_t res_6 = lex_r_bracket(&st);
        if (res_6 != 0) {
            /* Guard against pathological over-consumption */
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

            /* Advance the input window by res bytes */
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
        size_t res_7 = lex_eq(&st);
        if (res_7 != 0) {
            /* Guard against pathological over-consumption */
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

            /* Advance the input window by res bytes */
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
        size_t res_8 = lex_ident(&st);
        if (res_8 != 0) {
            /* Guard against pathological over-consumption */
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

            /* Advance the input window by res bytes */
            ptr += res_8;
            len -= res_8;

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
                .kind = (uint32_t)9,
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
    Node root = new_group_node(7);

    NodeVec stack = node_vec_new();
    node_vec_push(&stack, root);

    TokenVec tokens = lex(ptr, len);

    return (ParserState){
        .tokens  = tokens,
        .stack   = stack,
        .offset  = 0,
        .breaks  = break_stack_new(),   /* <-- make sure this matches your actual constructor name */
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


/* Parse Just */
static size_t parse_3(ParserState *state, size_t unmatched_checkpoint) {
    (void)unmatched_checkpoint;

    for (;;) {
        /* EOF */
        if (state->offset >= state->tokens.len) {
            return 2;
        }

        uint32_t current = current_kind(state);

        /* Match expected token */
        if (current == (uint32_t)5) {
            bump(state);
            return 0;
        }

        /* Skip token if configured */
        if (skipped_vec_contains(&state->skipped, current)) {
            bump_skipped(state);
            continue;
        }

        /* Mismatch */
        break;
    }

    /* Recovery: walk break stack from top to bottom.
       If any PeakFunc matches, return (index + 3) like QBE. */
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

/* peak_3 */
static bool peak_3(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)5) return true;
    return false;
}


/* expected_3 data */
static const Expected expected_3_data[] = {
    (Expected){ .kind = 0u, .id = 5u },
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



/* Parse Just */
static size_t parse_37(ParserState *state, size_t unmatched_checkpoint) {
    (void)unmatched_checkpoint;

    for (;;) {
        /* EOF */
        if (state->offset >= state->tokens.len) {
            return 2;
        }

        uint32_t current = current_kind(state);

        /* Match expected token */
        if (current == (uint32_t)2) {
            bump(state);
            return 0;
        }

        /* Skip token if configured */
        if (skipped_vec_contains(&state->skipped, current)) {
            bump_skipped(state);
            continue;
        }

        /* Mismatch */
        break;
    }

    /* Recovery: walk break stack from top to bottom.
       If any PeakFunc matches, return (index + 3) like QBE. */
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

/* peak_37 */
static bool peak_37(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)2) return true;
    return false;
}


/* expected_37 data */
static const Expected expected_37_data[] = {
    (Expected){ .kind = 0u, .id = 2u },
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
static size_t parse_10(ParserState *state, size_t unmatched_checkpoint) {
    (void)unmatched_checkpoint;

    for (;;) {
        /* EOF */
        if (state->offset >= state->tokens.len) {
            return 2;
        }

        uint32_t current = current_kind(state);

        /* Match expected token */
        if (current == (uint32_t)8) {
            bump(state);
            return 0;
        }

        /* Skip token if configured */
        if (skipped_vec_contains(&state->skipped, current)) {
            bump_skipped(state);
            continue;
        }

        /* Mismatch */
        break;
    }

    /* Recovery: walk break stack from top to bottom.
       If any PeakFunc matches, return (index + 3) like QBE. */
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

    if (current == (uint32_t)8) return true;
    return false;
}


/* expected_10 data */
static const Expected expected_10_data[] = {
    (Expected){ .kind = 0u, .id = 8u },
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
static size_t parse_14(ParserState *state, size_t unmatched_checkpoint) {
    (void)unmatched_checkpoint;

    for (;;) {
        /* EOF */
        if (state->offset >= state->tokens.len) {
            return 2;
        }

        uint32_t current = current_kind(state);

        /* Match expected token */
        if (current == (uint32_t)7) {
            bump(state);
            return 0;
        }

        /* Skip token if configured */
        if (skipped_vec_contains(&state->skipped, current)) {
            bump_skipped(state);
            continue;
        }

        /* Mismatch */
        break;
    }

    /* Recovery: walk break stack from top to bottom.
       If any PeakFunc matches, return (index + 3) like QBE. */
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

/* peak_14 */
static bool peak_14(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)7) return true;
    return false;
}


/* expected_14 data */
static const Expected expected_14_data[] = {
    (Expected){ .kind = 0u, .id = 7u },
};


/* expected_14: owning ExpectedVec copy */
static inline ExpectedVec expected_14(void) {
    size_t count = sizeof(expected_14_data) / sizeof(expected_14_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_14_data, count * sizeof *data);

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

        /* Match expected token */
        if (current == (uint32_t)0) {
            bump(state);
            return 0;
        }

        /* Skip token if configured */
        if (skipped_vec_contains(&state->skipped, current)) {
            bump_skipped(state);
            continue;
        }

        /* Mismatch */
        break;
    }

    /* Recovery: walk break stack from top to bottom.
       If any PeakFunc matches, return (index + 3) like QBE. */
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

    if (current == (uint32_t)0) return true;
    return false;
}


/* expected_23 data */
static const Expected expected_23_data[] = {
    (Expected){ .kind = 0u, .id = 0u },
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


/* Build Choice */
static size_t parse_22(ParserState *state, size_t unmatched_checkpoint) {

    size_t res = 1;

    res = parse_10(state, unmatched_checkpoint);
    if (res == 0) {
        return 0;
    }


    res = parse_23(state, unmatched_checkpoint);
    if (res == 0) {
        return 0;
    }

    return res;
}


/* peak_22 */
static bool peak_22(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)8) return true;
    if (current == (uint32_t)0) return true;
    return false;
}


/* expected_22 data */
static const Expected expected_22_data[] = {
    (Expected){ .kind = 0u, .id = 8u },
    (Expected){ .kind = 0u, .id = 0u },
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
    size_t c = checkpoint(state);
    size_t res = parse_22(state, unmatched_checkpoint);
    if (res == 0) {
        group_at(state, c, 0);
    }
    return res;
}

/* peak_20 */
static bool peak_20(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)8) return true;
    if (current == (uint32_t)0) return true;
    return false;
}


/* expected_20 data */
static const Expected expected_20_data[] = {
    (Expected){ .kind = 1u, .id = 0u },
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
static size_t parse_26(ParserState *state, size_t unmatched_checkpoint) {
    (void)unmatched_checkpoint;

    for (;;) {
        /* EOF */
        if (state->offset >= state->tokens.len) {
            return 2;
        }

        uint32_t current = current_kind(state);

        /* Match expected token */
        if (current == (uint32_t)4) {
            bump(state);
            return 0;
        }

        /* Skip token if configured */
        if (skipped_vec_contains(&state->skipped, current)) {
            bump_skipped(state);
            continue;
        }

        /* Mismatch */
        break;
    }

    /* Recovery: walk break stack from top to bottom.
       If any PeakFunc matches, return (index + 3) like QBE. */
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

/* peak_26 */
static bool peak_26(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)4) return true;
    return false;
}


/* expected_26 data */
static const Expected expected_26_data[] = {
    (Expected){ .kind = 0u, .id = 4u },
};


/* expected_26: owning ExpectedVec copy */
static inline ExpectedVec expected_26(void) {
    size_t count = sizeof(expected_26_data) / sizeof(expected_26_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_26_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}


/* Seq break predicate wrapper for part 1 */
static bool break_pred_seq_25_1(ParserState *state) {
    return peak_20(state, 0, false);
}


/* Parse Seq (inline, new break model, emits missing for skipped parts) */
static size_t parse_25(ParserState *state, size_t unmatched_checkpoint) {

    /* Push breaks for upcoming parts (reverse so part 1 is on top) */
    size_t brk_1 = push_break(state, break_pred_seq_25_1);

    size_t res;

    /* Part 0 */
    res = parse_26(state, unmatched_checkpoint);
    if (res != 0) {
        for(int i = 0; i < 1;i++) {
            (void)break_stack_pop(&state->breaks, NULL);
        }
        return res;
    }


    /* Part 1: pop its break as we move past it */
    (void)break_stack_pop(&state->breaks, NULL);

    /* If res is EOF (2) or a break for a later part (>=2 but not this part), this part is missing. */
    if (res >= 2 && res != brk_1) {
        ExpectedVec e = expected_20();
        missing(state, e);
        /* keep res as-is so later parts are also treated as missing/skipped */
    } else {
        /* res == 0 (ok) OR res == brk_1 (we broke here): attempt to parse this part */
        for (;;) {
            res = parse_20(state, unmatched_checkpoint);
            if (res == 1) {
                bump_err(state);
                continue;
            }
            break;
        }
        if (res >= 2 && res != brk_1) {
            ExpectedVec e = expected_20();
            missing(state, e);
        }
    }


    if (res == 1) {
        return 1;
    }
    return 0;
}


/* peak_25 */
static bool peak_25(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)4) return true;
    return false;
}


/* expected_25 data */
static const Expected expected_25_data[] = {
    (Expected){ .kind = 0u, .id = 4u },
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


/* Rep0 break predicate wrapper */
static bool break_pred_rep0_24(ParserState *state) {
    return peak_25(state, 0, false);
}


/* Parse Rep0 */
static size_t parse_24(ParserState *state, size_t unmatched_checkpoint) {
    size_t brk = push_break(state, break_pred_rep0_24);
    size_t res = parse_25(state, unmatched_checkpoint);
    if(res != 0) {
        (void)break_stack_pop(&state->breaks, NULL);
        return res;
    }
    for (;;) {
        size_t res = parse_25(state, unmatched_checkpoint);

        if (res == 0) {
            /* matched one occurrence */
            continue;
        }

        if (res == 1) {
            /* always bump_err and retry */
            bump_err(state);
            continue;
        }

        if (res == 2) {
            /* EOF => stop */
            break;
        }

        if (res == brk) {
            /* broke on our delimiter => stop */
            break;
        }

        /* other break or error => propagate */
        (void)break_stack_pop(&state->breaks, NULL);
        return res;
    }

    (void)break_stack_pop(&state->breaks, NULL);
    return 0;
}

/* peak_24 */
static bool peak_24(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)4) return true;
    return false;
}


/* expected_24: optional => empty */
static inline ExpectedVec expected_24(void) {
    return (ExpectedVec){ .data = NULL, .len = 0, .cap = 0 };
}


/* Fold break predicate wrapper */
static bool break_pred_18(ParserState *state) {
    return peak_24(state, 0, false);
}


/* Parse Fold */
static size_t parse_18(ParserState *state, size_t unmatched_checkpoint) {
    /* Skip leading skipped tokens until either EOF or peak(first) says we can start. */
    for (;;) {
        if (state->offset >= state->tokens.len) {
            return 2; /* EOF */
        }

        if (peak_20(state, 0, false)) {
            break;
        }

        uint32_t k = current_kind(state);
        if (skipped_vec_contains(&state->skipped, k)) {
            bump_skipped(state);
            continue;
        }

        /* Not start token and not skippable: fall through to parse attempt */
        break;
    }

    /* checkpoint: number of children currently in the active group */
    Node *cg = current_node(state);
    size_t checkpoint = cg->as.group.len;

    /* Push break predicate for "next" and get the break code that child parsers will return */
    size_t break_code = push_break(state, break_pred_18);

    /* Parse first */
    size_t res = parse_20(state, unmatched_checkpoint);

    /* Pop the break predicate we pushed */
    (void)break_stack_pop(&state->breaks, NULL);

    /* If parse_20 failed for a reason other than our break, propagate it */
    if (res != 0 && res != break_code) {
        return res;
    }

    /* Try parse next */
    {
        size_t res_next = parse_24(state, unmatched_checkpoint);
        if (res_next == 0) {
            return 0;
        }

        /* next didn't parse: create a group out of everything after checkpoint */
        (void)group_at(state, checkpoint, 1);

        return 0;
    }
}


/* peak_18 */
static bool peak_18(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)0) return true;
    if (current == (uint32_t)8) return true;
    return false;
}


/* expected_18 data */
static const Expected expected_18_data[] = {
    (Expected){ .kind = 1u, .id = 0u },
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



/* Parse Just */
static size_t parse_29(ParserState *state, size_t unmatched_checkpoint) {
    (void)unmatched_checkpoint;

    for (;;) {
        /* EOF */
        if (state->offset >= state->tokens.len) {
            return 2;
        }

        uint32_t current = current_kind(state);

        /* Match expected token */
        if (current == (uint32_t)3) {
            bump(state);
            return 0;
        }

        /* Skip token if configured */
        if (skipped_vec_contains(&state->skipped, current)) {
            bump_skipped(state);
            continue;
        }

        /* Mismatch */
        break;
    }

    /* Recovery: walk break stack from top to bottom.
       If any PeakFunc matches, return (index + 3) like QBE. */
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

/* peak_29 */
static bool peak_29(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)3) return true;
    return false;
}


/* expected_29 data */
static const Expected expected_29_data[] = {
    (Expected){ .kind = 0u, .id = 3u },
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


/* Seq break predicate wrapper for part 1 */
static bool break_pred_seq_28_1(ParserState *state) {
    return peak_18(state, 0, false);
}


/* Parse Seq (inline, new break model, emits missing for skipped parts) */
static size_t parse_28(ParserState *state, size_t unmatched_checkpoint) {

    /* Push breaks for upcoming parts (reverse so part 1 is on top) */
    size_t brk_1 = push_break(state, break_pred_seq_28_1);

    size_t res;

    /* Part 0 */
    res = parse_29(state, unmatched_checkpoint);
    if (res != 0) {
        for(int i = 0; i < 1;i++) {
            (void)break_stack_pop(&state->breaks, NULL);
        }
        return res;
    }


    /* Part 1: pop its break as we move past it */
    (void)break_stack_pop(&state->breaks, NULL);

    /* If res is EOF (2) or a break for a later part (>=2 but not this part), this part is missing. */
    if (res >= 2 && res != brk_1) {
        ExpectedVec e = expected_18();
        missing(state, e);
        /* keep res as-is so later parts are also treated as missing/skipped */
    } else {
        /* res == 0 (ok) OR res == brk_1 (we broke here): attempt to parse this part */
        for (;;) {
            res = parse_18(state, unmatched_checkpoint);
            if (res == 1) {
                bump_err(state);
                continue;
            }
            break;
        }
        if (res >= 2 && res != brk_1) {
            ExpectedVec e = expected_18();
            missing(state, e);
        }
    }


    if (res == 1) {
        return 1;
    }
    return 0;
}


/* peak_28 */
static bool peak_28(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)3) return true;
    return false;
}


/* expected_28 data */
static const Expected expected_28_data[] = {
    (Expected){ .kind = 0u, .id = 3u },
};


/* expected_28: owning ExpectedVec copy */
static inline ExpectedVec expected_28(void) {
    size_t count = sizeof(expected_28_data) / sizeof(expected_28_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_28_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}


/* Rep0 break predicate wrapper */
static bool break_pred_rep0_27(ParserState *state) {
    return peak_28(state, 0, false);
}


/* Parse Rep0 */
static size_t parse_27(ParserState *state, size_t unmatched_checkpoint) {
    size_t brk = push_break(state, break_pred_rep0_27);
    size_t res = parse_28(state, unmatched_checkpoint);
    if(res != 0) {
        (void)break_stack_pop(&state->breaks, NULL);
        return res;
    }
    for (;;) {
        size_t res = parse_28(state, unmatched_checkpoint);

        if (res == 0) {
            /* matched one occurrence */
            continue;
        }

        if (res == 1) {
            /* always bump_err and retry */
            bump_err(state);
            continue;
        }

        if (res == 2) {
            /* EOF => stop */
            break;
        }

        if (res == brk) {
            /* broke on our delimiter => stop */
            break;
        }

        /* other break or error => propagate */
        (void)break_stack_pop(&state->breaks, NULL);
        return res;
    }

    (void)break_stack_pop(&state->breaks, NULL);
    return 0;
}

/* peak_27 */
static bool peak_27(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)3) return true;
    return false;
}


/* expected_27: optional => empty */
static inline ExpectedVec expected_27(void) {
    return (ExpectedVec){ .data = NULL, .len = 0, .cap = 0 };
}


/* Fold break predicate wrapper */
static bool break_pred_15(ParserState *state) {
    return peak_27(state, 0, false);
}


/* Parse Fold */
static size_t parse_15(ParserState *state, size_t unmatched_checkpoint) {
    /* Skip leading skipped tokens until either EOF or peak(first) says we can start. */
    for (;;) {
        if (state->offset >= state->tokens.len) {
            return 2; /* EOF */
        }

        if (peak_18(state, 0, false)) {
            break;
        }

        uint32_t k = current_kind(state);
        if (skipped_vec_contains(&state->skipped, k)) {
            bump_skipped(state);
            continue;
        }

        /* Not start token and not skippable: fall through to parse attempt */
        break;
    }

    /* checkpoint: number of children currently in the active group */
    Node *cg = current_node(state);
    size_t checkpoint = cg->as.group.len;

    /* Push break predicate for "next" and get the break code that child parsers will return */
    size_t break_code = push_break(state, break_pred_15);

    /* Parse first */
    size_t res = parse_18(state, unmatched_checkpoint);

    /* Pop the break predicate we pushed */
    (void)break_stack_pop(&state->breaks, NULL);

    /* If parse_18 failed for a reason other than our break, propagate it */
    if (res != 0 && res != break_code) {
        return res;
    }

    /* Try parse next */
    {
        size_t res_next = parse_27(state, unmatched_checkpoint);
        if (res_next == 0) {
            return 0;
        }

        /* next didn't parse: create a group out of everything after checkpoint */
        (void)group_at(state, checkpoint, 2);

        return 0;
    }
}


/* peak_15 */
static bool peak_15(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)0) return true;
    if (current == (uint32_t)8) return true;
    return false;
}


/* expected_15 data */
static const Expected expected_15_data[] = {
    (Expected){ .kind = 1u, .id = 0u },
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


/* Seq break predicate wrapper for part 1 */
static bool break_pred_seq_13_1(ParserState *state) {
    return peak_15(state, 0, false);
}


/* Parse Seq (inline, new break model, emits missing for skipped parts) */
static size_t parse_13(ParserState *state, size_t unmatched_checkpoint) {

    /* Push breaks for upcoming parts (reverse so part 1 is on top) */
    size_t brk_1 = push_break(state, break_pred_seq_13_1);

    size_t res;

    /* Part 0 */
    res = parse_14(state, unmatched_checkpoint);
    if (res != 0) {
        for(int i = 0; i < 1;i++) {
            (void)break_stack_pop(&state->breaks, NULL);
        }
        return res;
    }


    /* Part 1: pop its break as we move past it */
    (void)break_stack_pop(&state->breaks, NULL);

    /* If res is EOF (2) or a break for a later part (>=2 but not this part), this part is missing. */
    if (res >= 2 && res != brk_1) {
        ExpectedVec e = expected_15();
        missing(state, e);
        /* keep res as-is so later parts are also treated as missing/skipped */
    } else {
        /* res == 0 (ok) OR res == brk_1 (we broke here): attempt to parse this part */
        for (;;) {
            res = parse_15(state, unmatched_checkpoint);
            if (res == 1) {
                bump_err(state);
                continue;
            }
            break;
        }
        if (res >= 2 && res != brk_1) {
            ExpectedVec e = expected_15();
            missing(state, e);
        }
    }


    if (res == 1) {
        return 1;
    }
    return 0;
}


/* peak_13 */
static bool peak_13(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)7) return true;
    return false;
}


/* expected_13 data */
static const Expected expected_13_data[] = {
    (Expected){ .kind = 0u, .id = 7u },
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



/* Parse Rename */
static size_t parse_12(ParserState *state, size_t unmatched_checkpoint) {
    size_t res = parse_13(state, unmatched_checkpoint);
    if (res != 0) {
        return res;
    }

    /* group_at makes a new group from elements after checkpoint; then we tag it with `name`. */
    (void)group_at(state, unmatched_checkpoint, 4);


    return 0;
}

/* peak_12 */
static bool peak_12(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)7) return true;
    return false;
}


/* expected_12 data */
static const Expected expected_12_data[] = {
    (Expected){ .kind = 0u, .id = 7u },
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



/* Parse Rename */
static size_t parse_32(ParserState *state, size_t unmatched_checkpoint) {
    size_t res = parse_24(state, unmatched_checkpoint);
    if (res != 0) {
        return res;
    }

    /* group_at makes a new group from elements after checkpoint; then we tag it with `name`. */
    (void)group_at(state, unmatched_checkpoint, 1);


    return 0;
}

/* peak_32 */
static bool peak_32(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)4) return true;
    return false;
}


/* expected_32: optional => empty */
static inline ExpectedVec expected_32(void) {
    return (ExpectedVec){ .data = NULL, .len = 0, .cap = 0 };
}


# Parse Optional
function l $parse_31(l %state_ptr, w %recover, l %unmatched_checkpoint) {
@start
    %res =l call $parse_32(l %state_ptr, w %recover, l %unmatched_checkpoint)
    ret %res
}
/* peak_31 */
static bool peak_31(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)4) return true;
    return false;
}


/* expected_31: optional => empty */
static inline ExpectedVec expected_31(void) {
    return (ExpectedVec){ .data = NULL, .len = 0, .cap = 0 };
}



/* Parse Rename */
static size_t parse_34(ParserState *state, size_t unmatched_checkpoint) {
    size_t res = parse_27(state, unmatched_checkpoint);
    if (res != 0) {
        return res;
    }

    /* group_at makes a new group from elements after checkpoint; then we tag it with `name`. */
    (void)group_at(state, unmatched_checkpoint, 2);


    return 0;
}

/* peak_34 */
static bool peak_34(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)3) return true;
    return false;
}


/* expected_34: optional => empty */
static inline ExpectedVec expected_34(void) {
    return (ExpectedVec){ .data = NULL, .len = 0, .cap = 0 };
}


# Parse Optional
function l $parse_33(l %state_ptr, w %recover, l %unmatched_checkpoint) {
@start
    %res =l call $parse_34(l %state_ptr, w %recover, l %unmatched_checkpoint)
    ret %res
}
/* peak_33 */
static bool peak_33(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)3) return true;
    return false;
}


/* expected_33: optional => empty */
static inline ExpectedVec expected_33(void) {
    return (ExpectedVec){ .data = NULL, .len = 0, .cap = 0 };
}


/* Seq break predicate wrapper for part 1 */
static bool break_pred_seq_30_1(ParserState *state) {
    return peak_33(state, 0, false);
}


/* Parse Seq (inline, new break model, emits missing for skipped parts) */
static size_t parse_30(ParserState *state, size_t unmatched_checkpoint) {

    /* Push breaks for upcoming parts (reverse so part 1 is on top) */
    size_t brk_1 = push_break(state, break_pred_seq_30_1);

    size_t res;

    /* Part 0 */
    res = parse_31(state, unmatched_checkpoint);
    if (res != 0) {
        for(int i = 0; i < 1;i++) {
            (void)break_stack_pop(&state->breaks, NULL);
        }
        return res;
    }


    /* Part 1: pop its break as we move past it */
    (void)break_stack_pop(&state->breaks, NULL);

    /* If res is EOF (2) or a break for a later part (>=2 but not this part), this part is missing. */
    if (res >= 2 && res != brk_1) {
        ExpectedVec e = expected_33();
        missing(state, e);
        /* keep res as-is so later parts are also treated as missing/skipped */
    } else {
        /* res == 0 (ok) OR res == brk_1 (we broke here): attempt to parse this part */
        for (;;) {
            res = parse_33(state, unmatched_checkpoint);
            if (res == 1) {
                bump_err(state);
                continue;
            }
            break;
        }
        if (res >= 2 && res != brk_1) {
            ExpectedVec e = expected_33();
            missing(state, e);
        }
    }


    if (res == 1) {
        return 1;
    }
    return 0;
}


/* peak_30 */
static bool peak_30(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)4) return true;
    if (current == (uint32_t)3) return true;
    return false;
}


/* expected_30: optional => empty */
static inline ExpectedVec expected_30(void) {
    return (ExpectedVec){ .data = NULL, .len = 0, .cap = 0 };
}


/* Build Choice */
static size_t parse_11(ParserState *state, size_t unmatched_checkpoint) {

    size_t res = 1;

    res = parse_12(state, unmatched_checkpoint);
    if (res == 0) {
        return 0;
    }


    /* default branch */
    group_at(state, unmatched_checkpoint, (uint32_t)0);


    res = parse_30(state, unmatched_checkpoint);
    if (res != 0) {
        return res;
    }

    return 0;
}


/* peak_11 */
static bool peak_11(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)4) return true;
    if (current == (uint32_t)7) return true;
    if (current == (uint32_t)3) return true;
    return false;
}


/* expected_11: optional => empty */
static inline ExpectedVec expected_11(void) {
    return (ExpectedVec){ .data = NULL, .len = 0, .cap = 0 };
}


/* Seq break predicate wrapper for part 1 */
static bool break_pred_seq_9_1(ParserState *state) {
    return peak_11(state, 0, false);
}


/* Parse Seq (inline, new break model, emits missing for skipped parts) */
static size_t parse_9(ParserState *state, size_t unmatched_checkpoint) {

    /* Push breaks for upcoming parts (reverse so part 1 is on top) */
    size_t brk_1 = push_break(state, break_pred_seq_9_1);

    size_t res;

    /* Part 0 */
    res = parse_10(state, unmatched_checkpoint);
    if (res != 0) {
        for(int i = 0; i < 1;i++) {
            (void)break_stack_pop(&state->breaks, NULL);
        }
        return res;
    }


    /* Part 1: pop its break as we move past it */
    (void)break_stack_pop(&state->breaks, NULL);

    /* If res is EOF (2) or a break for a later part (>=2 but not this part), this part is missing. */
    if (res >= 2 && res != brk_1) {
        ExpectedVec e = expected_11();
        missing(state, e);
        /* keep res as-is so later parts are also treated as missing/skipped */
    } else {
        /* res == 0 (ok) OR res == brk_1 (we broke here): attempt to parse this part */
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


    if (res == 1) {
        return 1;
    }
    return 0;
}


/* peak_9 */
static bool peak_9(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)8) return true;
    return false;
}


/* expected_9 data */
static const Expected expected_9_data[] = {
    (Expected){ .kind = 0u, .id = 8u },
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


/* Build Choice */
static size_t parse_36(ParserState *state, size_t unmatched_checkpoint) {

    size_t res = 1;

    /* default branch */
    group_at(state, unmatched_checkpoint, (uint32_t)0);


    res = parse_30(state, unmatched_checkpoint);
    if (res != 0) {
        return res;
    }

    return 0;
}


/* peak_36 */
static bool peak_36(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)3) return true;
    if (current == (uint32_t)4) return true;
    return false;
}


/* expected_36: optional => empty */
static inline ExpectedVec expected_36(void) {
    return (ExpectedVec){ .data = NULL, .len = 0, .cap = 0 };
}


/* Seq break predicate wrapper for part 1 */
static bool break_pred_seq_35_1(ParserState *state) {
    return peak_36(state, 0, false);
}


/* Parse Seq (inline, new break model, emits missing for skipped parts) */
static size_t parse_35(ParserState *state, size_t unmatched_checkpoint) {

    /* Push breaks for upcoming parts (reverse so part 1 is on top) */
    size_t brk_1 = push_break(state, break_pred_seq_35_1);

    size_t res;

    /* Part 0 */
    res = parse_23(state, unmatched_checkpoint);
    if (res != 0) {
        for(int i = 0; i < 1;i++) {
            (void)break_stack_pop(&state->breaks, NULL);
        }
        return res;
    }


    /* Part 1: pop its break as we move past it */
    (void)break_stack_pop(&state->breaks, NULL);

    /* If res is EOF (2) or a break for a later part (>=2 but not this part), this part is missing. */
    if (res >= 2 && res != brk_1) {
        ExpectedVec e = expected_36();
        missing(state, e);
        /* keep res as-is so later parts are also treated as missing/skipped */
    } else {
        /* res == 0 (ok) OR res == brk_1 (we broke here): attempt to parse this part */
        for (;;) {
            res = parse_36(state, unmatched_checkpoint);
            if (res == 1) {
                bump_err(state);
                continue;
            }
            break;
        }
        if (res >= 2 && res != brk_1) {
            ExpectedVec e = expected_36();
            missing(state, e);
        }
    }


    if (res == 1) {
        return 1;
    }
    return 0;
}


/* peak_35 */
static bool peak_35(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)0) return true;
    return false;
}


/* expected_35 data */
static const Expected expected_35_data[] = {
    (Expected){ .kind = 0u, .id = 0u },
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


/* Build Choice */
static size_t parse_8(ParserState *state, size_t unmatched_checkpoint) {

    size_t res = 1;

    res = parse_9(state, unmatched_checkpoint);
    if (res == 0) {
        return 0;
    }


    res = parse_35(state, unmatched_checkpoint);
    if (res == 0) {
        return 0;
    }

    return res;
}


/* peak_8 */
static bool peak_8(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)0) return true;
    if (current == (uint32_t)8) return true;
    return false;
}


/* expected_8 data */
static const Expected expected_8_data[] = {
    (Expected){ .kind = 0u, .id = 8u },
    (Expected){ .kind = 0u, .id = 0u },
};


/* expected_8: owning ExpectedVec copy */
static inline ExpectedVec expected_8(void) {
    size_t count = sizeof(expected_8_data) / sizeof(expected_8_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_8_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}



/* Parse Checkpoint */
static size_t parse_7(ParserState *state, size_t unmatched_checkpoint) {
    size_t c = checkpoint(state);
    size_t res = parse_8(state, c);
    return res;
}

/* peak_7 */
static bool peak_7(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)8) return true;
    if (current == (uint32_t)0) return true;
    return false;
}


/* expected_7 data */
static const Expected expected_7_data[] = {
    (Expected){ .kind = 0u, .id = 8u },
    (Expected){ .kind = 0u, .id = 0u },
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


/* Sep break predicate wrapper: item */
static bool break_pred_sep_6_item(ParserState *state) {
    return peak_7(state, 0, false);
}

/* Sep break predicate wrapper: sep */
static bool break_pred_sep_6_sep(ParserState *state) {
    return peak_37(state, 0, false);
}


/* Parse Sep */
static size_t parse_6(ParserState *state, size_t unmatched_checkpoint) {
    /* Push break predicates: item then sep (sep ends up on top, like your old push order). */
    size_t item_brk = push_break(state, break_pred_sep_6_item);
    size_t sep_brk  = push_break(state, break_pred_sep_6_sep);

    size_t res = 0;

    res = parse_7(state, unmatched_checkpoint);

    if (res != 0) {
        /* error / eof / break: match old behavior -> propagate */
        goto ret_err;
    }

    /* ---- loop: (sep item)* ---- */
    for (;;) {
        /* Try parse sep */
        for (;;) {
            res = parse_37(state, unmatched_checkpoint);
            if (res == 1) {
                bump_err(state);
                continue;
            }
            break;
        }

        if (res == 0) {
            /* parsed sep, now must parse item */
        } else {
            /* couldn't parse sep */
            if (res == 2) {
                /* EOF while expecting sep: success */
                goto ret_ok;
            }

            if (res == item_brk) {
                /* We hit an item delimiter => missing separator */
                ExpectedVec e = expected_37();
                missing(state, e);
                /* then attempt item */
            } else {
                /* some other break or error => stop successfully (old QBE ret_ok) */
                goto ret_ok;
            }
        }

        /* Try parse item */
        for (;;) {
            res = parse_7(state, unmatched_checkpoint);
            if (res == 1) {
                bump_err(state);
                continue;
            }
            break;
        }

        if (res == 0) {
            /* got item, continue looping */
            continue;
        }

        /* item didn't parse */
        {
            /* Always emit missing(item) on failure (matches old QBE check_item_eof path) */
            ExpectedVec e = expected_7();
            missing(state, e);

            if (res == 2) {
                /* EOF after missing item: success */
                goto ret_ok;
            }

            if (res == sep_brk) {
                /* We hit a sep delimiter => treat missing item as recovery and continue with sep */
                continue;
            }

            /* Otherwise: stop successfully */
            goto ret_ok;
        }
    }

ret_ok:
    /* pop sep break then item break */
    (void)break_stack_pop(&state->breaks, NULL);
    (void)break_stack_pop(&state->breaks, NULL);
    return 0;

ret_err:
    (void)break_stack_pop(&state->breaks, NULL);
    (void)break_stack_pop(&state->breaks, NULL);
    return res;
}


/* peak_6 */
static bool peak_6(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)8) return true;
    if (current == (uint32_t)0) return true;
    return false;
}


/* expected_6 data */
static const Expected expected_6_data[] = {
    (Expected){ .kind = 0u, .id = 8u },
    (Expected){ .kind = 0u, .id = 0u },
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



/* Parse Named */
static size_t parse_4(ParserState *state, size_t unmatched_checkpoint) {
    size_t c = checkpoint(state);
    size_t res = parse_6(state, unmatched_checkpoint);
    if (res == 0) {
        group_at(state, c, 5);
    }
    return res;
}

/* peak_4 */
static bool peak_4(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)8) return true;
    if (current == (uint32_t)0) return true;
    return false;
}


/* expected_4 data */
static const Expected expected_4_data[] = {
    (Expected){ .kind = 1u, .id = 5u },
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



/* Parse Just */
static size_t parse_38(ParserState *state, size_t unmatched_checkpoint) {
    (void)unmatched_checkpoint;

    for (;;) {
        /* EOF */
        if (state->offset >= state->tokens.len) {
            return 2;
        }

        uint32_t current = current_kind(state);

        /* Match expected token */
        if (current == (uint32_t)6) {
            bump(state);
            return 0;
        }

        /* Skip token if configured */
        if (skipped_vec_contains(&state->skipped, current)) {
            bump_skipped(state);
            continue;
        }

        /* Mismatch */
        break;
    }

    /* Recovery: walk break stack from top to bottom.
       If any PeakFunc matches, return (index + 3) like QBE. */
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

/* peak_38 */
static bool peak_38(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)6) return true;
    return false;
}


/* expected_38 data */
static const Expected expected_38_data[] = {
    (Expected){ .kind = 0u, .id = 6u },
};


/* expected_38: owning ExpectedVec copy */
static inline ExpectedVec expected_38(void) {
    size_t count = sizeof(expected_38_data) / sizeof(expected_38_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_38_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}


/* Seq break predicate wrapper for part 1 */
static bool break_pred_seq_1_1(ParserState *state) {
    return peak_4(state, 0, false);
}


/* Seq break predicate wrapper for part 2 */
static bool break_pred_seq_1_2(ParserState *state) {
    return peak_38(state, 0, false);
}


/* Parse Seq (inline, new break model, emits missing for skipped parts) */
static size_t parse_1(ParserState *state, size_t unmatched_checkpoint) {

    /* Push breaks for upcoming parts (reverse so part 1 is on top) */
    size_t brk_2 = push_break(state, break_pred_seq_1_2);
    size_t brk_1 = push_break(state, break_pred_seq_1_1);

    size_t res;

    /* Part 0 */
    res = parse_3(state, unmatched_checkpoint);
    if (res != 0) {
        for(int i = 0; i < 2;i++) {
            (void)break_stack_pop(&state->breaks, NULL);
        }
        return res;
    }


    /* Part 1: pop its break as we move past it */
    (void)break_stack_pop(&state->breaks, NULL);

    /* If res is EOF (2) or a break for a later part (>=2 but not this part), this part is missing. */
    if (res >= 2 && res != brk_1) {
        ExpectedVec e = expected_4();
        missing(state, e);
        /* keep res as-is so later parts are also treated as missing/skipped */
    } else {
        /* res == 0 (ok) OR res == brk_1 (we broke here): attempt to parse this part */
        for (;;) {
            res = parse_4(state, unmatched_checkpoint);
            if (res == 1) {
                bump_err(state);
                continue;
            }
            break;
        }
        if (res >= 2 && res != brk_1) {
            ExpectedVec e = expected_4();
            missing(state, e);
        }
    }


    /* Part 2: pop its break as we move past it */
    (void)break_stack_pop(&state->breaks, NULL);

    /* If res is EOF (2) or a break for a later part (>=2 but not this part), this part is missing. */
    if (res >= 2 && res != brk_2) {
        ExpectedVec e = expected_38();
        missing(state, e);
        /* keep res as-is so later parts are also treated as missing/skipped */
    } else {
        /* res == 0 (ok) OR res == brk_2 (we broke here): attempt to parse this part */
        for (;;) {
            res = parse_38(state, unmatched_checkpoint);
            if (res == 1) {
                bump_err(state);
                continue;
            }
            break;
        }
        if (res >= 2 && res != brk_2) {
            ExpectedVec e = expected_38();
            missing(state, e);
        }
    }


    if (res == 1) {
        return 1;
    }
    return 0;
}


/* peak_1 */
static bool peak_1(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)5) return true;
    return false;
}


/* expected_1 data */
static const Expected expected_1_data[] = {
    (Expected){ .kind = 0u, .id = 5u },
};


/* expected_1: owning ExpectedVec copy */
static inline ExpectedVec expected_1(void) {
    size_t count = sizeof(expected_1_data) / sizeof(expected_1_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_1_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}



/* Parse Skip */
static size_t parse_0(ParserState *state, size_t unmatched_checkpoint) {
    bool did_skip = skip(state, (uint32_t)1);
    size_t res = parse_1(state, unmatched_checkpoint);
    if (did_skip) {
        (void)unskip(state, (uint32_t)1);
    }
    return res;
}

/* peak_0 */
static bool peak_0(ParserState *state, size_t offset, bool recover) {
    (void)offset;
    (void)recover;

    uint32_t current = current_kind(state);

    if (current == (uint32_t)5) return true;
    return false;
}


/* expected_0 data */
static const Expected expected_0_data[] = {
    (Expected){ .kind = 0u, .id = 5u },
};


/* expected_0: owning ExpectedVec copy */
static inline ExpectedVec expected_0(void) {
    size_t count = sizeof(expected_0_data) / sizeof(expected_0_data[0]);

    Expected *data = (Expected *)malloc(count * sizeof *data);
    if (!data) abort();

    memcpy(data, expected_0_data, count * sizeof *data);

    return (ExpectedVec){
        .data = data,
        .len  = count,
        .cap  = count,
    };
}


/* root group id */
enum { ROOT_GROUP_ID = 7 };

/* parse entrypoint */
Node parse(char *ptr, size_t len) {
    ParserState state = default_state(ptr, len);

    for (;;) {
        /* Apply initial skip rules (from Skip wrappers) */
        skip(&state, (uint32_t)1);

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

    /* After parse: consume skipped tokens until EOF; otherwise emit error until EOF */
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

    /* There should be exactly one item left on the stack: the root node */
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

