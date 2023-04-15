require 'fileutils'

include FileUtils

class String
  # Remove verbatim environments and comments (including the following new line) from self (LaTeX source).
  def remove_tex_comment
    gsub(/\\begin\{verbatim\}.*\\end\{verbatim\}/m, '').gsub(/%.*\n/,'')
  end
  # Return a string with the new suffix.
  # If the suffix is illegal, nil is returned.
  # Be careful that the suffix begins with a period.
  #
  # It redefines itself if it has been defined. For example, rake defines ext method.
  def ext(suffix)
    return nil unless suffix.is_a?(String) && /^\.\w+$/ =~ suffix
    s = File.extname(self)
    self.sub(/#{s}$/, suffix)
  end
end

module Lbt
=begin rdoc
When you create an instance of the PCS class, it keeps the structure of Part-Chapter-Section files.
For example,
  +-part1-+-chap1-+-sec1.tex
  |       |       +-sec2.tex`
  |       +-chap2-+-sec1.tex`
  |       |       +-sec2.tex`
  +-part2-+-chap1-+-sec1.tex
          |       +-sec2.tex`
If the files are as above, the PCS instance keeps the six filenames whch are sorted alphabetically.
=end
  class PCS
    # Type is one of :PCS, :CS and :S
    # - :PCS => The file structure has part, chap directories.
    # - :CS  => The file structure has chap directories.
    # - :S   => The file structure doesn't have any directories.
    attr_reader :type
    # The name of the top direcotory
    attr_reader :dir
    # Create a new PCS instance.
    # You can give a top directory as an argument.
    def initialize dir="."
      @dir = dir.dup
      @dir.freeze
      @files = Dir.glob("part*/chap*/sec*", base: @dir).select{|f| f.match?(/^part\d+(\.\d+)?\/chap\d+(\.\d+)?\/sec\d+(\.\d+)?\.\w+$/)}
      unless @files.empty?
        @type = :PCS
        @files.sort! do |a, b|
          m = /^part(\d+(\.\d+)?)\/chap(\d+(\.\d+)?)\/sec(\d+(\.\d+)?)\.\w*$/.match(a)
          ap = m[1].to_f; ac= m[3].to_f; as = m[5].to_f
          m = /^part(\d+(\.\d+)?)\/chap(\d+(\.\d+)?)\/sec(\d+(\.\d+)?)\.\w*$/.match(b)
          bp = m[1].to_f; bc= m[3].to_f; bs = m[5].to_f
          if ap != bp
            ap <=> bp
          elsif ac != bc
            ac <=> bc
          else
            as <=> bs
          end
        end
        return
      end
      @files = Dir.glob("chap*/sec*", base: @dir).select{|f| f.match?(/^chap\d+(\.\d+)?\/sec\d+(\.\d+)?\.\w+$/)}
      unless @files.empty?
        @type = :CS
        @files.sort! do |a, b|
          m = /^chap(\d+(\.\d+)?)\/sec(\d+(\.\d+)?)\.\w*$/.match(a)
          ac= m[1].to_f; as = m[3].to_f
          m = /^chap(\d+(\.\d+)?)\/sec(\d+(\.\d+)?)\.\w*$/.match(b)
          bc= m[1].to_f; bs = m[3].to_f
          if ac != bc
            ac <=> bc
          else
            as <=> bs
          end
        end
        return
      end
      @files = Dir.glob("sec*", base: @dir).select{|f| f.match?(/^sec\d+(\.\d+)?\.\w+$/)}
      unless @files.empty?
        @type = :S
        @files.sort! do |a, b|
          m = /^sec(\d+(\.\d+)?)\.\w*$/.match(a)
          as = m[1].to_f
          m = /^sec(\d+(\.\d+)?)\.\w*$/.match(b)
          bs = m[1].to_f
          as <=> bs
        end
        return
      end
      raise "No [[part/]chap/]sec files exist.\n" if @files.empty?
    end

    # Return an array of pathnames which are relative from the top directory.
    # The returned pathnames are the copies.
    # So, even if a user changes them, the original pathnames in the PCS instance are not changed.
    def to_a
      @files.map {|s| s.dup}
    end
    # Executes the block with each pathname.
    def each
      @files.each {|f| yield(f)}
    end
  end

  # Return a hash (key: extension, value: Proc object) of converters.
  def get_converters
    converters = {'.md':  lambda {|src, dst| system("pandoc -o #{dst} #{src}")} }
    if File.file?("converters.rb")
      c = eval(File.read("converters.rb"))
      c.each {|key, val| converters[key] = val} if c.is_a?(Hash)
    end
    converters
  end

  # copy or convert source files into build directory.
  def cp_conv build_dir
    converters = get_converters
    files = Dir.children(".").reject{|f| f == build_dir || f == "main.tex"}
    cp_conv_0 ".", files, build_dir, converters
  end
  # :nodoc:
  def cp_conv_0 sdir, files, ddir, converters
    files.each do |f|
      f1 = "#{sdir}/#{f}"; f2 = "#{ddir}/#{f}"; ext = File.extname(f).to_sym
      if Dir.exist?(f1)
        mkdir_p f2
        f1_files = Dir.children(f1)
        cp_conv_0 f1, f1_files, f2, converters
      elsif converters.has_key?(ext)
        f2 = f2.ext ".tex"
        unless File.exist?(f2) && File.mtime(f1) <= File.mtime(f2)
          converters[ext].call(f1, f2)
        end
      elsif File.file?(f1)
        cp f1, f2
      end
    end
  end
end
