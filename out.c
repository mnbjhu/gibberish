#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
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

struct ParserState {
  TokenVec tokens;
  NodeVec stack;
  size_t offset;
  bool (*op[])(ParserState *);
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
static const char *group_names[] = {
    "string", "num",   "bool", "array",     "field",
    "object", "_expr", "root", "unmatched", "error",
};

const char *group_name(uint32_t kind) {
  if (kind < (uint32_t)(sizeof(group_names) / sizeof(group_names[0]))) {
    return group_names[kind];
  }
  return "error";
}

static const char *label_names[] = {
    "expr",
    "error",
};

const char *label_name(uint32_t kind) {
  if (kind < (uint32_t)(sizeof(label_names) / sizeof(label_names[0]))) {
    return label_names[kind];
  }
  return "error";
}

/* Exact */
static bool lex_2(LexerState *lexer_state) {
  size_t start = lexer_state->offset;

  if (lexer_state->offset >= lexer_state->len) {
    lexer_state->offset = start;
    return false;
  }
  if ((unsigned char)lexer_state->data[lexer_state->offset] !=
      (unsigned char)116) {
    lexer_state->offset = start;
    return false;
  }
  lexer_state->offset += 1;

  if (lexer_state->offset >= lexer_state->len) {
    lexer_state->offset = start;
    return false;
  }
  if ((unsigned char)lexer_state->data[lexer_state->offset] !=
      (unsigned char)114) {
    lexer_state->offset = start;
    return false;
  }
  lexer_state->offset += 1;

  if (lexer_state->offset >= lexer_state->len) {
    lexer_state->offset = start;
    return false;
  }
  if ((unsigned char)lexer_state->data[lexer_state->offset] !=
      (unsigned char)117) {
    lexer_state->offset = start;
    return false;
  }
  lexer_state->offset += 1;

  if (lexer_state->offset >= lexer_state->len) {
    lexer_state->offset = start;
    return false;
  }
  if ((unsigned char)lexer_state->data[lexer_state->offset] !=
      (unsigned char)101) {
    lexer_state->offset = start;
    return false;
  }
  lexer_state->offset += 1;

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

/* RegexRange */
static bool lex_4(LexerState *lexer_state) {
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
static bool lex_5(LexerState *lexer_state) {
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
static bool lex_6(LexerState *lexer_state) {
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

/* RegexChar */
static bool lex_7(LexerState *lexer_state) {
  if (lexer_state->offset >= lexer_state->len) {
    return false; /* EOF */
  }

  if ((unsigned char)lexer_state->data[lexer_state->offset] ==
      (unsigned char)95) {
    lexer_state->offset += 1;
    return true;
  }

  return false;
}

/* RegexNegatedChoice */
static bool lex_3(LexerState *lexer_state) {
  size_t len = lexer_state->len;
  size_t start = lexer_state->offset;

  if (lex_4(lexer_state)) {
    lexer_state->offset = start;
    return false;
  }

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
    return true; /* EOF: succeed without consuming */
  }

  lexer_state->offset += 1; /* consume one byte/char */
  return true;
}

/* RegexSeq */
static bool lex_0(LexerState *lexer_state) {
  size_t start = lexer_state->offset;

  if (!lex_1(lexer_state)) {
    lexer_state->offset = start;
    return false;
  }

  if (!lex_3(lexer_state)) {
    lexer_state->offset = start;
    return false;
  }

  return true;
}

/* Token wrapper: lex_true */
static size_t lex_true(LexerState *lexer_state) {
  if (!lex_0(lexer_state)) {
    return 0;
  }

  /* If group_offset was set by a capturing group, prefer it; else use offset.
   */
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
  if ((unsigned char)lexer_state->data[lexer_state->offset] !=
      (unsigned char)102) {
    lexer_state->offset = start;
    return false;
  }
  lexer_state->offset += 1;

  if (lexer_state->offset >= lexer_state->len) {
    lexer_state->offset = start;
    return false;
  }
  if ((unsigned char)lexer_state->data[lexer_state->offset] !=
      (unsigned char)97) {
    lexer_state->offset = start;
    return false;
  }
  lexer_state->offset += 1;

  if (lexer_state->offset >= lexer_state->len) {
    lexer_state->offset = start;
    return false;
  }
  if ((unsigned char)lexer_state->data[lexer_state->offset] !=
      (unsigned char)108) {
    lexer_state->offset = start;
    return false;
  }
  lexer_state->offset += 1;

  if (lexer_state->offset >= lexer_state->len) {
    lexer_state->offset = start;
    return false;
  }
  if ((unsigned char)lexer_state->data[lexer_state->offset] !=
      (unsigned char)115) {
    lexer_state->offset = start;
    return false;
  }
  lexer_state->offset += 1;

  if (lexer_state->offset >= lexer_state->len) {
    lexer_state->offset = start;
    return false;
  }
  if ((unsigned char)lexer_state->data[lexer_state->offset] !=
      (unsigned char)101) {
    lexer_state->offset = start;
    return false;
  }
  lexer_state->offset += 1;

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

/* RegexRange */
static bool lex_12(LexerState *lexer_state) {
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
static bool lex_13(LexerState *lexer_state) {
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
static bool lex_14(LexerState *lexer_state) {
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

/* RegexChar */
static bool lex_15(LexerState *lexer_state) {
  if (lexer_state->offset >= lexer_state->len) {
    return false; /* EOF */
  }

  if ((unsigned char)lexer_state->data[lexer_state->offset] ==
      (unsigned char)95) {
    lexer_state->offset += 1;
    return true;
  }

  return false;
}

/* RegexNegatedChoice */
static bool lex_11(LexerState *lexer_state) {
  size_t len = lexer_state->len;
  size_t start = lexer_state->offset;

  if (lex_12(lexer_state)) {
    lexer_state->offset = start;
    return false;
  }

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
    return true; /* EOF: succeed without consuming */
  }

  lexer_state->offset += 1; /* consume one byte/char */
  return true;
}

/* RegexSeq */
static bool lex_8(LexerState *lexer_state) {
  size_t start = lexer_state->offset;

  if (!lex_9(lexer_state)) {
    lexer_state->offset = start;
    return false;
  }

  if (!lex_11(lexer_state)) {
    lexer_state->offset = start;
    return false;
  }

  return true;
}

/* Token wrapper: lex_false */
static size_t lex_false(LexerState *lexer_state) {
  if (!lex_8(lexer_state)) {
    return 0;
  }

  /* If group_offset was set by a capturing group, prefer it; else use offset.
   */
  if (lexer_state->group_offset != 0) {
    return lexer_state->group_offset;
  }
  return lexer_state->offset;
}

/* RegexChar */
static bool lex_18(LexerState *lexer_state) {
  if (lexer_state->offset >= lexer_state->len) {
    return false; /* EOF */
  }

  if ((unsigned char)lexer_state->data[lexer_state->offset] ==
      (unsigned char)32) {
    lexer_state->offset += 1;
    return true;
  }

  return false;
}

/* RegexChar */
static bool lex_19(LexerState *lexer_state) {
  if (lexer_state->offset >= lexer_state->len) {
    return false; /* EOF */
  }

  if ((unsigned char)lexer_state->data[lexer_state->offset] ==
      (unsigned char)9) {
    lexer_state->offset += 1;
    return true;
  }

  return false;
}

/* RegexChar */
static bool lex_20(LexerState *lexer_state) {
  if (lexer_state->offset >= lexer_state->len) {
    return false; /* EOF */
  }

  if ((unsigned char)lexer_state->data[lexer_state->offset] ==
      (unsigned char)10) {
    lexer_state->offset += 1;
    return true;
  }

  return false;
}

/* RegexChar */
static bool lex_21(LexerState *lexer_state) {
  if (lexer_state->offset >= lexer_state->len) {
    return false; /* EOF */
  }

  if ((unsigned char)lexer_state->data[lexer_state->offset] ==
      (unsigned char)12) {
    lexer_state->offset += 1;
    return true;
  }

  return false;
}

/* RegexChoice */
static bool lex_17(LexerState *lexer_state) {
  size_t start = lexer_state->offset;

  lexer_state->offset = start;
  if (lex_18(lexer_state)) {
    return true;
  }

  lexer_state->offset = start;
  if (lex_19(lexer_state)) {
    return true;
  }

  lexer_state->offset = start;
  if (lex_20(lexer_state)) {
    return true;
  }

  lexer_state->offset = start;
  if (lex_21(lexer_state)) {
    return true;
  }

  lexer_state->offset = start;
  return false;
}

/* Rep1Regex */
static bool lex_22(LexerState *lexer_state) {
  size_t start = lexer_state->offset;

  if (lexer_state->offset >= lexer_state->len) {
    return false;
  }
  if (!lex_17(lexer_state)) {
    lexer_state->offset = start;
    return false;
  }

  for (;;) {
    size_t before = lexer_state->offset;
    if (!lex_17(lexer_state)) {
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
static bool lex_16(LexerState *lexer_state) {
  size_t start = lexer_state->offset;

  if (!lex_22(lexer_state)) {
    lexer_state->offset = start;
    return false;
  }

  return true;
}

/* Token wrapper: lex_whitespace */
static size_t lex_whitespace(LexerState *lexer_state) {
  if (!lex_16(lexer_state)) {
    return 0;
  }

  /* If group_offset was set by a capturing group, prefer it; else use offset.
   */
  if (lexer_state->group_offset != 0) {
    return lexer_state->group_offset;
  }
  return lexer_state->offset;
}

/* Exact */
static bool lex_24(LexerState *lexer_state) {
  size_t start = lexer_state->offset;

  if (lexer_state->offset >= lexer_state->len) {
    lexer_state->offset = start;
    return false;
  }
  if ((unsigned char)lexer_state->data[lexer_state->offset] !=
      (unsigned char)34) {
    lexer_state->offset = start;
    return false;
  }
  lexer_state->offset += 1;

  return true;
}

/* RegexChar */
static bool lex_26(LexerState *lexer_state) {
  if (lexer_state->offset >= lexer_state->len) {
    return false; /* EOF */
  }

  if ((unsigned char)lexer_state->data[lexer_state->offset] ==
      (unsigned char)34) {
    lexer_state->offset += 1;
    return true;
  }

  return false;
}

/* RegexNegatedChoice */
static bool lex_25(LexerState *lexer_state) {
  size_t len = lexer_state->len;
  size_t start = lexer_state->offset;

  if (lex_26(lexer_state)) {
    lexer_state->offset = start;
    return false;
  }

  if (lexer_state->offset == len) {
    return true; /* EOF: succeed without consuming */
  }

  lexer_state->offset += 1; /* consume one byte/char */
  return true;
}

/* Rep0Regex */
static bool lex_27(LexerState *lexer_state) {
  for (;;) {
    size_t before = lexer_state->offset;
    if (!lex_25(lexer_state)) {
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

/* Exact */
static bool lex_28(LexerState *lexer_state) {
  size_t start = lexer_state->offset;

  if (lexer_state->offset >= lexer_state->len) {
    lexer_state->offset = start;
    return false;
  }
  if ((unsigned char)lexer_state->data[lexer_state->offset] !=
      (unsigned char)34) {
    lexer_state->offset = start;
    return false;
  }
  lexer_state->offset += 1;

  return true;
}

/* RegexSeq */
static bool lex_23(LexerState *lexer_state) {
  size_t start = lexer_state->offset;

  if (!lex_24(lexer_state)) {
    lexer_state->offset = start;
    return false;
  }

  if (!lex_27(lexer_state)) {
    lexer_state->offset = start;
    return false;
  }

  if (!lex_28(lexer_state)) {
    lexer_state->offset = start;
    return false;
  }

  return true;
}

/* Token wrapper: lex_str */
static size_t lex_str(LexerState *lexer_state) {
  if (!lex_23(lexer_state)) {
    return 0;
  }

  /* If group_offset was set by a capturing group, prefer it; else use offset.
   */
  if (lexer_state->group_offset != 0) {
    return lexer_state->group_offset;
  }
  return lexer_state->offset;
}

/* RegexRange */
static bool lex_31(LexerState *lexer_state) {
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
static bool lex_30(LexerState *lexer_state) {
  size_t start = lexer_state->offset;

  lexer_state->offset = start;
  if (lex_31(lexer_state)) {
    return true;
  }

  lexer_state->offset = start;
  return false;
}

/* Rep1Regex */
static bool lex_32(LexerState *lexer_state) {
  size_t start = lexer_state->offset;

  if (lexer_state->offset >= lexer_state->len) {
    return false;
  }
  if (!lex_30(lexer_state)) {
    lexer_state->offset = start;
    return false;
  }

  for (;;) {
    size_t before = lexer_state->offset;
    if (!lex_30(lexer_state)) {
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
static bool lex_29(LexerState *lexer_state) {
  size_t start = lexer_state->offset;

  if (!lex_32(lexer_state)) {
    lexer_state->offset = start;
    return false;
  }

  return true;
}

/* Token wrapper: lex_int */
static size_t lex_int(LexerState *lexer_state) {
  if (!lex_29(lexer_state)) {
    return 0;
  }

  /* If group_offset was set by a capturing group, prefer it; else use offset.
   */
  if (lexer_state->group_offset != 0) {
    return lexer_state->group_offset;
  }
  return lexer_state->offset;
}

/* Exact */
static bool lex_34(LexerState *lexer_state) {
  size_t start = lexer_state->offset;

  if (lexer_state->offset >= lexer_state->len) {
    lexer_state->offset = start;
    return false;
  }
  if ((unsigned char)lexer_state->data[lexer_state->offset] !=
      (unsigned char)58) {
    lexer_state->offset = start;
    return false;
  }
  lexer_state->offset += 1;

  return true;
}

/* RegexSeq */
static bool lex_33(LexerState *lexer_state) {
  size_t start = lexer_state->offset;

  if (!lex_34(lexer_state)) {
    lexer_state->offset = start;
    return false;
  }

  return true;
}

/* Token wrapper: lex_colon */
static size_t lex_colon(LexerState *lexer_state) {
  if (!lex_33(lexer_state)) {
    return 0;
  }

  /* If group_offset was set by a capturing group, prefer it; else use offset.
   */
  if (lexer_state->group_offset != 0) {
    return lexer_state->group_offset;
  }
  return lexer_state->offset;
}

/* Exact */
static bool lex_36(LexerState *lexer_state) {
  size_t start = lexer_state->offset;

  if (lexer_state->offset >= lexer_state->len) {
    lexer_state->offset = start;
    return false;
  }
  if ((unsigned char)lexer_state->data[lexer_state->offset] !=
      (unsigned char)44) {
    lexer_state->offset = start;
    return false;
  }
  lexer_state->offset += 1;

  return true;
}

/* RegexSeq */
static bool lex_35(LexerState *lexer_state) {
  size_t start = lexer_state->offset;

  if (!lex_36(lexer_state)) {
    lexer_state->offset = start;
    return false;
  }

  return true;
}

/* Token wrapper: lex_comma */
static size_t lex_comma(LexerState *lexer_state) {
  if (!lex_35(lexer_state)) {
    return 0;
  }

  /* If group_offset was set by a capturing group, prefer it; else use offset.
   */
  if (lexer_state->group_offset != 0) {
    return lexer_state->group_offset;
  }
  return lexer_state->offset;
}

/* Exact */
static bool lex_38(LexerState *lexer_state) {
  size_t start = lexer_state->offset;

  if (lexer_state->offset >= lexer_state->len) {
    lexer_state->offset = start;
    return false;
  }
  if ((unsigned char)lexer_state->data[lexer_state->offset] !=
      (unsigned char)91) {
    lexer_state->offset = start;
    return false;
  }
  lexer_state->offset += 1;

  return true;
}

/* RegexSeq */
static bool lex_37(LexerState *lexer_state) {
  size_t start = lexer_state->offset;

  if (!lex_38(lexer_state)) {
    lexer_state->offset = start;
    return false;
  }

  return true;
}

/* Token wrapper: lex_l_bracket */
static size_t lex_l_bracket(LexerState *lexer_state) {
  if (!lex_37(lexer_state)) {
    return 0;
  }

  /* If group_offset was set by a capturing group, prefer it; else use offset.
   */
  if (lexer_state->group_offset != 0) {
    return lexer_state->group_offset;
  }
  return lexer_state->offset;
}

/* Exact */
static bool lex_40(LexerState *lexer_state) {
  size_t start = lexer_state->offset;

  if (lexer_state->offset >= lexer_state->len) {
    lexer_state->offset = start;
    return false;
  }
  if ((unsigned char)lexer_state->data[lexer_state->offset] !=
      (unsigned char)93) {
    lexer_state->offset = start;
    return false;
  }
  lexer_state->offset += 1;

  return true;
}

/* RegexSeq */
static bool lex_39(LexerState *lexer_state) {
  size_t start = lexer_state->offset;

  if (!lex_40(lexer_state)) {
    lexer_state->offset = start;
    return false;
  }

  return true;
}

/* Token wrapper: lex_r_bracket */
static size_t lex_r_bracket(LexerState *lexer_state) {
  if (!lex_39(lexer_state)) {
    return 0;
  }

  /* If group_offset was set by a capturing group, prefer it; else use offset.
   */
  if (lexer_state->group_offset != 0) {
    return lexer_state->group_offset;
  }
  return lexer_state->offset;
}

/* Exact */
static bool lex_42(LexerState *lexer_state) {
  size_t start = lexer_state->offset;

  if (lexer_state->offset >= lexer_state->len) {
    lexer_state->offset = start;
    return false;
  }
  if ((unsigned char)lexer_state->data[lexer_state->offset] !=
      (unsigned char)123) {
    lexer_state->offset = start;
    return false;
  }
  lexer_state->offset += 1;

  return true;
}

/* RegexSeq */
static bool lex_41(LexerState *lexer_state) {
  size_t start = lexer_state->offset;

  if (!lex_42(lexer_state)) {
    lexer_state->offset = start;
    return false;
  }

  return true;
}

/* Token wrapper: lex_l_brace */
static size_t lex_l_brace(LexerState *lexer_state) {
  if (!lex_41(lexer_state)) {
    return 0;
  }

  /* If group_offset was set by a capturing group, prefer it; else use offset.
   */
  if (lexer_state->group_offset != 0) {
    return lexer_state->group_offset;
  }
  return lexer_state->offset;
}

/* Exact */
static bool lex_44(LexerState *lexer_state) {
  size_t start = lexer_state->offset;

  if (lexer_state->offset >= lexer_state->len) {
    lexer_state->offset = start;
    return false;
  }
  if ((unsigned char)lexer_state->data[lexer_state->offset] !=
      (unsigned char)125) {
    lexer_state->offset = start;
    return false;
  }
  lexer_state->offset += 1;

  return true;
}

/* RegexSeq */
static bool lex_43(LexerState *lexer_state) {
  size_t start = lexer_state->offset;

  if (!lex_44(lexer_state)) {
    lexer_state->offset = start;
    return false;
  }

  return true;
}

/* Token wrapper: lex_r_brace */
static size_t lex_r_brace(LexerState *lexer_state) {
  if (!lex_43(lexer_state)) {
    return 0;
  }

  /* If group_offset was set by a capturing group, prefer it; else use offset.
   */
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
    size_t res_0 = lex_true(&st);
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
    size_t res_1 = lex_false(&st);
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
    size_t res_2 = lex_whitespace(&st);
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
    size_t res_3 = lex_str(&st);
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
    size_t res_4 = lex_int(&st);
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
    size_t res_5 = lex_colon(&st);
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
    size_t res_6 = lex_comma(&st);
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
    size_t res_7 = lex_l_bracket(&st);
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
    size_t res_8 = lex_r_bracket(&st);
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

    st.group_offset = 0;
    size_t res_9 = lex_l_brace(&st);
    if (res_9 != 0) {
      /* Guard against pathological over-consumption */
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

      /* Advance the input window by res bytes */
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
    size_t res_10 = lex_r_brace(&st);
    if (res_10 != 0) {
      /* Guard against pathological over-consumption */
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

      /* Advance the input window by res bytes */
      ptr += res_10;
      len -= res_10;

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
          .kind = (uint32_t)11,
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
