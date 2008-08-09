if RAILS_ENV == 'production'
  config = ActiveRecord::Base.configurations['production']
  if config['adapter'] == 'mysql' 
    ActiveRecord::Base.require_mysql
    if Mysql::VERSION.to_s.include?('-ruby')
      abort "Ruby-based MySQL driver is not suitable for production"
    end
  end
end