
class Llvmlite < Formula
  homepage "https://github.com/numba/llvmlite"
  head "https://github.com/numba/llvmlite.git",
       :using => :git

  url "https://github.com/numba/llvmlite/archive/v0.9.0.tar.gz"
  sha1 "128743a70c0511ab95bf2af95c5067a337247b86"
  version "0.9.0"
  
  devel do
    url "https://github.com/numba/llvmlite/archive/v0.10.0.dev.tar.gz"
    sha1 "23ed1458ec48319beaaa73a23eac1c06d1c321d4"
    version "0.10.0.dev"
  end
  
  depends_on "cmake" => :build
  depends_on "llvm" => :build
  depends_on :python
  
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
