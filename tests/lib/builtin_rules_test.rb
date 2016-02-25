require 'test_helper'

describe 'Built-in rules' do
  it '#en__an' do
    result = with_factory(:en, :an) do |f|
      f.for(:en) { |l| l.use_rule_for(:an, :alarm) }

      f.add :add, en: f.with_rules('A', an: 'An')
    end

    assert_equal result[:base][:add], 'A'
    assert_equal result[:alarm][:add], 'An'
  end

  it '#de__gender' do
    list = with_factory(:de, :gender) do |f|
      f.for(:de) do |l|
        l.use_rule_for(:feminine, :role)
        l.use_rule_for(:neuter, :company)
      end

      f.add :choose_gender, de: f.with_rules('M', feminine: 'F', neuter: 'N')
    end

    assert_equal list[:base][:choose_gender], 'M'
    assert_equal list[:role][:choose_gender], 'F'
    assert_equal list[:company][:choose_gender], 'N'
  end

  it '#ru__accuse' do
    list = with_factory(:ru, :accuse) do |f|
      f.for(:ru) do |l|
        l.use_rule_for(:accuse, man: { r: 'man', R: 'Man' }, woman: { RS: 'Women', rs: 'women' })
      end

      f.add :accuse, ru: f.with_rules("%{r} %{rs} %{R} %{RS}", :accuse)
    end

    assert_equal list[:base][:accuse], "%{r} %{rs} %{R} %{RS}"
    assert_equal list[:man][:accuse], "man %{rs} Man %{RS}"
    assert_equal list[:woman][:accuse], "%{r} women %{R} Women"
  end

  private

  def with_factory(lang, macro)
    TT.define_actions(lang) do |f|
      f.activate_rules("#{ lang }__#{ macro }")
      yield f
    end[lang][:actions]
  end
end
