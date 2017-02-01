DEPS = jinja2 pyyaml


templated: env/bin/pip templated.py Makefile
	rm -rf build
	mkdir build
	pip download $(DEPS) -d build
	cp templated.py build/__main__.py
	env/bin/python -m zipapp -p "/usr/bin/env python" build -o templated

env/bin/pip:
	virtualenv env --python python3
	env/bin/pip install -U pip

clean:
	rm -rf build
