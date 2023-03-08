Dir.glob(File.expand_path('xlsx/*.rb', __dir__)).each(&method(:require))
