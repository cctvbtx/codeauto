$:.unshift '.'
require 'erb'
require 'column'
require 'dataschema'
include ERB::Util
require 'tiny_tds'

help =%q{
@@filename = 'table.html.erb' 

#method 1 
# class Template 
#   extend ERB::DefMethod
#   def_erb_method('render()', "template/#{@@filename}")
#   def initialize(items)
#     @columns = items
#   end
# end

# method 2 
# class MyClass_
#   def initialize(arg1 )
#     @columns = arg1 
#   end
# end


# erb = ERB.new(File.open("template/#{@@filename}"    ))
# erb.filename = "template/#{@@filename}"
# MyClass = erb.def_class(MyClass_, 'render()')

# print MyClass.new(@columns ).render()


# f = File.open "output/#{@@filename}" ,'w:utf-8'
# result  =  Template.new(@columns).render()

# f.write(result.encode('gb2312'))
# f.close 

#methods 3 OK 
class Template2

  def initialize( items)
    @columns = items        
  end
  
  def get_binding
    binding
  end
end 

f = File.open("template/#{@@filename}" ,'r:utf-8') 
template = f.read 
puts template.encoding
rhtml = ERB.new(template)
result =  rhtml.result(Template2.new(@columns).get_binding)
p result.encoding
ff = File.open "output/#{@@filename}" ,'w:utf-8'
 

ff.write result  
ff.close 


}
 
# puts  help if File.basename(__FILE__) =='codeauto.rb'