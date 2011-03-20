# encoding: utf-8
 
Gem::Specification.new do |s|
  s.name = 'acts_as_enum'
  s.version = '0.0.1'
  s.summary = 'Enum Attribute for Rails'
  s.description = '主要应用于有枚举类型属性的Model，这个插件会帮我们生成一些常用到的方法。'
  
  s.required_ruby_version     = '>= 1.8.6'
  s.required_rubygems_version = '>= 1.3.5'

  s.author            = 'Wenke Liang'
  s.email             = 'liangwenke8@gmail.com'
  s.homepage          = 'http://github.com/wenke/acts_as_enum'
  s.rubyforge_project = 'acts_as_enum'
  
  s.extra_rdoc_files = ["README.rdoc"]
  s.files = %w(
    MIT-LICENSE
    Rakefile
    README.rdoc
    lib/acts_as_enum.rb
    test/helper.rb
    test/acts_as_enum_test.rb
  )
  s.require_paths = %w(lib)  
end
