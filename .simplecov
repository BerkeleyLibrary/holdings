SimpleCov.start do
  add_filter 'module_info.rb'
  coverage_dir 'artifacts/coverage'
  minimum_coverage 100
end
