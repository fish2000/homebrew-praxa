
class Libxcm < Formula
  homepage "https://github.com/oyranos-cms/libxcm"
  head "https://github.com/oyranos-cms/libxcm.git", :using => :git
  
  depends_on :x11
  
  def install
    system "./configure", "--prefix=#{prefix}", "--with-x11"
    system "make"
    system "make install"
  end
end

