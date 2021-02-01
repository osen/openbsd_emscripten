COMMENT=	toolchain for compiling C and C++ to asm.js and WebAssembly
VERSION=	2.0.12
PKGNAME=	emscripten-${VERSION}
REVISION=	1
DIST_SUBDIR=	emscripten
CATEGORIES=	devel
HOMEPAGE=	https://emscripten.org/

LLVM_VERSION=	12.0.0-rc1
BINARYEN_VERSION=	99

# MIT
PERMIT_PACKAGE=	Yes

MASTER_SITES0=	https://github.com/emscripten-core/
MASTER_SITES1=	https://github.com/llvm/
MASTER_SITES2=	https://github.com/WebAssembly/

#llvm{llvm-project/archive/llvmorg}-${LLVM_VERSION}${EXTRACT_SUFX}:1 \
#llvm-current{llvm-project/archive/main}${EXTRACT_SUFX}:1 \

DISTFILES=	emscripten-{emscripten/archive/}${VERSION}${EXTRACT_SUFX}:0 \
		llvm{llvm-project/archive/llvmorg}-${LLVM_VERSION}${EXTRACT_SUFX}:1 \
		binaryen-{binaryen/archive/version_}${BINARYEN_VERSION}${EXTRACT_SUFX}:2

BUILD_DEPENDS=	devel/cmake

LIB_DEPENDS=	lang/python/3.8
RUN_DEPENDS=	lang/node

#mv "${WRKDIR}/llvm-project-llvmorg-${LLVM_VERSION}" "${WRKDIR}/llvm"
#mv "${WRKDIR}/llvm-project-main" "${WRKDIR}/llvm"

post-extract:
	mv "${WRKDIR}/binaryen-version_${BINARYEN_VERSION}" "${WRKDIR}/binaryen"
	mv "${WRKDIR}/emscripten-${VERSION}" "${WRKDIR}/emscripten"
	mv "${WRKDIR}/llvm-project-llvmorg-${LLVM_VERSION}" "${WRKDIR}/llvm"

#-DLLVM_TARGETS_TO_BUILD="host;WebAssembly" \

do-configure:
	mkdir "${WRKDIR}/llvm/build"

	cd "${WRKDIR}/llvm/build" && cmake \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_INSTALL_PREFIX="${WRKDIR}/emscripten/llvm" \
		-DCMAKE_DISABLE_FIND_PACKAGE_LibXml2:Bool=True \
		-DCMAKE_DISABLE_FIND_PACKAGE_Backtrace:Bool=True \
		-DLLVM_VERSION_SUFFIX='' \
		-DLLVM_ENABLE_PROJECTS='lld;clang' \
		-DLLVM_TARGETS_TO_BUILD="WebAssembly" \
		-DLLVM_LINK_LLVM_DYLIB:Bool=True \
		-DLLVM_BUILD_LLVM_DYLIB:Bool=True \
		-DLLVM_INCLUDE_EXAMPLES=OFF \
		-DLLVM_INCLUDE_TESTS=OFF \
		../llvm

	mkdir "${WRKDIR}/binaryen/build"
	cd "${WRKDIR}/binaryen/build" && cmake \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_INSTALL_PREFIX="${WRKDIR}/emscripten/binaryen" \
		..

	cd "${WRKDIR}/emscripten" && rm -r .*
	cd "${WRKDIR}/emscripten" && rm *.bat
	cd "${WRKDIR}/emscripten" && npm ci --no-optional --ignore-scripts

do-build:
	cd "${WRKDIR}/llvm" && cmake --build build
	cd "${WRKDIR}/llvm" && cmake --build build --target install
	cd "${WRKDIR}/binaryen" && cmake --build build
	cd "${WRKDIR}/binaryen" && cmake --build build --target install

do-install:
	cp -rv "${WRKDIR}/emscripten" "${PREFIX}/libexec/emscripten"
	install "${FILESDIR}/site_emscripten" "${PREFIX}/libexec/emscripten/.emscripten"
	install "${FILESDIR}/emcc" "${PREFIX}/bin/emcc"
	install "${FILESDIR}/emcc" "${PREFIX}/bin/em++"

.include <bsd.port.mk>

