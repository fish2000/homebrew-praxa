
class Vpp < Formula
  homepage "https://github.com/matt-42/vpp"
  #url "https://github.com/matt-42/vpp/archive/0.2.tar.gz"
  url "https://github.com/matt-42/vpp/archive/e03f0dd4d33953c0017b946995960e491a928426.zip"
  head "https://github.com/matt-42/vpp.git",
       :using => :git
  version "0.3.1"
  
  option "with-benchmarks", "Build and run benchmarks"
  option "with-examples",   "Build and install examples"
  
  depends_on "cmake" => :build
  depends_on "llvm"  => :build
  depends_on "eigen" => :build
  depends_on "homebrew/science/opencv"
  depends_on "fish2000/praxa/iod"
  depends_on "fish2000/praxa/dige"
  
  def install
    # Use brewed Clang
    # ENV['CC'] = Formula['llvm'].opt_prefix/"bin/clang"
    # ENV['CXX'] = Formula['llvm'].opt_prefix/"bin/clang++"
    ENV.append_to_cflags  "-I#{Formula['eigen'].opt_prefix/"include/eigen3"}"
    
    cargs = std_cmake_args
    cargs.keep_if { |v| v !~ /DCMAKE_VERBOSE_MAKEFILE/ }
    
    mkdir "build" do
      system "cmake", "..", *cargs
      system "make"
      system "make", "install"
    end
    
    if build.with? "benchmarks"
      cd "benchmarks" do
        mkdir "build" do
          system "cmake", "..", *cargs
          system "make"
        end
      end
    end
    
    if build.with? "examples"
      cd "examples" do
        mkdir "build" do
          system "cmake", "..", *cargs
          system "make"
          system "make", "install"
        end
      end
    end
    
  end
end
