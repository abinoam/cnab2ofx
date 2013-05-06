Gem::Specification.new do |s|
  s.name              = "cnab2ofx"
  s.version           = "0.0.5"
  s.platform          = Gem::Platform::RUBY
  s.authors           = ["Abinoam Praxedes Marques Junior"]
  s.email             = ["abinoam@gmail.com"]
  s.homepage          = "https://bitbucket.org/abinoam/cnab2ofx"
  s.summary           = "CNAB240 to ofx conversion script"
  s.description       = "A small and simple script that can be used to convert CNAB240 to ofx financial formats"
  s.rubyforge_project = s.name

  s.required_rubygems_version = ">= 1.3.6"
  s.required_ruby_version = ">= 1.9.2"

  # If you have runtime dependencies, add them here
  # s.add_runtime_dependency "other", "~> 1.2"

  # If you have development dependencies, add them here
  # s.add_development_dependency "another", "= 0.9"

  # The list of files to be contained in the gem
  s.files         = `git ls-files`.split("\n")
  s.executables   = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  # s.extensions    = `git ls-files ext/extconf.rb`.split("\n")

  s.require_paths = ['lib', 'helpers']

  # For C extensions
  # s.extensions = "ext/extconf.rb"

  s.post_install_message = "\nA sample generated CNAB240 file is provided at 'test' directory.\n\n"
end
