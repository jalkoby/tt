require 'test_helper'

describe 'I18n synchronisation' do
  it 'add a missing keys' do
    store = {
      'en' => { 'a' => 'a', 'b' => 'b', 'c' => { 'd' => 'd' }, 'e' => { 'f' => ['k', 'l'] } },
      'de' => { 'b' => 'de-b' }
    }

    YAML.stub :load_file, store do
      group = TT::I18nSync::FileGroup.new('en', __FILE__, { 'de' => 'de.yml' })
      expectation = lambda do |path, content|
        assert_equal path, 'de.yml'
        assert_equal content, {
          'de' => {
            'a' => ':t_t: a', 'b' => 'de-b',
            'c' => { 'd' => ':t_t: d' },
            'e' => { 'f' => [':t_t: k', ':t_t: l'] }
          }
        }
      end

      utils = TT::I18nSync::Utils
      utils.stub(:write_file, expectation) { group.execute }

      should_not_call_twice = proc { assert false, "should not call twice" }
      utils.stub(:write_file, should_not_call_twice) { group.execute }
    end
  end

  it 'saves the previous review and adds a new' do
    store = {
      'review' => { 'c/d' => 'c', 'r' => 'r' },
      'en' => { 'a' => 'a', 'b' => 'b', 'c' => { 'd' => 'd' } },
      'de' => { 'b' => 'de-b' }
    }
    YAML.stub :load_file, store do
      group = TT::I18nSync::FileGroup.new('de', __FILE__, { 'en' => 'en.yml' })
      expectation = lambda do |path, content|
        assert_equal path, 'en.yml'
        assert_equal content['en'], { 'b' => 'b' }
        assert_equal content['review'].sort, [['a', 'a'], ['c/d', 'd'], ['r', 'r']]
      end

      utils = TT::I18nSync::Utils
      utils.stub(:write_file, expectation) { group.execute }
    end
  end

  it 'combines files into a full groups' do
    groupMock = Struct.new(:locale, :standard, :list) do
      def execute
      end
    end

    TT::I18nSync::FileGroup.stub(:new, proc { |*args| groupMock.new(*args) }) do
      sync = TT::I18nSync.new(['de', 'es', 'en-US'], [
        'config/locales/fr.yml', 'config/locales/views.bg.yml', 'config/locales/models/orm.nl.yml',
        'config/locales/de.yml', 'config/locales/views.de.yml', 'config/locales/models/orm.en-US.yml',
        'config/locales/es.yml', 'config/locales/views.en-US.yml', 'config/locales/models/orm.de.yml',
        'config/locales/en-US.yml', 'config/locales/views.es.yml', 'config/locales/models/orm.es.yml'
      ])

      assert_equal 3, sync.groups.length
      assert sync.groups.all? { |g| g.locale == 'de' && g.list.keys == ['es', 'en-US'] }
      sync.groups[0].tap do |group|
        assert_equal 'config/locales/de.yml', group.standard
        assert_equal({ 'es' => 'config/locales/es.yml', 'en-US' => 'config/locales/en-US.yml' }, group.list)
      end
    end
  end

  it 'shows all missed translations' do
    store = {
      'en' => { 'a' => 'a', 'b' => 'b', 'c' => { 'd' => 'd' } },
      'de' => { 'b' => 'de-b' }
    }
    YAML.stub :load_file, store do
      sync = TT::I18nSync.new(['en', 'de'], ['en.yml', 'de.yml'])
      result = sync.missed

      assert_equal 1, result.size
      assert_equal '(*).yml', result.keys.first

      result['(*).yml'].tap do |list|
        assert_equal 2, list.size
        assert_equal({ 'en' => 'a', 'de' => nil }, list.first)
        assert_equal({ 'en' => 'd', 'de' => nil }, list.last)
      end
    end
  end
end
