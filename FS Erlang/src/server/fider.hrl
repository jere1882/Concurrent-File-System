% proceso que estará todo el tiempo corriendo en paralelo a nuestro servidor.
% se encarga de recibir solicitudes de los 5 workers. Ellos le piden un ID fresco
% cada vez que intentan agregar un archivo, para ponerle ese id al archivo y asegurarse
% de que ningun otro worker tiene ese id usado.


fider(CurrFid) ->
  receive
    Worker ->
      Worker ! CurrFid,
      fider(CurrFid + 1)
  end.
