respond (Handler, Msg) ->
  Handler ! {self(), Msg}.
