#!/bin/sh
exec ruby -x "$0" "$@"
#!ruby

require 'fileutils'
include FileUtils

def newtex_conv app
  app0, app1, app2 = app.partition("rakefile = File.read('Rakefile')\n")
  rakefile = File.read('Rakefile')
  app0+"rakefile = <<'EOS'\n"+rakefile+"\nEOS\n"+app2
end

def arch_tex_conv app
  app0, app1, app2 = app.partition("rakefile = File.read('Rakefile')\nlatex_utils = File.read('lib_latex_utils.rb')\n")
  rakefile = File.read('Rakefile')
  latex_utils = File.read('lib_latex_utils.rb')
  app0+"rakefile = <<'EOS'\n"+rakefile+"\nEOS\n"+"latex_utils = <<'EOS'\n"+latex_utils+"\nEOS\n"+app2
end

@libraries = [
  'lib_latex_utils.rb'
]

@applications = [
  ['newtex.rb', 'newtex', method(:newtex_conv)],
  ['arch_tex.rb', 'arch_tex', method(:arch_tex_conv)],
  ['part_typeset.rb', 'part_typeset'],
  ['renumber.rb', 'renumber']
]

def usage
  print "Usage:\n"
  print "ruby install.rb [+|-|?|-h|--help]\n"
  print "option:\n"
  print "  +: install (default)\n"
  print "  -: uninstall\n"
  print "  ?, -h, --help: show this message\n"
end

def install
  # install libraries
  path = $LOAD_PATH[0] # target directory
  @libraries.each do |lib_program|
    cp lib_program, "#{path}/#{lib_program}"
  end

  # install applications
  @applications.each do |src, dst, conv|
    dst = "/usr/local/bin/#{dst}"
    app = File.read(src)
    app = conv.call(app) if conv.instance_of? Method
    File.write(dst, app)
    chmod(0755, dst)
  end
end

def uninstall
  rm_f (@libraries.map{|library| "#{$LOAD_PATH[0]}/#{library}"})
  rm_f (@applications.map{|application| "/usr/local/bin/#{application[1]}"})
end

case ARGV[0]
when '+', nil then install
when '-' then uninstall
when '?', '-h', '--help' then usage
end
