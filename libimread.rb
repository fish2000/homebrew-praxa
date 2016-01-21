
class Libimread < Formula
  homepage "https://github.com/fish2000/libimread"
  url "https://github.com/fish2000/libimread.git", :using => :git
  version "0.2.0"
  
  option "skip-tests",
         "Skip running tests"
  option "with-brewed-clang",
         "Compile using Clang from Homebrew-installed LLVM package"
  
  depends_on "cmake"          =>  :build
  depends_on "llvm"           =>  :build
  depends_on "pkg-config"     =>  :build
  # depends_on "iod-symbolizer" => [:python, :build]
  depends_on :python          =>  :optional
  depends_on "hdf5"
  depends_on "libjpeg"
  depends_on "libpng"
  depends_on "libtiff"
  depends_on "webp"
  depends_on "zlib"
  
  def install
    # Use brewed clang
    if build.with? "brewed-clang"
      ENV['CC'] = Formula['llvm'].opt_prefix/"bin/clang"
      ENV['CXX'] = Formula['llvm'].opt_prefix/"bin/clang++"
    end
    ENV.cxx11
    
    cargs = std_cmake_args
    cargs.keep_if { |v| v !~ /DCMAKE_VERBOSE_MAKEFILE/ }
    
    mkdir "build" do
      system "cmake", "..", *cargs
      system "make", "install"
      bin.install "imread_tests"
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
    
    if not build.with? "skip-tests"
      cd "build" do
        system "ctest", "-j4",
                        "-D", "Experimental",
                        "--output-on-failure"
      end
    end
    
  end
  
  def test
    system bin/"imread_tests", "--success",
                               "--durations", "yes",
                               "--abortx", "10"
  end
  
end
