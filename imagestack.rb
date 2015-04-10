
class Imagestack < Formula
  homepage "https://github.com/fish2000/ImageStack"
  version "0.1.0"
  url "https://github.com/fish2000/ImageStack.git", :using => :git
  
  depends_on "cmake" => :build
  depends_on "llvm"  => :build
  depends_on "pkg-config" => :build
  
  depends_on "fish2000/praxa/halide" => :build # for build_halide_h
  
  depends_on "fftw" => :recommended
  depends_on "openexr" => :recommended
  depends_on "sdl" => :recommended
  depends_on "jpeg" => :recommended
  depends_on "libtiff" => :recommended
  depends_on "libpng" => :recommended
  
  # Helper method to invoke `build_halide_h`,
  #   from a brewed Halide install
  def build_halide_h
    return Pathname(Formula['halide'].opt_prefix/"bin/build_halide_h")
  end
  
  # Run the `build_halide_h` tool from the Halide distribution,
  #   with a list of header files to concatenate
  def combine_headers *ff
    return Utils.popen_read build_halide_h, *ff
  end
  
  def install
    # Use brewed clang
    ENV['CC'] = Formula['llvm'].opt_prefix/"bin/clang"
    ENV['CXX'] = Formula['llvm'].opt_prefix/"bin/clang++"
    
    # This list comes from the currently shipping ImageStack.h file
    headfiles = %W(main.h Operation.h Calculus.h
      Color.h Control.h Convolve.h Complex.h
      Deconvolution.h DFT.h Display.h DisplayWindow.h
      Exception.h File.h Filter.h Geometry.h
      GaussTransform.h HDR.h Image.h KernelEstimation.h
      LAHBPCG.h LightField.h Arithmetic.h Network.h
      NetworkOps.h Paint.h Parser.h Prediction.h
      Stack.h Statistics.h Wavelet.h WLS.h
      macros.h tables.h)
    
    # Copy the apropriate Makefile to the buildpath and run make
    system "cp", "makefiles/Makefile.homebrew", buildpath/"Makefile"
    system "make"
    
    # Combine the headers into the master header template
    template = (buildpath/"src/ImageStack.h.tpl").binread
    cd "lib/build" do
      template.gsub! "$INCLUDES", combine_headers(*headfiles)
    end
    
    # Destroy build artifacts before installing
    cd "bin" do
      rm_rf "build"
    end
    cd "lib" do
      rm_rf "build"
    end
    
    # install the build products and write out the master header
    bin.install buildpath/"bin/ImageStack"
    lib.install buildpath/"lib/libImageStack.dylib"
    include.mkdir
    (include/"ImageStack.h").atomic_write(template)
    
  end
end

