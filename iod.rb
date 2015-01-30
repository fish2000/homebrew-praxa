
class Iod < Formula
  homepage "https://github.com/matt-42/iod"
  head "https://github.com/matt-42/iod.git", :using => :git
  
  option "without-cxx11", "Don't enable any standard C++11 build flags"
  
  depends_on "cmake" => :build
  depends_on "boost"
  
  def install
    ENV.cxx11 if not build.without? "cxx11"
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end
end
