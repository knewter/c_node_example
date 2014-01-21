-module(complex).
-export([start/0, init/0]).
-export([img/1, benchmark/1, do_benchmark/2]).

start() ->
  spawn(?MODULE, init, []).

init() ->
  process_flag(trap_exit, true),
  Port = open_port({spawn, 'priv/c_node'}, [{packet, 2}, binary]),
  loop(Port, self()).

img(ReceiverPid) ->
  Pid = start(),
  ReceiverPid ! {data, call_port(Pid, {img})}.

call_port(Pid, Msg) ->
  Pid ! {call, self(), Msg},
  receive
    {_Pid, Result} ->
      Result
  end.

loop(Port, Pid) ->
  receive
    {call, Caller, Msg} ->
      Port ! {self(), {command, term_to_binary(Msg)}},
      receive
        {Port, {data, Data}} ->
          Caller ! {Pid, binary_to_term(Data)}
      end,
      loop(Port, Pid);
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
  Pid = self(),
  timer:tc(?MODULE, do_benchmark, [Pid, Number]).

do_benchmark(_Pid, 0) ->
  receive
    {data, SomeData} -> do_benchmark(_Pid, 0)
  after
    1 -> ok
  end;
do_benchmark(Pid, Number) ->
  spawn(?MODULE, img, [Pid]),
  do_benchmark(Pid, Number-1).
