
class Iod < Formula
  homepage "https://github.com/matt-42/iod"
  head "https://github.com/matt-42/iod.git", :using => :git
  
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
    
    # cd "tests" do
    #   mkdir "build" do
    #     system "cmake", "..", *std_cmake_args
    #     system "make", "test"
    #   end
    # end
    
  end
end
