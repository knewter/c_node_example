all: clean build

build:
	gcc -o out/c_node -I/usr/lib/erlang/ -I/usr/lib/erlang/lib/erl_interface-3.7.15/include/ -L/usr/lib/erlang/lib/erl_interface-3.7.15/lib c_src/erl_comm.c c_src/c_node.c -lerl_interface -lei -lpthread

clean:
	rm -fr out/c_node
