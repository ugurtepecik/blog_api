# typed: false

if defined?(Tapioca)
  Rails.application.config.after_initialize do
    Rails.application.eager_load! # <— BU, Zeitwerk kurul­duktan sonra
    # İsterseniz tanılama satırı ekleyin:
    puts '[TAPIOCA] eager-load tamam'
  end
end
