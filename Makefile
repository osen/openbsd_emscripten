COMMENT=	toolchain for compiling C and C++ to asm.js and WebAssembly

PKGNAME=	emscripten-${VERSION}
VERSION=	1.38.31
REVISION=	1

DISTNAME=	${VERSION}
DIST_SUBDIR=	emscripten

CATEGORIES=	devel

MASTER_SITES0=	https://github.com/emscripten-core/
MASTER_SITES1=	https://github.com/WebAssembly/
DISTFILES=	emscripten-{emscripten/archive/}${DISTNAME}${EXTRACT_SUFX}:0 \
		fastcomp-{emscripten-fastcomp/archive/}${DISTNAME}${EXTRACT_SUFX}:0 \
		fastcomp-clang-{emscripten-fastcomp-clang/archive/}${DISTNAME}${EXTRACT_SUFX}:0 \
		binaryen-{binaryen/archive/}${DISTNAME}${EXTRACT_SUFX}:1

HOMEPAGE=	https://emscripten.org/

PERMIT_PACKAGE_CDROM=	Yes

WRKDIST=${WRKDIR}/work

post-extract:
	mkdir ${WRKDIST}
	mv ${WRKDIR}/emscripten-${VERSION} ${WRKDIST}/emscripten
	mv ${WRKDIR}/emscripten-fastcomp-${VERSION} ${WRKDIST}/fastcomp
	mv ${WRKDIR}/emscripten-fastcomp-clang-${VERSION} ${WRKDIST}/fastcomp/tools/clang
	mv ${WRKDIR}/binaryen-${VERSION} ${WRKDIST}/binaryen

do-configure:
	rm -r -f ${WRKBUILD}/binaryen/build
	mkdir ${WRKBUILD}/binaryen/build

	cd ${WRKBUILD}/binaryen/build && cmake .. \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_INSTALL_PREFIX=${WRKBUILD}/emscripten/binaryen

	rm -r -f ${WRKBUILD}/fastcomp/build
	mkdir ${WRKBUILD}/fastcomp/build

	cd ${WRKBUILD}/fastcomp/build && cmake .. \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_INSTALL_PREFIX=${WRKBUILD}/emscripten/fastcomp \
		-DLLVM_TARGETS_TO_BUILD="host;JSBackend" \
		-DLLVM_INCLUDE_EXAMPLES=OFF \
		-DLLVM_INCLUDE_TESTS=OFF \
		-DCLANG_INCLUDE_TESTS=OFF

do-build:
	rm -r -f ${WRKBUILD}/wbin
	mkdir ${WRKBUILD}/wbin
	ln -s /usr/local/bin/python3 ${WRKBUILD}/wbin/python

	rm -r -f ${WRKBUILD}/emscripten/binaryen
	cd ${WRKBUILD}/binaryen && PATH=${PATH}:${WRKBUILD}/wbin cmake --build build --target install

	rm -r -f ${WRKBUILD}/emscripten/fastcomp
	cd ${WRKBUILD}/fastcomp && cmake --build build --target install

do-install:
	cp -r "${WRKSRC}/emscripten" "${PREFIX}/emscripten"
	cat "${FILESDIR}/emcc" > "${PREFIX}/bin/emcc"
	chmod +x "${PREFIX}/bin/emcc"
	cp "${PREFIX}/bin/emcc" "${PREFIX}/bin/em++"
	cp "${PREFIX}/bin/emcc" "${PREFIX}/bin/emmake"
	cp "${PREFIX}/bin/emcc" "${PREFIX}/bin/emcmake"
	cp "${PREFIX}/bin/emcc" "${PREFIX}/bin/emconfigure"
	cp "${PREFIX}/bin/emcc" "${PREFIX}/bin/emrun"

.include <bsd.port.mk>
