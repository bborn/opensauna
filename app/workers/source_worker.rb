
class SourceWorker < BaseWorker
  sidekiq_options :retry => false,
                  :unique => true

  def perform(source_id)
    Source.find(source_id).process
  end


  def self.process_all
    Source.all.each do |source|
      source.queue_worker
    end
  end

end
