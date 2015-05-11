
class LemonGraphLibrary < Formula
  ENV['LEMON_VERSION'] = "1.3.1"
  
  homepage "https://lemon.cs.elte.hu/"
  head "http://lemon.cs.elte.hu/hg/lemon-main/", :using => :hg
  url "http://lemon.cs.elte.hu/pub/sources/lemon-#{ENV['LEMON_VERSION']}.zip"
  sha256 "2222c2b2e58f556d6d53117dfbd9c5b4fc1fceb41a6eaca3c9a3e58b66f9e46f"
  version ENV['LEMON_VERSION']
  
  resource "cylemon" do
    url "https://github.com/ilastik/cylemon/archive/21f892908c689c7ec4526b76f833be77e5a307aa.zip"
    #sha256 "1d435a079cb5bc16b3e0ef9391b2da9a15c18305b41b595b3595e81f80d12dad"
    sha256 "4b11ce7cf0f3ee7e60076622b8673339a5f344fde1a8e608bfe00caf831de26e"
  end
  
  resource "pylemon" do
    url "http://lime.cs.elte.hu/~alpar/hg/hgwebdir.cgi/pylemon/archive/f5d1dff1b491.zip"
    sha256 "e528671fb412c92472d7ac502dad7aeea05478152d41142916a823df2466c3e6"
  end
  
  option "with-python",       "Build Cythonized Python bindings"
  option "with-pure-python",  "Build Pure Python bindings"
  option "with-tests",        "Run self-tests with 'make check'"
  option "with-docs",         "Build documentation"
  option "without-cxx11",     "Don't build using C++11 mode"
  
  doing_python = (build.with? "python" or build.with? "pure-python")
  
  depends_on "cmake"  =>  :build
  depends_on "llvm"   =>  :build
  depends_on "wget"   =>  :build # ?!
  depends_on "coin"   =>  :optional
  depends_on "glpk"
  # depends_on "gs"     =>  :recommended
  
  depends_on :python              if doing_python
  depends_on "numpy"  =>  :python if doing_python
  depends_on "cython" =>  :python if build.with? "python"
  
  def install
    # Use brewed clang
    ENV['CC'] = Formula['llvm'].opt_prefix/"bin/clang"
    ENV['CXX'] = Formula['llvm'].opt_prefix/"bin/clang++"
    ENV.cxx11 unless build.without? "cxx11"
    ENV.append_to_cflags  "-Wno-unused-function"
    ENV.append_to_cflags  "-Wno-unused-variable"
    ENV.append_to_cflags  "-stdlib=libc++"
    ENV.append 'LDFLAGS', "-stdlib=libc++"
    ENV.append 'LDFLAGS', "-lc++"
    
    doing_python = (build.with? "python" or build.with? "pure-python")
    
    cargs = *std_cmake_args + %W[
      -DCMAKE_BUILD_TYPE=RelWithDebInfo
      -DCMAKE_CXX_COMPILER=#{ENV['CXX']}
      -DLEMON_DOC_SOURCE_BROWSER=NO
      -DLEMON_DOC_USE_MATHJAX=NO
      -DBUILD_SHARED_LIBS=TRUE
      -DLEMON_ENABLE_ILOG=FALSE
      -DLEMON_ENABLE_GLPK=TRUE
      -DGLPK_ROOT_DIR=#{Formula['glpk'].opt_prefix}
      -DLEMON_DEFAULT_LP=GLPK
      -DLEMON_DEFAULT_MIP=GLPK
      -DLEMON_ENABLE_COIN=#{build.with? "coin" and "TRUE" or "FALSE"}
    ]
    
    if not build.without? "coin"
      cargs << "-DCOIN_ROOT_DIR=#{Formula['coin'].opt_prefix}"
    end
    
    mkdir "build" do
      system "cmake", "..", *cargs
      system "make"
      system "make", "check"    if build.with? "tests"
      system "make", "html"     if build.with? "docs"
      system "make", "install"
    end
    
    if doing_python
      ENV.prepend_create_path "PYTHONPATH", lib/"python2.7/site-packages"
    end
    
    if build.with? "python"
      mkdir "cylemon" do
        resource("cylemon").stage {
          ["setup.py",
           "cylemon/segmentation.pyxbld",
           "cylemon/lemon_example.pyxbld"
          ].each do |bad_file|
            inreplace bad_file, "stdc++", "c++"
          end
          
          system "python", "setup.py", "build_ext",
                                       "--cython-cplus",
                                       "--no-openmp",
                                       "-I#{include}",
                                       "-L#{lib}" 
          
          system "python", "setup.py", "install",
                                       "--prefix=#{prefix}"
        }
      end
    elsif build.with? "pure-python"
      mkdir "pylemon" do
        resource("pylemon").stage {
          system "python", "setup.py", "build_ext"
          system "python", "setup.py", "install",
                                       "--prefix=#{prefix}"
        }
      end
    end
    
  end
end

