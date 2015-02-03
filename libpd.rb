
class Libpd < Formula
  homepage "http://libpd.cc/"
  head "https://github.com/libpd/libpd.git"
  
  def install
    # ENV['CC'] = Formula['llvm'].opt_prefix/"bin/clang"
    # ENV['CXX'] = Formula['llvm'].opt_prefix/"bin/clang++"
    ENV['CC'] = "/usr/bin/clang"
    ENV['CXX'] = "/usr/bin/clang++"
    
    # system "git", "submodule", "init"
    # system "git", "submodule", "update"
    system "make", "UTIL=true", "EXTRA=true",
                   "CFLAGS=-Wno-parentheses -Wno-implicit-function-declaration"
    
    lib.mkpath
    lib.install "libs/libpd.dylib"
    lib.install "dist/libpd.jar"
    
    prefix.install %w(LICENSE.txt README.md)
    (prefix/"objc").mkpath
    (prefix/"objc").install Dir["objc/*"]
    
    cd "python" do
      ENV.prepend_create_path "PYTHONPATH", lib/"python2.7/site-packages"
      system "python", "setup.py", "install", "--prefix=#{prefix}"
    end
    
    # cd "pure-data" do
    #   system "autogen.sh"
    #   system "./configure", "--prefix=#{prefix}", "--disable-dependency-tracking", "--enable-fftw"
    # end
    
  end

end
