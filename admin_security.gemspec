$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "admin_security/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "admin_security"
  s.version     = AdminSecurity::VERSION
  s.authors     = ["Thomas Balthazar"]
  s.email       = ["thomas@balthazar.info"]
  s.homepage    = "https://github.com/tbalthazar/admin_security"
  s.summary     = "A gem that simplifies the use of a restricted (admin) area"
  s.description = "This gem gives you helper methods to protect some of your controllers"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.1"

  s.add_development_dependency "sqlite3"
end
