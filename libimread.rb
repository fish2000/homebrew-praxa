
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
    ENV['CC'] = Formula['llvm'].opt_prefix/"bin/clang"
    ENV['CXX'] = Formula['llvm'].opt_prefix/"bin/clang++"
    
    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end
    
  end
end
