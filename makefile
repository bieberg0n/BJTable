main:
	rebar3 compile

run:
	rebar3 compile
	erl -pa ./_build/default/lib/bjtable/ebin/ -noshell -s bjtable main -s init stop
