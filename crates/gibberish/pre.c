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
