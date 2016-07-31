
# Original formula by @glazzara
# Adapted from https://github.com/Homebrew/homebrew/pull/16092/files

class Olena < Formula
  homepage 'http://olena.lrde.epita.fr'
  
  #url 'http://www.lrde.epita.fr/dload/olena/2.0/olena-2.0a.tar.gz'
  #version "2.0"
  #sha1 'a9445bac1f30c9d999ad5ce70588745e153700dd'
  
  url 'https://www.lrde.epita.fr/dload/olena/2.1/olena-2.1.tar.bz2'
  version "2.1.0"
  # sha1 '54f756b033a45d4c2fe1233c10fc43f99f9f552f'
  
  option "without-scribo", "Omit building the Scribo header library"
  option "without-cxx11", "Don't enable any standard C++11 build flags"
  option "with-head-docs", "Attempt to make all the docs when building from HEAD"

  head do
    url 'https://github.com/glazzara/olena.git'
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
    depends_on "doxygen" => [:build, :optional] if build.with? "head-docs"
    depends_on "hevea" => [:build, :optional] if build.with? "head-docs"
    depends_on :tex => [:build, :optional] if build.with? "head-docs"
  end

  depends_on 'swig' => :recommended
  depends_on :python if not build.without? "swig"
  
  depends_on 'fftw' => :optional
  depends_on 'poppler' => :optional
  depends_on 'libtiff' => :recommended
  depends_on 'tesseract' => :recommended
  depends_on 'graphicsmagick'
  depends_on 'libxslt'
  depends_on 'fop'
  depends_on 'qt'

  def install
    ENV.cxx11 if not build.without? "cxx11"
    ENV['CPPFLAGS'] = "-I#{Formula['graphicsmagick'].opt_prefix}/include/GraphicsMagick"
    ENV['CPPFLAGS'] += " -DHAVE_SYS_TYPES_H=1"
    ENV['CXXFLAGS'] = "-fno-strict-aliasing"
    
    # Baseline arguments to .configure
    cargs = [
      "QT_PATH=#{Formula['qt'].opt_prefix}",
      
      "MOC=#{Formula['qt'].opt_prefix}/bin/moc", 
      "UIC=#{Formula['qt'].opt_prefix}/bin/uic",
      "RCC=#{Formula['qt'].opt_prefix}/bin/rcc",
      "QMAKE=#{Formula['qt'].opt_prefix}/bin/qmake",
      
      "--with-graphicsmagickxx=#{Formula['graphicsmagick'].opt_prefix}",
      "--with-imagemagickxx=no"]
    
    # Third-party imaging libraries
    if not build.without? "libtiff"
      cargs << "--with-tiff=#{Formula['libtiff'].opt_prefix}"
    end
    if not build.without? "tesseract"
      cargs << "--with-tesseract=#{Formula['tesseract'].opt_prefix}"
    end
    
    # Swig-generated Python bindings
    if not build.without? "swig"
      cargs << "--enable-swilena"
      cargs << "PYTHON=#{`which python`}"
    end
    
    # QT-backed Scribo UI
    cargs << "--enable-scribo" if not build.without? "scribo"
    
    # Heads are wise to strap first, always
    if build.head?
      if build.with? "head-docs"
        system "./bootstrap"
      else
        system "./bootstrap", "--regen"
      end
    end
    
    # configure/make/install
    system "./configure", "--prefix=#{prefix}", *cargs
    system "make"
    system "make install"
    
    # clean up logorrhea-inducing artifacts
    rm_rf share/"doc/olena/milena/user-refman"
    
  end
  
end