MODULES = time_compat_old.beam \
	  time_compat_new.beam \
	  time_compat.beam \
	  test.beam

all: build

build: $(MODULES)

test: build
	erl -noinput -A0 -pa . -s test -s init stop

clean:
	rm -f $(MODULES)

.NOTPARALLEL:

time_compat_old.beam: ERLC_FLAGS = -DOLD_API
time_compat_new.beam: ERLC_FLAGS = -DNEW_API
time_compat.beam:

test.beam: test.erl
	erlc -Wall $<

time_compat.beam time_compat_old.beam time_compat_new.beam: time_compat.erl
	erlc -Wall $(ERLC_FLAGS) $<
	mv time_compat.beam $@
