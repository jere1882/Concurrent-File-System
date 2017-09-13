-module(client).
-export([test/0, prompt/0]).

-import(timer, [sleep/1]).

start() ->
  gen_tcp:connect(
    {127,0,0,1}, 8000, [{active, true}]).

test() ->
  {ok, Socket} = start(),
  io:format("~n"),
  test_aux(Socket, [
    "CRE lala"
  ]).
test_aux(Socket, [Command | Cmds]) ->
  io:format("> ~s~n", [Command]),
  gen_tcp:send(Socket, Command),
  receive
    {tcp, _, Response} ->
      io:format("~s~n", [Response]),
      test_aux(Socket, Cmds);
    _ -> throw(test_aux)
  end;
test_aux(Socket, []) ->
  Socket.

prompt() ->
  Msg = io:get_line("> "),
  if
    Msg == "CON\n" ->
      {ok, Socket} = start(),
      io:format("OK ~n"),
      prompt(Socket);
    true ->
      io:format("Start a new connection "
        ++ "with `CON`~n"),
      prompt()
  end.

prompt(Socket) ->
  Request = io:get_line("> "),
  gen_tcp:send(Socket, Request),
  receive
    {tcp, _, Response} ->
      io:format("~s~n", [Response]),
      prompt(Socket);
    _ ->
      throw(prompt)
  end.
