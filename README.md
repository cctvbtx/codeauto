codeauto
========

codeauto is a tool for genereating code from mssql description  like codesmith

how to use 
==========

- example  : exam1.rb
----------
```ruby

$:.unshift '.'
$:.unshift '../lib'
# puts $:
require 'codeauto'

@@filename = 'table.html.erb'  

dc = DataSchema.new( '192.168.168.81' ,'dbname' ,'sa' ,'xxxxxx')


 
@columns =dc.get_columns_all 'tmpinvoice' ,'ems'  
 	

f = File.open("#{@@filename}" ,'r:utf-8') 
template = f.read 
puts template.encoding
rhtml = ERB.new(template)
result =  rhtml.result
p result.encoding
ff = File.open "#{Time.now.strftime('%Y%m%d%s')}_#{@@filename}" ,'w:utf-8'
ff.write result  
ff.close 

rescue Exception => e
	 puts "error:#{$!} at:#{$@}"		
ensure  
	puts 'ensure it here '
end 

```
template :  table.html.erb
--------------------------
```html 

<% @columns.each do | column| %> <%= "'#{column[:name].strip}'".ljust(20)  + " => "+" '#{column[:description].strip}' ,".ljust(20) %> 
<% end %> 

``` 