
class Iod < Formula
  homepage "https://github.com/matt-42/iod"
  head "https://github.com/matt-42/iod.git", :using => :git
  
  option :cxx11
  
  depends_on "cmake" => :build
  depends_on "boost"
  
  def install
    ENV.cxx11 if build.cxx11?
    
    #inreplace "CMakeLists.txt", "c++14", "c++1y"
    inreplace "tools/CMakeLists.txt", "c++14", "c++1y"
    inreplace "iodUse.cmake", "c++14", "c++1y"
    
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end
end
