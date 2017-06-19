DEPS = jinja2 pyyaml


contemplate: env/bin/pip contemplate.py build.py Makefile
	rm -rf build
	mkdir build
	env/bin/pip install $(DEPS) -t build
	rm -rf build/*-info build/*/__pycache__
	rm build/markupsafe/_speedups*
	cp contemplate.py build/__main__.py
	env/bin/python build.py

env/bin/pip:
	virtualenv env --python python3
	env/bin/pip install -U pip
	env/bin/pip install $(DEPS)

clean:
	rm -rf build env contemplate

.PHONY: test
test: contemplate env/bin/pip 
	./tests.sh

debug:
	EXEC="env/bin/python contemplate.py" ./tests.sh
