SolidCable.configure do |config|
  # Force all jobs to run immediately (inline) instead of enqueuing
  config.async_adapter = :inline
end