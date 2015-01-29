
# Original formula by @glazzara
# Adapted from https://github.com/Homebrew/homebrew/pull/16092/files

class Olena < Formula
  homepage 'http://olena.lrde.epita.fr'
  url 'http://www.lrde.epita.fr/dload/olena/2.0/olena-2.0a.tar.gz'
  version "2.0"
  sha1 'a9445bac1f30c9d999ad5ce70588745e153700dd'

  depends_on 'qt'
  depends_on 'fop'
  depends_on 'libxslt'
  depends_on 'tesseract'
  depends_on 'graphicsmagick'

  def install
    system "./configure", "--prefix=#{prefix}",
           "--enable-scribo", 
           "QT_PATH=/usr/local", "QMAKE=/usr/local/bin/qmake",
                                 "MOC=/usr/local/bin/moc", 
                                 "UIC=/usr/local/bin/uic",
                                 "RCC=/usr/local/bin/rcc",
           "--with-tiff=/usr/local",
           "--with-tesseract=/usr/local",
           "--with-graphicsmagickxx=/usr/local", "--with-imagemagickxx=no",
           "CPPFLAGS=-I/usr/local/include/GraphicsMagick -DHAVE_SYS_TYPES_H=1",
           "CXXFLAGS=-fno-strict-aliasing"
    
    system "make" 
    system "make install"
  end
end