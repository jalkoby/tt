module TT
  module Formaters
    extend self

    def print(groups, format)
      case format
      when 'csv' then csv(groups)
      else stdout(groups)
      end
    end

    private

    def stdout(groups)
      groups.each do |group, list|
        puts "# #{ group }"

        list.each do |line|
          puts line.inject("") { |r, (k, v)| r + "#{ k.upcase }: #{ v.to_s.encode('utf-8') }\n" }
        end

        puts '---'
      end
    end

    def csv(groups)
      return if groups.empty?

      require 'csv'
      CSV.open('tmp/tt-missed.csv', 'w') do |io|
        locales = groups.first.last.first.keys.sort
        io << locales.map(&:upcase)
        groups.each_value { |list| list.each { |line| io << line.values_at(*locales) } }
      end
    end
  end
end
