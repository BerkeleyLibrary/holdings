Dir.glob(File.expand_path('holdings/*.rb', __dir__)).each(&method(:require))
