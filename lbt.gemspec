Gem::Specification.new do |s|
  s.name              = 'lbt'
  s.version           = '0.5'
  s.summary           = 'LaTeX Build Tools'
  s.description       = 'Lbt is a build tool for LaTeX. It is useful for big documents.'
  s.licenses          = ['GPL-3.0']
  s.author            = 'Toshio Sekiya'
  s.email             = 'lxboyjp@gmail.com'
  s.homepage          = 'https://github.com/ToshioCP/LaTeX-BuildTools'
  s.files             = ['bin/lbt', 'lib/lbt.rb', 'lib/lbt/build.rb', 'lib/lbt/create.rb', 'lib/lbt/part_typeset.rb', 'lib/lbt/renumber.rb', 'lib/lbt/utils.rb']
  s.executables       = ['lbt']
end
