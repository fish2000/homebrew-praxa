
class Libimread < Formula
  homepage "https://github.com/fish2000/libimread"
  url "https://github.com/fish2000/libimread.git", :using => :git
  version "0.2.0"
  
  option "without-tests",
         "Skip running tests"
  option "without-apps",
         "Skip building companion apps"
  option "with-extra-tests",
       %s[Run an extra test phase and post results to the project CDash:
             http://my.cdash.org/index.php?project=libimread]
  option "with-brewed-clang",
         "Compile using Clang from Homebrew-installed LLVM package"
  
  depends_on "cmake"          =>  :build
  depends_on "llvm"           =>  :build
  depends_on "pkg-config"     =>  :build
  depends_on :python          =>  :optional
  depends_on "hdf5"
  depends_on "libjpeg"
  depends_on "libpng"
  depends_on "libtiff"
  depends_on "webp"
  # depends_on "zlib"
  cxxstdlib_check :skip
  
  def install
    
    # Use brewed clang
    if build.with? "brewed-clang"
      ENV['CC'] = Formula['llvm'].opt_prefix/"bin/clang"
      ENV['CXX'] = Formula['llvm'].opt_prefix/"bin/clang++"
    end
    
    ENV.append 'CXXFLAGS', "-std=c++1z"
    ENV.append 'CXXFLAGS', "-stdlib=libc++"
    
    cargs = std_cmake_args
    cargs.keep_if { |v| v !~ /DCMAKE_VERBOSE_MAKEFILE/ }
    
    if build.without? "apps"
      cargs << "-DIM_APPS=OFF"
    end
    
    cargs << "-DIM_COLOR_TRACE=ON"
    cargs << "-DIM_COVERAGE=OFF"
    cargs << "-DIM_TERMINATOR=ON"
    cargs << "-DIM_VERBOSE=ON"
    
    if build.without? "tests"
      cargs << "-DIM_TESTS=OFF"
    end
    
    mkdir "build" do
      system "cmake", "..", *cargs
      system "make", "install"
      if not build.without? "tests"
        bin.install "imread_tests"
      end
    end
    
    if build.with? :python
      cd "python" do
        bin.mkdir
        lib.mkdir
        pylib = lib/"python2.7/site-packages"
        ENV.prepend_create_path "PYTHONPATH", pylib
        system "python", "setup.py", "build"
        system "python", "setup.py", "install",
                         "--prefix=#{prefix}",
                         "--install-scripts=#{bin}",
                         "--install-lib=#{pylib}"
      end
    end
    
    if build.with? "extra-tests"
      cd "build" do
        begin
          system "ctest", "-j8",
                          "-D", "Experimental",
                          "--output-on-failure"
        rescue BuildError
          opoo "[install] not all tests passed"
        end
      end
    end
    
  end # install
  
  def test
    
    if not build.without? "tests"
      begin
        system bin/"imread_tests", "--success",
                                   "--durations", "yes",
                                   "--abortx", "10"
      rescue BuildError
        opoo "[test] not all tests passed"
      end
    end
    
  end # test
  
end
