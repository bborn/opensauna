class BaseClassifier < BaseWorker

  def initialize(prefix = '')
    @host, @port = Mongoid.sessions['default']['hosts'].first.split(':')
    @db = Mongoid.sessions['default']['database']
    @username = Mongoid.sessions['default']['username']
    @password = Mongoid.sessions['default']['password']

    @options = {
      :host => @host,
      :port => @port,
      :db => @db,
      :frequency_tablename => "#{prefix}_word_frequencies",
      :summary_tablename => "#{prefix}_summary"
    }
    if @password
      @options[:username] = @username
      @options[:password] = @password
    end

    @storage    = Ankusa::MongoDbStorage.new @options

    @classifier = Ankusa::NaiveBayesClassifier.new @storage
  end

  def storage
    @storage
  end

  def classifier
    @classifier
  end

  def database
    db = Mongo::Connection.new(@options[:host], @options[:port]).db(@db)
    db.authenticate(@username, @password) if @password
    db
  end


end
