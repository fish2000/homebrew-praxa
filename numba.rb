
class Numba < Formula
  homepage "https://github.com/numba/numba"
  url "https://github.com/numba/numba.git", :using => :git
  version "0.1.0"

  depends_on :python
  depends_on "numpy" => :python
  depends_on "argparse" => :python
  depends_on "funcsigs" => :python
  depends_on "fish2000/praxa/llvmlite"
  
  def install
    ENV.prepend_path "PYTHONPATH", Formula['llvmlite'].opt_prefix/"lib/python2.7/site-packages"
    ENV.prepend_create_path "PYTHONPATH", lib/"python2.7/site-packages"
    system "python", "setup.py", "build_ext", "--inplace"
    system "python", "setup.py", "install", "--prefix=#{prefix}"
  end
  
  test do
    system "pycc", "--help"
  end
end
