
class Oyranos < Formula
  homepage "https://oyranos.org/"
  head "https://github.com/oyranos-cms/oyranos.git", :using => :git
  
  depends_on "cmake" => :build
  depends_on "llvm"  => :build
  depends_on "gettext" => :build
  depends_on "qt" => :recommended
  depends_on "libpng"
  depends_on "fltk"
  depends_on "exiv2"
  depends_on "cairo"
  depends_on "libraw"
  depends_on "little-cms2"
  depends_on "fish2000/praxa/libxcm"
  depends_on "fish2000/praxa/elektra"
  depends_on :x11
  
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

