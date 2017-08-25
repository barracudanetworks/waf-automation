require 'rubygems'
require 'bundler/setup'

require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'
require 'rubocop/rake_task'

# This gem isn't always present, for instance
# on Travis with --without development
begin
  require 'puppet_blacksmith/rake_tasks'
rescue LoadError # rubocop:disable Lint/HandleExceptions
end

# This gem isn't always present, for instance
# on Travis with --without acceptance
begin
require 'master_manipulator'
rescue LoadError # rubocop:disable Lint/HandleExceptions
end

RuboCop::RakeTask.new

exclude_paths = [
  "pkg/**/*",
  "vendor/**/*",
  "spec/**/*",
]

Rake::Task[:lint].clear

PuppetLint.configuration.relative = true
PuppetLint.configuration.disable_140chars
PuppetLint.configuration.disable_class_inherits_from_params_class
PuppetLint.configuration.fail_on_warnings = true
PuppetLint::RakeTask.new :lint do |config|
  config.ignore_paths = exclude_paths
end

PuppetSyntax.exclude_paths = exclude_paths

# Use our own metadata task so we can ignore the non-SPDX PE licence
Rake::Task[:metadata].clear
desc "Check metadata is valid JSON"
task :metadata do
  sh "bundle exec metadata-json-lint metadata.json --no-strict-license"
end

desc "Run syntax, lint, and spec tests."
task :test => [
  :metadata,
  :syntax,
  :lint,
  :rubocop,
  :spec,
]
