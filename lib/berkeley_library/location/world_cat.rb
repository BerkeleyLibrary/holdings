Dir.glob(File.expand_path('world_cat/*.rb', __dir__)).each(&method(:require))
