class UrlReferenceWorker < BaseWorker

  sidekiq_options :retry => 2,
                  :unique => true

  def perform(id)
    if reference = UrlReference.find(id)
      reference.classify
    end
  end

end
