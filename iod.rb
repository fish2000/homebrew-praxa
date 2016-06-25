
class Iod < Formula
  homepage "https://github.com/matt-42/iod"
  #url "https://github.com/matt-42/iod/archive/master.zip"
  url "https://github.com/matt-42/iod/archive/fd241227b33aa1f0c9ae80a384aa2bb7f7e17609.zip"
  head "https://github.com/matt-42/iod.git",
    :using => :git
  version "0.6.6"
  
  depends_on "cmake" => :build
  depends_on "llvm"  => :build
  depends_on "boost"
  
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
