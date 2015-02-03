
class Vpp < Formula
  homepage "https://github.com/matt-42/vpp"
  url "https://github.com/matt-42/vpp/archive/0.2.tar.gz"
  sha1 "b9f0a8a2bb25ecc16ca1b13b40cb6d62813350d6"
  head "https://github.com/matt-42/vpp.git", :using => :git
  
  option :cxx11
  depends_on "cmake" => :build
  depends_on "gcc" => :build
  #depends_on "llvm" => [:build, "clang"]
  depends_on "eigen"
  depends_on "fish2000/praxa/opencv"
  depends_on "fish2000/praxa/iod"
  depends_on "fish2000/praxa/dige"

  def install
    ENV.cxx11 if build.cxx11?
    inreplace "CMakeLists.txt", "/usr/include/eigen3", "#{Formula['eigen'].opt_prefix}/include/eigen3"
    
    mkdir "build" do
      gccpth = Formula['gcc'].opt_prefix
      ENV['CC'] = gccpth+"bin/gcc-4.9"
      ENV['CXX'] = gccpth+"bin/g++-4.9"
      system "cmake", "..", *std_cmake_args
      system "make"
      system "make", "install"
    end
  end
end
