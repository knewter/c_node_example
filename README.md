# Erlang C Node Example

This is an effort to show off erlang/c interop.  In theory, it was going to encapsulate a C node, but it might just do a port for now...

## To see it in action

First, compile the C program and the beamfiles:

```sh
rebar compile
rebar compile
```

NOTE - yes, run it twice for now, because I don't know how to fix a bug in the
build process yet...

Next, run an erlang console with `erl -pa ebin`.

Now call `foo/1` and `bar/1` on the `complex` module:

```erlang
complex:start().
complex:foo(1).
complex:bar(1).
```
