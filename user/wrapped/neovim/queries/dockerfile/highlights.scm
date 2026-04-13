[
  "FROM"
  "AS"
  "RUN"
  "CMD"
  "LABEL"
  "EXPOSE"
  "ENV"
  "ADD"
  "COPY"
  "ENTRYPOINT"
  "VOLUME"
  "USER"
  "WORKDIR"
  "ARG"
  "ONBUILD"
  "STOPSIGNAL"
  "HEALTHCHECK"
  "SHELL"
  "MAINTAINER"
  "CROSS_BUILD"
] @keyword

[
  ":"
  "@"
] @operator

(comment) @comment @spell

(image_spec
  (image_tag
    ":" @punctuation.special)
  (image_digest
    "@" @punctuation.special))

(double_quoted_string) @string

[
  (heredoc_marker)
  (heredoc_end)
] @label

((heredoc_block
  (heredoc_line) @string)
  (#set! priority 90))

(expansion
  [
    "$"
    "{"
    "}"
  ] @punctuation.special)

((variable) @constant
  (#lua-match? @constant "^[A-Z][A-Z_0-9]*$"))

(arg_instruction
  .
  (unquoted_string) @property)

(env_instruction
  (env_pair
    .
    (unquoted_string) @property))

(expose_instruction
  (expose_port) @number)

(json_string) @string

(unquoted_string) @string

(image_spec) @type

(path) @string.special.path

(param) @parameter

(env_pair
  name: (unquoted_string) @variable.parameter
  "=" @operator
  value: [
    (unquoted_string)
    (single_quoted_string)
    (double_quoted_string)
  ] @string)

(arg_instruction
  name: (unquoted_string) @variable.parameter
  "=" @operator
  value: (unquoted_string)? @string)

(mount_param) @variable.parameter
