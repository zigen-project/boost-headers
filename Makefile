tag = boost-1.80.0
mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfile_dir := $(dir $(mkfile_path))

.PHONY: install
install: include/boost/version.hpp Boost_README.md Boost_LICENSE_1_0.txt Boost_COMMIT_HASH.txt
	rm -rf lib # This contains builder's personal information

include/boost/version.hpp: builddir/boost/b2
	cd ${mkfile_dir}builddir/boost; \
	./b2 install                    \
	  --with-headers                \
	  --prefix=${mkfile_dir}

Boost_README.md: builddir/boost/README.md
	cp builddir/boost/README.md Boost_README.md

Boost_LICENSE_1_0.txt: builddir/boost/README.md
	cp builddir/boost/LICENSE_1_0.txt Boost_LICENSE_1_0.txt

Boost_COMMIT_HASH.txt: builddir/boost/README.md
	cd builddir/boost; \
	git rev-parse HEAD > ${mkfile_dir}Boost_COMMIT_HASH.txt

builddir/boost/b2: builddir/boost/libs/headers/README.md
	cd builddir/boost; \
	./bootstrap.sh

builddir/boost/libs/headers/README.md: builddir/boost/README.md
	cd builddir/boost; \
	git submodule update --init --recursive --recommend-shallow --depth 1 

builddir/boost/README.md: builddir
	git clone           \
		--quiet         \
	  	--depth 1       \
	  	--single-branch \
	  	-b ${tag}       \
	  	https://github.com/boostorg/boost.git builddir/boost

builddir:
	cd mkfile_dir; \
	mkdir builddir

.PHONY: clean
clean:
	rm -rf builddir
	rm -rf include
	rm -rf lib
	rm -f Boost_COMMIT_HASH.txt
	rm -f Boost_LICENSE_1_0.txt
	rm -f Boost_README.md
