# Erlang C Node Example

This is an effort to show off erlang/c interop.  In theory, it was going to encapsulate a C node, but it might just do a port for now...

## To see it in action

First, compile the C program:

```sh
make
```

Next, run an erlang console with `erl`.

Now compile the `complex` module, and call `foo/1` and `bar/1` on it.

```erlang
c('src/complex').
complex:start('out/c_node').
complex:foo(1).
complex:bar(1).
```
