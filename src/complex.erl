-module(complex).
-export([start/0, init/0]).
-export([img/0, benchmark/1, do_benchmark/1]).

start() ->
  spawn(?MODULE, init, []).

init() ->
  register(complex, self()),
  process_flag(trap_exit, true),
  Port = open_port({spawn, 'priv/c_node'}, [{packet, 2}, binary]),
  loop(Port).

img() ->
  call_port({img}).

call_port(Msg) ->
  complex ! {call, self(), Msg},
  receive
    {complex, Result} ->
      Result
  end.

loop(Port) ->
  receive
    {call, Caller, Msg} ->
      Port ! {self(), {command, term_to_binary(Msg)}},
      receive
        {Port, {data, Data}} ->
          Caller ! {complex, binary_to_term(Data)}
      end,
      loop(Port);
	stop ->
	  Port ! {self(), close},
	  receive
        {Port, closed} ->
          exit(normal)
      end;
    {'EXIT', _Port, _Reason} ->
      exit(port_terminated)
  end.

%% This is just used to benchmark how many images we can do per second...
benchmark(Number) ->
  timer:tc(?MODULE, do_benchmark, [Number]).

do_benchmark(0) ->
  ok;
do_benchmark(Number) ->
  img(),
  do_benchmark(Number-1).
