require 'factory_bot_rails'

namespace :nilm do 
  desc "Add a nilmdb database"
  task :add, [:email, :name, :url] => [:environment] do |t, args|
    adapter = Nilmdb::Adapter.new(args[:url])
    service = CreateNilm.new(adapter)
    service.run(name: args[:name], url: args[:url],
                owner: User.find_by_email(args[:email]))
    if service.success?
      puts "created Nilm #{args[:name]} with owner #{args[:email]}"
    else
      puts args.warnings
      puts args.errors
    end
  end
end

