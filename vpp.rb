
class Vpp < Formula
  homepage "https://github.com/matt-42/vpp"
  head "https://github.com/matt-42/vpp.git", :using => :git
  
  option :cxx11
  
  depends_on "cmake" => :build
  depends_on "eigen"
  depends_on "homebrew/science/opencv"
  depends_on "fish2000/praxa/iod"
  depends_on "fish2000/praxa/dige"

  def install
    ENV.cxx11 if build.cxx11?
    
    inreplace "CMakeLists.txt", "c++14", "c++1y"
    inreplace "CMakeLists.txt", "/usr/include/eigen3", "#{Formula['eigen'].opt_prefix}/include/eigen3"
    #inreplace "examples/CMakeLists.txt", "c++14", "c++1y"
    #inreplace "benchmarks/CMakeLists.txt", "c++14", "c++1y"
    
    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make"
      system "make", "install"
    end
  end
end
