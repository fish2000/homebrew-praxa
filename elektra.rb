
class Elektra < Formula
  homepage "https://github.com/ElektraInitiative/libelektra"
  head "https://github.com/ElektraInitiative/libelektra.git", :using => :git
  
  depends_on "cmake" => :build
  depends_on "llvm"  => :build
  depends_on "swig" => :build
  
  def install
    # Use brewed clang
    ENV['CC'] = Formula['llvm'].opt_prefix/"bin/clang"
    ENV['CXX'] = Formula['llvm'].opt_prefix/"bin/clang++"
    
    cargs = std_cmake_args + %W[
      -DCMAKE_BUILD_TYPE=Release
      -DBUILD_FULL=ON
      -DBUILD_DOCUMENTATION=OFF
    ]
    
    inreplace "scripts/CMakeLists.txt",
      "/etc/bash_completion.d", bash_completion
    inreplace "scripts/CMakeLists.txt",
      "/etc/profile.d", prefix/"etc/profile.d"
    (prefix/"etc").mkdir
    (prefix/"etc/profile.d").mkdir
    
    mkdir "build" do
      system "cmake", "..", *cargs
      system "make", "install"
    end
    
  end
end

