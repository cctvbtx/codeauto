class Column

	attr_accessor :name ,:description  ,:datatype 

	def to_s
		puts "Column Name : #{@name}  Description: #{@description} DataType: #{datatype} "
	end

end
