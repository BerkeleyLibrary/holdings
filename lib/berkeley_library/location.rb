Dir.glob(File.expand_path('location/*.rb', __dir__)).each(&method(:require))
