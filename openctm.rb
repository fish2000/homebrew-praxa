
class Openctm < Formula
  homepage "http://openctm.sourceforge.net/"
  url "http://download.sourceforge.net/project/openctm/OpenCTM-1.0.3/OpenCTM-1.0.3-src.zip"
  sha256 "1310346651d96dc310022fde23a7d1a7810f32bccdfda4be0ea1b7a3cfd2b583"
  
  depends_on "cmake" => :build
  depends_on "llvm"  => :build
  depends_on "tinyxml" => :optional
  depends_on "jpeg"
  depends_on "zlib"
  
  def install
    # Use brewed clang
    ENV['CC'] = Formula['llvm'].opt_prefix/"bin/clang"
    ENV['CXX'] = Formula['llvm'].opt_prefix/"bin/clang++"
    ENV.cxx11
    
    makeargs = %W[
      CC=#{ENV['CC']}
      CXX=#{ENV['CXX']}
      CPP=#{ENV['CXX']}
      LIBDIR=#{lib}
      BINDIR=#{bin}
      INCDIR=#{include}
      MAN1DIR=#{man1}
    ]
    
    c99 = "-std=c99 -pedantic"
    cc11 = "-std=c++11 -stdlib=libc++"
    common = "-O3 -W -Wall -Wno-self-assign -Wno-unused-parameter -Wno-deprecated-declarations -c"
    hidden = "-fvisibility=hidden"
    
    cd "lib" do
      system "make", "-j4", "-f", "Makefile.macosx", "all",
             "CFLAGS="+c99+" "+common+" "+hidden+" -DOPENCTM_BUILD -Iliblzma -DLZMA_PREFIX_CTM",
             "CFLAGS_LZMA="+c99+" "+common+" "+hidden+" -DLZMA_PREFIX_CTM",
             *makeargs
    end
    
    cd "tools" do
      # speed things up by copying over libz.a, libjpeg.a, and libtinyxml.dylib:
      system "cp", Formula['zlib'].opt_prefix/"lib/libz.a",
                   "#{Dir.pwd}/zlib/libz.a"
      system "cp", Formula['jpeg'].opt_prefix/"lib/libjpeg.a",
                   "#{Dir.pwd}/jpeg/libjpeg.a"
      
      if build.with? "tinyxml"
        system "cp", Formula['tinyxml'].opt_prefix/"lib/libtinyxml.dylib",
                      "#{Dir.pwd}/tinyxml/libtinyxml.dylib"
        inreplace "Makefile.macosx", "libtinyxml.a",
                                     "libtinyxml.dylib"
      else
        inreplace "Makefile.macosx", "-ltinyxml",
                                     "tinyxml/libtinyxml.a"
        inreplace "Makefile.macosx", "-lopenctm",
                                      "../lib/libopenctm.dylib"
      end
      
      # MAKE IT REAL GOOD
      system "make", "-j4", "-f", "Makefile.macosx", "all",
             "OCPP=#{ENV['CXX']} -x objective-c++",
             "CPPFLAGS="+cc11+" "+common+" -I../lib -Irply -Ijpeg -Itinyxml -Iglew -Izlib -Ipnglite",
             "OCPPFLAGS="+cc11+" "+common,
             *makeargs
    end
    
    # THE HARD WAY:
    lib.mkpath
    include.mkpath
    man1.mkpath
    lib.install buildpath/"lib/libopenctm.dylib"
    include.install buildpath/"lib/openctm.h"
    include.install buildpath/"lib/openctmpp.h"
    bin.install buildpath/"tools/ctmconv"
    bin.install buildpath/"tools/ctmviewer"
    man1.install buildpath/"doc/ctmconv.1"
    man1.install buildpath/"doc/ctmviewer.1"
    
  end
end

