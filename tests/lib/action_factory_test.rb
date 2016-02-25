require 'test_helper'

describe "Action factory" do
  describe "adding an actions" do
    it 'adds an action' do
      result = factory(:es) { |f| f.add :sing, es: 'cantar' }
      assert_equal result, { es: { actions: { base: { sing: 'cantar' } } } }
    end

    it 'checks a locale action presence' do
      assert_raises(ArgumentError, 't_t: action `run` is missing for `fr` locale') do
        factory(:fr) { |f| f.add :run, en: 'Run' }
      end
    end

    it 'checks a locale rule presence' do
      assert_raises(ArgumentError, 't_t: `feminine` is an unknown rule for `es` locale') do
        factory(:es) { |f| f.add :swim, es: f.with_rules('El nada', feminine: 'Ella nada') }
      end
    end

    it 'checks a valid action type' do
      assert_raises(ArgumentError, 't_t: the value of `count` action for `fr` locale has a wrong type') do
        factory(:fr) { |f| f.add :count, fr: 34 }
      end
    end
  end

  describe "adding an exceptions" do
    it 'adds an exception' do
      result = factory(:en) do |f|
        f.add :add, en: 'Add a new'
        f.add_exception :user, en: { add: 'Register a new' }
      end

      assert_equal result, { en: { actions: { base: { add: 'Add a new' }, user: { add: 'Register a new' } } } }
    end

    it 'checks a locale presence' do
      assert_raises(ArgumentError, 't_t: `ru` is an unknown locale') do
        factory(:en) do |f|
          f.add :add, en: 'Add a new'
          f.add_exception :user, ru: { add: 'Register a new' }
        end
      end
    end

    it 'checks an action presence' do
      assert_raises(ArgumentError, 't_t: `listen` action is not specified. Do it before add an exception') do
        factory(:en) { |f| f.add_exception :visitor, en: { listen: "listen to a band" } }
      end
    end
  end

  private

  def factory(*args, &block)
    TT.define_actions(*args, &block)
  end
end
