task default: [:test, :execute]

desc "Running all tests"
task :test do 
    sh "rspec spec/rovers_spec.rb --format documentation"
end

desc "Executes ruby rover program"
task :execute do
    sh "ruby lib/rovers.rb"
end 