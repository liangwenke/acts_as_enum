# encoding: utf-8

version = File.read(File.expand_path("../VERSION",__FILE__)).strip

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name = 'acts_as_enum'
  s.version = version
  s.summary = 'Enum Attribute for Rails'
  s.description = '主要应用于有枚举类型属性的Model，这个插件会帮我们生成一些常用到的方法。'

  s.required_ruby_version     = '>= 1.8.7'
  s.required_rubygems_version = ">= 1.3.6"
  
  s.authors     = ["LiangWenKe"]
  s.email       = ["liangwenke8@gmail.com"]
  s.homepage    = "http://www.liangwenke.com"
  s.rubyforge_project = "acts_as_enum"

  s.require_path = 'lib'
end
