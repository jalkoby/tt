require 'active_support/file_update_checker'
require 'yaml'

module TT
  class I18nSync
    MARK = ":t_t: "

    module Utils
      extend self

      def flat_hash(value, key = nil)
        case value
        when Hash
          value.inject({}) { |r, (k, v)| r.merge! flat_hash(v, [key, k].compact.join('/')) }
        else
          { key => value }
        end
      end

      def flat_file(*args)
        flat_hash(load_file(*args))
      end

      def load_file(path, locale, &block)
        content = YAML.load_file(path)
        yield content if block_given?
        content.fetch(locale.to_s) do
          TT.raise_error "expected #{ path } should contain `#{ locale }` translations"
        end
      end

      def sync_file(path, locale, standard)
        old_review = {}
        source = load_file(path, locale) { |content| old_review.merge!(content.fetch('review', {})) }
        new_review = {}
        content = { locale => sync_level(standard, source, new_review) }
        review = old_review.merge(flat_hash(new_review))
        content['review'] = review unless review.empty?
        write_file(path, content)
      end

      def write_file(path, content)
        File.open("#{ path }", "wb") { |stream| YAML.dump(content, stream, line_width: 1000) }
      end

      private

      def sync_level(st_level, source, review)
        level = st_level.inject({}) do |r, (key, st_node)|
          node = source[key]

          r[key] = case st_node
          when Hash
            sub_review = {}
            sub_level = sync_level(st_node, (node.is_a?(Hash) ? node : {}), sub_review)
            review[key] = sub_review unless sub_review.empty?
            sub_level
          when Array then node.is_a?(Array) ? node : st_node.map { |v| "#{ MARK }#{ v }" }
          else
            node.nil? ? "#{ MARK }#{ st_node }" : node
          end
          r
        end

        (source.keys - st_level.keys).each { |key| review[key] = source[key] }

        level
      end
    end

    class FileGroup
      attr_reader :st_locale, :standard, :list

      def initialize(st_locale, standard, list)
        @st_locale = st_locale
        @standard = standard
        @list = list
      end

      def execute
        file_updated_at = File.mtime(standard)
        return if file_updated_at == @prev_updated_at

        st_source = Utils.load_file(standard, st_locale)
        list.each { |l, path| Utils.sync_file(path, l, st_source) }

        @prev_updated_at = file_updated_at
      end

      def missed
        flat_list = list.inject({}) { |r, (l, path)| r.merge!(l => Utils.flat_file(path, l)) }

        Utils.flat_file(standard, st_locale).inject([]) do |list, (k, st_v)|
          item = flat_list.inject({ st_locale => st_v }) { |r, (l, h)| r.merge!(l => h[k]) }
          list << item if item.any? { |l, v| v.nil? }
          list
        end
      end
    end

    attr_reader :checker, :groups

    def initialize(locales, files)
      @groups = []
      main = locales.first

      files.inject({}) do |r, file|
        parts = file.split('.')
        k = parts[0...-2].join('.')
        l = File.basename(parts[-2])
        r[k] ||= {}
        r[k][l] = file
        r
      end.each_value do |group|
        next unless locales.all? { |l| group.has_key?(l) }

        list = locales.inject({}) do |r, l|
          r[l] = group[l] unless l == main
          r
        end

        groups << FileGroup.new(main, group[main], list)
      end

      @checker = ActiveSupport::FileUpdateChecker.new(groups.map(&:standard)) { execute }
    end

    def execute
      groups.each(&:execute)
    end

    def missed
      groups.inject({}) do |r, group|
        unless (list = group.missed).empty?
          base_path = group.standard.split(group.st_locale)[0]
          key = "#{ base_path }(*).yml"
          r[key] = list
        end
        r
      end
    end
  end
end
