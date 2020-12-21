# Concurrent File-System ; Operating Systems I, final project.

Implementation of a distributed file system that enables users to share files in a network. The filesystem acts as a server, listening in TCP port 8000. It communicates with users by sending strings over a TCP socket. 

A basic set of operations was implemented so that users can manipullate files. There are two different implementations of the same filesystem:

Implementation 1: Language C (Using POSIX Threads)
Implementation 2: Language Erlang

A detailed repor (in Spanish) can be found in Concurrent-File-System/blob/master/informe.pdf
