
class Libimread < Formula
  homepage "https://github.com/fish2000/libimread"
  url "https://github.com/fish2000/libimread.git", :using => :git
  version "0.1.0"
  
  depends_on "cmake" => :build
  depends_on "llvm"  => :build
  depends_on "libjpeg"
  depends_on "libpng"
  depends_on "libtiff"
  depends_on "webp"
  
  def install
    # Use brewed clang
    # ENV['CC'] = Formula['llvm'].opt_prefix/"bin/clang"
    # ENV['CXX'] = Formula['llvm'].opt_prefix/"bin/clang++"
    ENV.cxx11
    
    cargs = std_cmake_args
    cargs.keep_if { |v| v !~ /DCMAKE_VERBOSE_MAKEFILE/ }
    
    mkdir "build" do
      system "cmake", "..", *cargs
      system "make", "install"
    end
    
  end
end
