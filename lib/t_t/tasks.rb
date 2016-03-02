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
  task :m => [:s] do
    if sync = TT::Rails.sync
      sync.missed.each do |group, list|
        puts "# #{ group }"
        puts line.inject("") { |r, (k, v)| r + "#{ k.upcase }: #{ v.to_s.encode('utf-8') }\n" }
        puts '---'
      end
    else
      puts "t_t: Please, setup the synchronisation first"
    end
  end
end
