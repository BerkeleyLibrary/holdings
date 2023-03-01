SimpleCov.start do
  add_filter 'module_info.rb'
  coverage_dir 'artifacts/coverage'

  enable_coverage :branch
  minimum_coverage line: 100, branch: 100
end
