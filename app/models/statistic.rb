module Variance
  def sum(identity = 0, &block)
    if block_given?
      map(&block).sum(identity)
    else
      inject(:+) || identity
    end
  end

  def mean
    return 0 if size.zero?
    (sum.to_f / size.to_f)
  end

  def variance
    return 0 if size.zero?
    m = mean
    sum { |i| ( i - m )**2 } / size
  end

  def std_dev
    variance && Math.sqrt(variance)
  end
end
Array.send :include, Variance

class Statistic
  include Mongoid::Document
  embedded_in :dashboard
  field :stat_key, :type => String
  field :value, :type => Float

  def self.average_source_score_with_deviation(dashboard)
    self.average_model_score_with_deviation(Source, dashboard)
  end

  def self.average_feed_score_with_deviation(dashboard)
    self.average_model_score_with_deviation(Feed, dashboard)
  end

  def self.average_model_score_with_deviation(klass, dashboard)
    # sources = dashboard.send(klass.to_s.tableize).only(:scores)
    sources = klass.send(:exists, {"scores.#{dashboard.id.to_s}" => true})

    scores = sources.map{|source|
      source.scores[dashboard.id.to_s]
    }.compact

    scores_size = scores.size.to_i

    klass_string = klass.to_s.underscore
    count_key = "#{klass_string}_scores_count"
    avg_key   = "#{klass_string}_scores_avg"
    dev_key   = "#{klass_string}_scores_dev"

    if (self.get(dashboard, count_key) && self.get(dashboard, count_key).value.to_i === scores_size)
      return [self.get(dashboard, avg_key).value.to_f, self.get(dashboard, dev_key).value.to_f]
    else
      mean  = scores.mean
      dev   = scores.std_dev

      self.set(dashboard, avg_key, mean )
      self.set(dashboard, dev_key, dev)
      self.set(dashboard, count_key, scores.size)

      return [mean, dev]
    end
  end

  def self.get(dashboard, key)
    dashboard.statistics.where(:stat_key => key).first
  end

  def self.set(dashboard, key, value)
    dashboard.statistics.find_or_initialize_by(:stat_key => key).update_attributes(:value => value)
  end


end
