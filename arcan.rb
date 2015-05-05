
class Arcan < Formula
  homepage "https://github.com/letoram/arcan"
  head "https://github.com/letoram/arcan.git", :using => :git
  
  depends_on "cmake" => :build
  depends_on "llvm"  => :build
  depends_on "fish200/praxa/openctm"
  depends_on "freetype"
  depends_on "luajit"
  depends_on "sqlite"
  depends_on "sdl"
  
  def install
    # Use brewed clang
    ENV['CC'] = Formula['llvm'].opt_prefix/"bin/clang"
    ENV['CXX'] = Formula['llvm'].opt_prefix/"bin/clang++"
    
    cargs = *std_cmake_args + %W[
      -DVIDEO_PLATFORM=sdl
      -DENABLE_LWA=OFF
      -DDISABLE_FRAMESERVERS=OFF
    ]
    
    cd "arcan" do
      mkdir "build" do
        system "cmake", "../src", *std_cmake_args
        system "make", "install"
      end
    end
    
  end
end

