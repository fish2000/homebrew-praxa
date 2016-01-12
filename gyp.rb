
class Gyp < Formula
  homepage 'https://github.com/bnoordhuis/gyp'
  head 'https://github.com/bnoordhuis/gyp.git'
  url 'https://github.com/bnoordhuis/gyp/archive/e2313c02ad7b6d589b38fe578f5d39970a9bbc20.zip'
  sha256 'eb6d8bc14a024181470ceaf9dc0d608de3e9aeecf6bfc6fdfed39b96bd06da9e'
  version '0.1.0'

  depends_on 'scons'

  def install
    # This is very similar to the Duplicity formula:
    # Install mostly into libexec
    bin.mkdir
    libexec.mkdir
    system "python", "setup.py", "build"
    system "python", "setup.py", "install",
                     "--single-version-externally-managed",
                     "--root=/",
                     "--prefix=#{prefix}",
                     "--install-scripts=#{bin}",
                     "--install-lib=#{libexec}"

    # Shift files around to avoid needing a PYTHONPATH
    mv bin+'gyp', bin+'gyp.py'
    mv Dir[bin+'*'], libexec
    bin.install_symlink "#{libexec}/gyp.py" => "gyp"
  end
end