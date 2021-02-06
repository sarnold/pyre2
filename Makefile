install2:
	python2 setup.py install --user

test: install
	(cd tests && python re2_test.py)
	(cd tests && python test_re.py)

install:
	python setup.py install --user

test2: install2
	(cd tests && python2 re2_test.py)
	(cd tests && python2 test_re.py)

clean:
	rm -rf build &>/dev/null
	rm -rf src/*.so src/*.html &>/dev/null
	rm -rf *.so tests/*.so &>/dev/null
	rm -rf src/re2.cpp &>/dev/null

valgrind:
	python-dbg setup.py install --user && \
	(cd tests && valgrind --tool=memcheck --suppressions=../valgrind-python.supp \
	--leak-check=full --show-leak-kinds=definite \
	python-dbg test_re.py)

valgrind2:
	python-dbg setup.py install --user && \
	(cd tests && valgrind --tool=memcheck --suppressions=../valgrind-python.supp \
	--leak-check=full --show-leak-kinds=definite \
	python-dbg re2_test.py)
