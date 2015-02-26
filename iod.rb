
class Iod < Formula
  homepage "https://github.com/matt-42/iod"
  url "https://github.com/matt-42/iod.git", :using => :git
  version "0.1.0"
  
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
    
    bin.install "tools/generate_symbol_definitions.sh"
    
    # cd "tests" do
    #   mkdir "build" do
    #     system "cmake", "..", *std_cmake_args
    #     system "make", "test"
    #   end
    # end
    
  end
end
