# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder, Pkg

name = "HPIPM"
version = v"0.1.4"

# Collection of sources required to complete build
sources = [
    #ArchiveSource("https://github.com/giaf/blasfeo/archive/refs/tags/$(version).2.tar.gz", "df990206225095fb97ca1b1a3ebfe34cbc2cea7a8b2643ed3a6deb28a1848aa2"),
    GitSource(
        "https://github.com/giaf/blasfeo.git",
        "0ab5db3259c009ea62318a5e35622fe6de7ae554"
    )
    GitSource(
        "https://github.com/giaf/hpipm.git",
        "e4e34b3ab46bcc787bcaf04e5e13a2c394c412e2",
    )
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
cd blasfeo
export BLASFEO_TARGET="X64_INTEL_HASWELL"
if [[ "$bb_full_target" == *"avx512" ]]; then
    BLASFEO_TARGET="X64_INTEL_SKYLAKE_X"
elif [[ "$bb_full_target" == *"avx2" ]]; then
    BLASFEO_TARGET="X64_INTEL_HASWELL"
elif [[ "$bb_full_target" == *"avx" ]]; then
    BLASFEO_TARGET="X64_INTEL_HASWELL"
else
    BLASFEO_TARGET="X64_INTEL_SANDY_BRIDGE"
fi
echo "BLASFEO Target: $BLASFEO_TARGET"
cmake -B build -DCMAKE_INSTALL_PREFIX=$prefix  -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TARGET_TOOLCHAIN} -DCMAKE_BUILD_TYPE=Release -D TARGET=$BLASFEO_TARGET -D LA=HIGH_PERFORMANCE -D MF=PANELMAJ -D BUILD_SHARED_LIBS=OFF
cmake --build build --parallel ${nproc}
cmake --install build
cd ../hpipm/
cmake -B build -DCMAKE_INSTALL_PREFIX=$prefix -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TARGET_TOOLCHAIN} -DCMAKE_BUILD_TYPE=Release -D TARGET=AVX -D BLASFEO_PATH=$prefix -D BUILD_SHARED_LIBS=ON -D HPIPM_TESTING=OFF -D HPIPM_BLASFEO_LIB=Static
cmake --build build --parallel ${nproc}
cmake --install build
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Platform("x86_64", "linux"; libc = "glibc", march = "avx2"),
    Platform("x86_64", "linux"; libc = "musl", march = "avx2"),
    # Platform("x86_64", "linux"; libc = "glibc", march = "avx512"),
    # Platform("x86_64", "linux"; libc = "musl", march = "avx512"),
]


# The products that we will ensure are always built
products = [
    # LibraryProduct("libblasfeo", :libblasfeo),
    LibraryProduct("libhpipm", :libhpipm),
]

# Dependencies that must be installed before this package can be built
dependencies = Dependency[]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(
    ARGS,
    name,
    version,
    sources,
    script,
    platforms,
    products,
    dependencies;
    julia_compat = "1.6",
)
