$:<< '.'
require 'column'
require 'tiny_tds'
 
class DataSchema
    def initialize( host , database ,username, password)
    @host = host
    @database = database 
    @username = username
    @password = password
    @columns = [] 
    @client = TinyTds::Client.new(:username => @username, :password => @password, 
      :host => @host,:database=>@database)
    puts @client 
   end

   def get_client
      @client 
   end 
   # 返回字段所有信息
   def get_columns_all (tablename,schema='dbo',view='table')
      columns_all= [] 
      @columns    = get_columns(tablename ,schema,view)
      @columnsdef = column_definitions(tablename ,schema)

      @columnsdef.each do | cdef|
        @columns.each do | col|
          if col[:name] == cdef[:name] 
            cdef.merge! col 
          end

        end
        cdef[:description]= cdef[:name] unless cdef.has_key? :description
        columns_all << cdef  
      end


   end

   def get_columns (tablename,schema='dbo' ,view='table')

      sql =" SELECT objname ,value FROM   ::fn_listextendedproperty ('MS_Description', 'schema', '#{schema}', '#{view}', '#{tablename}' , 'column', default) "
      # puts sql 
      columns = [] 
       result = @client.execute(sql)
       result.each do |row|
           # p " #{row['objname']}  ---- #{row['value']}"
           # p " #{row['objname'].encode!('gb2312')}  ---- #{row['value'].encode!('gb2312')}"
           
          # c           = Column.new 
          # c.name        = row['objname'] 

          # c.description     = row['value']
          

          columns << {:name =>row['objname']  , :description =>  row['value']}
      end 
      return columns 
    end 
    def column_definitions(table_name ,schema='dbo')
           
          sql = "
            SELECT DISTINCT 
             columns.TABLE_NAME  AS table_name,
             columns.COLUMN_NAME  AS name,
            columns.DATA_TYPE AS type,
            columns.COLUMN_DEFAULT AS default_value,
            columns.NUMERIC_SCALE AS numeric_scale,
            columns.NUMERIC_PRECISION AS numeric_precision,
            columns.ordinal_position,
             
            CASE
              WHEN columns.DATA_TYPE IN ('nchar','nvarchar') THEN columns.CHARACTER_MAXIMUM_LENGTH
              ELSE COL_LENGTH( columns.TABLE_SCHEMA+'.'+columns.TABLE_NAME, columns.COLUMN_NAME)
            END AS [length],

            CASE 
              WHEN KCU.COLUMN_NAME IS NOT NULL AND TC.CONSTRAINT_TYPE = N'PRIMARY KEY' THEN 1
              ELSE NULL
            END AS [is_primary],
            c.is_identity AS [is_identity]
            FROM  INFORMATION_SCHEMA.COLUMNS columns
            LEFT OUTER JOIN  INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS TC
              ON TC.TABLE_NAME = columns.TABLE_NAME
              AND TC.CONSTRAINT_TYPE = N'PRIMARY KEY'
            LEFT OUTER JOIN  INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS KCU
              ON KCU.COLUMN_NAME = columns.COLUMN_NAME
              AND KCU.CONSTRAINT_NAME = TC.CONSTRAINT_NAME
              AND KCU.CONSTRAINT_CATALOG = TC.CONSTRAINT_CATALOG
              AND KCU.CONSTRAINT_SCHEMA = TC.CONSTRAINT_SCHEMA
            INNER JOIN  sys.schemas AS s
              ON s.name = columns.TABLE_SCHEMA
              AND s.schema_id = s.schema_id
            INNER JOIN  sys.objects AS o
              ON s.schema_id = o.schema_id
              AND o.is_ms_shipped = 0
              AND o.type IN ('U', 'V')
              AND o.name = columns.TABLE_NAME
            INNER JOIN  sys.columns AS c
              ON o.object_id = c.object_id
              AND c.name = columns.COLUMN_NAME
            WHERE columns.TABLE_NAME = '#{table_name}'
              AND columns.TABLE_SCHEMA = '#{schema}'
            ORDER BY columns.ordinal_position
          "

           # puts sql 
          
          results =  @client.execute(sql)
          results.collect do |ci|
            # puts '---' 
            # puts ci 
            # ci = ci.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo} #new hash 
            ci.keys.each do |key|
              ci[(key.to_sym rescue key) || key] = ci[key] #ci.delete(key)
            end
            ci[:rbtype] = case ci[:type]
                         when /^datetime$/
                           'datetime'
                         when /^numeric|decimal|float|real$/i
                           "float"
                         when /^bigint|int|smallint$/
                            "integer"
                         when /^char|nchar|varchar|nvarchar|varbinary$/
                           "string"
                         when /^image|text|ntext$/
                           "text"
                         when /^bit$/
                           "boolean"
                         else
                           "string"
                         end
            # ci[:type] = case ci[:type]
            #              when /^bit|image|text|ntext|datetime$/
            #                ci[:type]
            #              when /^numeric|decimal$/i
            #                "#{ci[:type]}(#{ci[:numeric_precision]},#{ci[:numeric_scale]})"
            #              when /^float|real$/i
            #                "#{ci[:type]}(#{ci[:numeric_precision]})"
            #              when /^char|nchar|varchar|nvarchar|varbinary|bigint|int|smallint$/
            #                ci[:length].to_i == -1 ? "#{ci[:type]}(max)" : "#{ci[:type]}(#{ci[:length]})"
            #              else
            #                ci[:type]
            #              end
            
            # ci[:default_value] =  ''
            # ci[:null] = ci[:is_nullable].to_i == 1 ; ci.delete(:is_nullable)
            # ci[:is_primary] = ci[:is_primary].to_i == 1
            # ci[:is_identity] = ci[:is_identity].to_i == 1 # unless [TrueClass, FalseClass].include?(ci[:is_identity].class)
            # puts 'ci row ' + ci.class.to_s
            ci  
          end
          # puts 'result ' +results.class.to_s
          return results 
  end 

end #end class 

# test code here:  
 # dc = DataSchema.new( '192.168.168.81' ,'dbGalaxy_pisces' ,'sa' ,'qwe123,.')
#  cs = dc.get_columns 'receiver' ,'ems'
#  puts cs.count 
#  cs.each do |c| 
#   puts c.to_s 
# end
# puts '----------'
# cs = dc.column_definitions 'receiver' ,'ems'
# cs.each do |c|
#   puts  "normal #{c['name']}  #{c['rbtype']}      --  #{c['type']}"
#   puts  "symbol #{c[:name]}  #{c[:rbtype]}      --  #{c[:type]}"
# end 
# test get_columns_all
#  dc = DataSchema.new( '192.168.168.81' ,'dbGalaxy_pisces' ,'sa' ,'qwe123,.')
#  cs = dc.get_columns_all 'receiver' ,'ems'
#  puts cs.count 
#  cs.each do |c| 
#   puts c.to_s 
# end


