desc "switch logger to stdout"
task :to_stdout => [:environment] do
 Rails.logger = Logger.new(STDOUT)
end
