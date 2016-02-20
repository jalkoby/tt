module TT
  module ActionMacros
    extend self

    # The indefinite article a (before a consonant sound) or an (before a vowel sound)
    # is used only with singular, countable nouns.
    def en__an(f)
      f.set_rule(:en, :an) { |config, _| config.fetch(:an) }

      f.add_macro(:en__an) do |a_text, an_text|
        { base: a_text, rules: :an, an: an_text }
      end
    end

    # The articles in German
    # | masculine | feminine | neuter | plural |
    # | neuen     | neue     | neues  | neue   |
    # | keinen    | keine    | kein   | keine  |
    # | der       | die      | das    | die    |

    # this lambda generate default translation for masculine form
    # & add exceptions for feminine & neuter genders
    # ie
    #   new:
    #     base: "Neuen %{r} hinzufügen"    -> "Neuen Benutzer anlegen"
    #     company: "Neues %{r} hinzufügen" -> "Neues Unternehmen anlegen"
    #     role: "Neue %{r} hinzufügen"     -> "Neue Rolle hinzufügen"
    def de__gender(f)
      f.set_rule(:de, :feminine) { |config, _| config.fetch(:feminine) }
      f.set_rule(:de, :neuter)   { |config, _| config.fetch(:neuter) }

      f.add_macro(:de__gender) do |masc, fem, neut|
        { base: masc, rules: [:feminine, :neuter], feminine: fem, neuter: neut }
      end
    end

    # To get a correct translation in Russian
    # you need to set the proper ending for object by using `Винительный падеж - Кого? Что?`
    # "Создать Компанию(кого?) & Cоздать Сектор(что?)"
    # for `что?` we can use the resource name, for `кого?` - need to provide a separated key
    def ru__accuse(f)
      f.set_rule(:ru, :accuse) do |config, meta|
        meta.inject(config.fetch(:base)) { |str, (k, t)| str.gsub("%{#{k}}", t) }
      end

      f.add_macro(:ru__accuse) do |message|
        { base: message, rules: :accuse }
      end
    end
  end
end
