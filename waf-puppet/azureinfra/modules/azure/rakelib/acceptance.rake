require 'rake'
require 'parallel_tests'

# We clear the Beaker rake tasks from spec_helper as they assume
# rspec-puppet and a certain filesystem layout
Rake::Task[:beaker_nodes].clear
Rake::Task[:beaker].clear

module ParallelTests
  module Tasks
    def self.parse_args(args)
      args = [args[:count], args[:options]]

      # count given or empty ?
      # parallel:spec[2,options]
      # parallel:spec[,options]
      count = args.shift if args.first.to_s =~ /^\d*$/
      num_processes = count.to_i unless count.to_s.empty?
      options = args.shift

      [num_processes, options.to_s]
    end
  end
end

namespace :parallel do
  desc "Run acceptance in parallel with parallel:acceptance[num_cpus]"
  task :acceptance, [:count, :options] do |t, args|
    ENV['BEAKER_TESTMODE'] = 'local'
    count, options = ParallelTests::Tasks.parse_args(args)
    executable = 'parallel_test'
    command = "#{executable} spec --type rspec " \
      "-n #{count} "                 \
      "--pattern 'spec/acceptance' " \
      "--test-options '#{options}'"
    abort unless system(command)
  end
end

PE_RELEASES = {
  '3.8.1' => 'http://pe-releases.puppetlabs.lan/3.8.1/',
  '2015.2' => 'http://pe-releases.puppetlabs.lan/2015.2.3/',
  '2015.3' => 'http://enterprise.delivery.puppetlabs.net/2015.3/preview/',
  '2016.2' => 'http://pe-releases.puppetlabs.lan/2016.2.1/',
}.freeze

desc "Run acceptance tests"
RSpec::Core::RakeTask.new(:acceptance => [:spec_prep]) do |t|
  ENV['BEAKER_PE_DIR'] = ENV['BEAKER_PE_DIR'] || PE_RELEASES['2015.2']
  ENV['BEAKER_set'] = ENV['BEAKER_set'] || 'vagrant/ubuntu1404'
  t.pattern = 'spec/acceptance'
end

namespace :acceptance do
  {
    :vagrant => [
      'ubuntu1404',
      'centos7',
      'centos6',
      'ubuntu1404m_debian7a',
      'ubuntu1404m_ubuntu1404a',
      'centos7m_centos7a',
      'centos6m_centos6a',
    ],
    :pooler => [
      'ubuntu1404',
      'centos7',
      'centos6',
      'ubuntu1404m_debian7a',
      'ubuntu1404m_ubuntu1404a',
      'centos7m_centos7a',
      'centos6m_centos6a',
      'rhel7',
      'rhel7m_scientific7a',
      'centos7m_windows2012a',
      'centos7m_windows2012r2a',
    ]
  }.each do |ns, configs|
    namespace ns.to_sym do
      configs.each do |config|
        PE_RELEASES.each do |version, pe_dir|
          desc "Run acceptance tests for #{config} on #{ns} with PE #{version}"
          RSpec::Core::RakeTask.new("#{config}_#{version}".to_sym => [:spec_prep]) do |t|
            ENV['BEAKER_PE_DIR'] = pe_dir
            ENV['BEAKER_keyfile'] = '~/.ssh/id_rsa-acceptance' if ns == :pooler
            ENV['BEAKER_debug'] = true if ENV['BEAKER_DEBUG']
            ENV['BEAKER_set'] = "#{ns}/#{config}"
            t.pattern = 'spec/acceptance'
          end
        end
      end
    end
  end
end
