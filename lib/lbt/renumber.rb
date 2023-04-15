module Lbt
  # Renumber the source files.
  # For example,
  # - sec1.tex, sec1.5.tex, sec2.tex => sec1.tex, sec2.tex, sec3.tex
  # - chap1/sec1.tex, chap1/sec1.2.tex, chap1.3/sec10.tex => chap1/sec1.tex, chap1/sec2.tex, chap2/sec1.tex
  def renum
    if Dir.children(".").select{|d| d =~ /^part\d+(\.\d+)?$/}.size > 0
      renumber "part"
    elsif Dir.children(".").select{|d| d =~ /^chap\d+(\.\d+)?$/}.size > 0
      renumber "chap"
    else
      renumber "sec"
    end
  end

  # :nodoc:
  def renumber pcs
    case pcs
    when "part", "chap"
      files = Dir.children(".").select{|d| d =~ /^#{pcs}\d+(\.\d+)?$/}
    when "sec"
      files = Dir.children(".").select{|d| d =~ /^#{pcs}\d+(\.\d+)?\.\w+$/}
    end
    files.sort! do |a,b|
      a.match(/^#{pcs}(\d+(\.\d+)?)/)[1] <=> b.match(/^#{pcs}(\d+(\.\d+)?)/)[1]
    end
    n = files.size
    case pcs
    when "part", "chap"
      temp_files = (1..n).map{|i| "#{pcs}#{i}_temp"}
    when "sec"
      temp_files = (1..n).map{|i| "#{pcs}#{i}#{File.extname(files[i-1])}_temp"}
    end
    n.times do |i|
      File.rename(files[i], temp_files[i])
    end
    n.times do |i|
      File.rename(temp_files[i], temp_files[i].sub(/_temp$/, ""))
    end
    return if pcs == "sec"
    Dir.children(".").select{|d| d =~ /^#{pcs}\d+(\.\d+)?$/}.each do |f|
      cd f
      case pcs
      when "part" then renumber "chap"
      when "chap" then renumber "sec"
      end
      cd ".."
    end
  end
end
