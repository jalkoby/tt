require 'test_helper'

describe 'Built-in macros' do
  it 'injects translations into I18n' do
    I18n.enforce_available_locales = false
    TT.define_actions(:en, :ru) do |f|
      f.action :store, en: 'Store', ru: 'Сохранить'
    end

    assert_equal I18n.t('actions.store.base', locale: :en), 'Store'
    assert_equal I18n.t('actions.store.base', locale: :ru), 'Сохранить'
    I18n.reload!
  end

  it '#en__an' do
    result = with_factory(:en, :an) do |f|
      f.use_rule_for(:en, :an, [:alarm])

      f.action :add, en: f.macro(:en__an, 'A', 'An')
    end

    assert_equal result[:add], { base: 'A', alarm: 'An' }
  end

  it '#de__gender' do
    list = with_factory(:de, :gender) do |f|
      f.use_rule_for(:de, :feminine, [:role])
      f.use_rule_for(:de, :neuter, [:company])

      f.action :choose_gender, de: f.macro(:de__gender, 'M', 'F', 'N')
    end

    assert_equal list[:choose_gender], { base: 'M', role: 'F', company: 'N' }
  end

  it '#ru__accuse' do
    list = with_factory(:ru, :accuse) do |f|
      f.use_rule_for(:ru, :accuse, man: { r: 'man', R: 'Man' }, woman: { RS: 'Women', rs: 'women' })

      f.action :accuse, ru: f.macro(:ru__accuse, "%{r} %{rs} %{R} %{RS}")
    end

    assert_equal list[:accuse], {
      base: "%{r} %{rs} %{R} %{RS}", man: "man %{rs} Man %{RS}", woman: "%{r} women %{R} Women"
    }
  end

  private

  def with_factory(lang, macro)
    factory = TT::ActionFactory.new(lang)
    TT::ActionMacros.send("#{ lang }__#{ macro }", factory)
    yield factory
    factory.as_hash[lang][:actions]
  end
end
