
class Dige < Formula
  homepage "https://github.com/matt-42/dige"
  head "https://github.com/matt-42/dige.git", :using => :git
  
  option "with-examples", "Build examples"
  #option "with-tests", "Build and run tests"
  
  depends_on "cmake" => :build
  depends_on "olena" => :optional
  depends_on "boost"
  depends_on "ffmpeg"
  depends_on "qt"
  
  def install
    # (temporary) inline patch fixing OpenGL header paths on Mac
    inreplace "dige/abstract_texture.h", "<GL/gl.h>", "<OpenGL/gl.h>"
    inreplace "dige/internal_texture.h", "<GL/gl.h>", "<OpenGL/gl.h>"
    inreplace "dige/texture.h", "<GL/gl.h>", "<OpenGL/gl.h>"
    inreplace "dige/is_texture_type.h", "<GL/glu.h>", "<OpenGL/glu.h>"
    inreplace "dige/error.h", "<GL/glu.h>", "<OpenGL/glu.h>"
    
    # build the dige
    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make"
      system "make", "install"
    end
    
    # examples: cmakify all the things, recursively
    # N.B. Only 'hello world seems to work; I do not
    # currently recommend this
    if build.with? "examples"
      # customize cmake args
      ex_cmake_args = [
        "-DCMAKE_INSTALL_PREFIX=#{share}/examples",
        "-DCMAKE_BUILD_TYPE=None",
        "-DCMAKE_FIND_FRAMEWORK=LAST",
        "-DCMAKE_VERBOSE_MAKEFILE=#{ARGV.verbose? and "ON" or "OFF"}",
        "-Wno-dev"]
      
      # patch example source
      # inreplace "examples/random/main.cc" do |s|
      #   s.gsub! "<dige/event/wait.h>", "<dige/event/all.h>"
      #   s.gsub! "dg::key_release", "dg::event::key_release"
      #   s.gsub! "dg::display", "dg::event::display"
      #   s.gsub! "dg::click", "dg::event::click"
      # end
      
      cd "examples" do
        exdir = Dir.pwd
        Dir.foreach(exdir) do |example|
          next if example == '.' \
               or example == '..' \
               or example == 'rgb_image.h' \
               or example == 'random' \
               or example == 'record_random' \
               or example == 'events'
          cd example do
            mkdir "build" do
              system "cmake", exdir+"/"+example, *ex_cmake_args
              system "make"
              (share/"examples").install example
            end
          end
        end
      end
    end
    
  end
end
