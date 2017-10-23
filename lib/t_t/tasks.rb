namespace :tt do
  desc "Synchronises the translation file groups"
  task :s => :environment do
    if sync = TT::Rails.sync
      sync.execute
    else
      puts "t_t: Please, setup the synchronisation first"
    end
  end

  desc "Shows a missed keys in the translation file groups"
  task :m, [:format] => [:s] do |t, args|
    if sync = TT::Rails.sync
      require_relative './formaters'
      TT::Formaters.print(sync.missed, args[:format])
    else
      puts "t_t: Please, setup the synchronisation first"
    end
  end
end
