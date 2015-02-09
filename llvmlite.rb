
class Llvmlite < Formula
  homepage "https://github.com/numba/llvmlite"
  head "https://github.com/numba/llvmlite.git"

  depends_on "cmake" => :build
  depends_on "llvm" => :build
  depends_on :python
  #depends_on "enum34" => :python
  
  def install
    # Use brewed clang
    ENV['LLVM_CONFIG'] = Formula['llvm'].opt_prefix/"bin/llvm-config"
    ENV['CC'] = Formula['llvm'].opt_prefix/"bin/clang"
    ENV['CXX'] = Formula['llvm'].opt_prefix/"bin/clang++"
    ENV.cxx11
    ENV.prepend_create_path "PYTHONPATH", lib/"python2.7/site-packages"
    
    # Can't "depend_on" enum34 as it is not imported as enum34, so:
    system "pip", "install", "-U", "enum34"
    
    system "python", "setup.py", "build"
    system "python", "setup.py", "install", "--prefix=#{prefix}"
  end
  
  test do
    system "python", "-m", "llvmlite.tests"
  end
end
