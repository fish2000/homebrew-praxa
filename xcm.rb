
class Xcm < Formula
  homepage "https://github.com/oyranos-cms/xcm"
  head "https://github.com/oyranos-cms/xcm.git", :using => :git
  
  depends_on "cmake" => :build
  depends_on "llvm"  => :build
  depends_on "fish2000/praxa/libxcm"
  depends_on :x11
  
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

