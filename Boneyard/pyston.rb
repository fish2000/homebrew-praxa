
class Pyston < Formula
  desc "Python runtime C++ implementation"
  homepage "https://github.com/dropbox/pyston"
  url "https://github.com/dropbox/pyston.git", :using => :git
  version "0.4.9"
  
  option "with-docs", "Build documentation (seems error-prone)"
  
  depends_on "pkgconfig" => :build
  depends_on "automake"  => :build
  depends_on "readline"  => :build
  depends_on "cmake"     => :build
  depends_on "ccache"    => :build
  depends_on "ninja"     => :build
  depends_on "llvm"      => :build
  depends_on "git"       => :build
  depends_on "python@2"
  depends_on "mpfr"
  depends_on "sqlite"
  
  def install
    system "make"
    # TODO: wait until pyston gets slightly less pre-alpha,
    # to at least the point where devs eschew hardcoded
    # dependency paths -- then you can finish this bit
  end
end

