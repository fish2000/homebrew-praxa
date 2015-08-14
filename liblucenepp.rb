
class Liblucenepp < Formula
  homepage "https://github.com/luceneplusplus/LucenePlusPlus"
  
  # Head works OK
  head "https://github.com/luceneplusplus/LucenePlusPlus.git", :using => :git
  
  # This release won't build
  # url "https://github.com/luceneplusplus/LucenePlusPlus/archive/rel_3.0.7.zip"
  # sha256 "8618905c9dea8b66374a3e9cd63acd9b302b3affce104b6a17cb3b98e53c6448"
  # version "3.0.7"
  
  url "https://github.com/luceneplusplus/LucenePlusPlus/archive/rel_3.0.6.zip"
  sha256 "0bfc9f2fc130d920f153ce801f59f686fe9d14680e537c1cdf10fb1dee157882"
  version "3.0.6"
  
  depends_on "llvm"  => [:build, :optional]
  depends_on "cmake" =>  :build
  depends_on "boost"
  
  def install
    # Use brewed clang
    if build.with? "llvm"
      ENV['CC'] = Formula['llvm'].opt_prefix/"bin/clang"
      ENV['CXX'] = Formula['llvm'].opt_prefix/"bin/clang++"
    end
    
    # use c++11
    ENV['CXX11'] = "1"
    ENV.cxx11
    
    cargs = std_cmake_args
    cargs.keep_if { |v| v !~ /DCMAKE_VERBOSE_MAKEFILE/ }
    
    mkdir "build" do
      system "cmake", "..", *cargs
      system "make", "install"
    end
    
  end
end

