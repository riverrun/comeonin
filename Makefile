ERLANG_PATH:=$(shell erl -eval 'io:format("~s~n", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)
CFLAGS_BCRYPT=-g -fPIC -O3
CFLAGS=$(CFLAGS_BCRYPT) -Ic_src
ERLANG_FLAGS=-I$(ERLANG_PATH)
EBIN_DIR=ebin

ifeq ($(shell uname),Darwin)
    OPTIONS=-dynamiclib -undefined dynamic_lookup
endif

NIF_SRC=\
	c_src/bcrypt_nif.c\
	c_src/bcrypt.c\
	c_src/blowfish.c

all: compile

priv/bcrypt_nif.so:
	$(CC) $(CFLAGS) $(ERLANG_FLAGS) -shared $(OPTIONS) $(NIF_SRC) -o $@

compile:
	mix compile

.PHONY: all compile
