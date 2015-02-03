
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
    # ENV.cxx11 if build.cxx11?
    
    # args = %W[
    #   -DCMAKE_INSTALL_PREFIX=#{prefix}
    #   -DCMAKE_BUILD_TYPE=None
    #   -DCMAKE_VERBOSE_MAKEFILE=OFF
    #   -DCMAKE_FIND_FRAMEWORK=LAST
    #   -Wno-dev
    #   -DCMAKE_OSX_DEPLOYMENT_TARGET=
    # ]
    
    eigenpth = Formula['eigen'].opt_include
    inreplace "CMakeLists.txt", "/usr/include/eigen3", "#{eigenpth}/eigen3"
    inreplace "tests/CMakeLists.txt", "/usr/include/eigen3", "#{eigenpth}/eigen3"
    inreplace "examples/CMakeLists.txt", "/usr/include/eigen3", "#{eigenpth}/eigen3"
    #inreplace "examples/CMakeLists.txt", "pyrlk", "pyrlk_match"
    #mv "examples/pyrlk.cc", "examples/pyrlk_match.cc"
    
    gccpth = Formula['gcc'].opt_bin
    iodpth = Formula['iod'].opt_include
    cvpth = Formula['opencv'].opt_prefix
    ENV['CC'] = gccpth+"/gcc-4.9"
    ENV['CXX'] = gccpth+"/g++-4.9"
    ENV.append_to_cflags "-I#{iodpth}"
    ENV.append_to_cflags "-I#{cvpth}/include"
    ENV.prepend "LDFLAGS", "-L#{cvpth}/lib"
    
    #system "sh", "./install_thirdparty.sh"
    
    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make"
      system "make", "install"
    end
  end
end
