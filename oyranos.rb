
class Oyranos < Formula
  homepage "https://oyranos.org/"
  head "https://github.com/oyranos-cms/oyranos.git", :using => :git
  
  depends_on "cmake" => :build
  depends_on "llvm"  => :build
  depends_on "doxygen" => :build
  depends_on "graphviz" => :build
  depends_on "qt" => :recommended
  depends_on "gettext"
  depends_on "libpng"
  depends_on "intltool"
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
    # ENV['CFLAGS'] = "-I#{Formula['gettext'].opt_prefix}/include"
    # ENV['CPPFLAGS'] = "-I#{Formula['gettext'].opt_prefix}/include"
    # ENV['CXXFLAGS'] = "-I#{Formula['gettext'].opt_prefix}/include"
    
    # cargs = std_cmake_args + %W[
    #   -DCMAKE_INCLUDE_PATH=#{Formula['gettext'].opt_prefix}/include:/usr/include/libxml2:/opt/X11/include:/opt/X11/include/freetype2:/System/Library/Frameworks/OpenGL.framework/Versions/Current/Headers
    #   -DCMAKE_LIBRARY_PATH=#{Formula['gettext'].opt_prefix}/lib:/opt/X11/lib:/System/Library/Frameworks/OpenGL.framework/Versions/Current/Libraries
    # ]
    
    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end
    
  end
end

