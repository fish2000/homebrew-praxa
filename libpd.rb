
class Libpd < Formula
  homepage "http://libpd.cc/"
  url "https://github.com/libpd/libpd.git", :using => :git
  version "0.1.0"
  
  depends_on "python" => :recommended
  depends_on "swig"  => :recommended
  
  def install
    # Fix hardcoded gcc/g++ refs in the Makefile
    inreplace "Makefile", "gcc -o", "$(CC) -o"
    inreplace "Makefile", "g++ -o", "$(CXX) -o"
    
    # Build the library
    system "make", "UTIL=true", "EXTRA=true"
    #system "make", "cpplib", "UTIL=true", "EXTRA=true"
    
    # Build and install the python module
    if build.with? "python" and build.with? "swig"
      cd "python" do
        ENV.prepend_create_path "PYTHONPATH", lib/"python2.7/site-packages"
        system "python", "setup.py", "build_ext", "--swig", Formula['swig'].opt_prefix/"bin/swig"
        system "python", "setup.py", "install", "--prefix=#{prefix}"
      end
    end
    
    # Install the library and ancilliaries
    prefix.install %w(LICENSE.txt README.md)
    lib.mkpath
    lib.install "libs/libpd.dylib"
    lib.install "dist/libpd.jar"
    include.mkpath
    include.install Dir["libpd_wrapper/*.h"]
    include.install "pure-data/src/m_pd.h"
    (include/"util").mkpath
    (include/"util").install Dir["libpd_wrapper/util/*.h"]
    (share/"objc").mkpath
    (share/"objc").install Dir["objc/*"]
    
  end

end
