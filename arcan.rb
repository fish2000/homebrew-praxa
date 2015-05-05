
class Arcan < Formula
  homepage "https://github.com/letoram/arcan"
  head "https://github.com/letoram/arcan.git", :using => :git
  
  depends_on "cmake" => :build
  depends_on "llvm"  => :build
  depends_on "openctm"
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
    
    cd "src" do
      mkdir "build" do
        system "cmake", "..", *cargs
        system "make", "install"
      end
    end
    
  end
end

