module TT
  module BuiltinRules
    extend self

    # The indefinite article a (before a consonant sound) or an (before a vowel sound)
    # is used only with singular, countable nouns.
    def en__an(f)
      f.for(:en) do |l|
        l.rule(:an) { |_, a_meta, _| a_meta }
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
      f.for(:de) do |l|
        l.rule(:feminine) { |_, a_meta, _| a_meta }
        l.rule(:neuter)   { |_, a_meta, _| a_meta }
      end
    end

    # To get a correct translation in Russian
    # you need to set the proper ending for object by using `Винительный падеж - Кого? Что?`
    # "Создать Компанию(кого?) & Cоздать Сектор(что?)"
    # for `что?` we can use the resource name, for `кого?` - need to provide a separated key
    def ru__accuse(f)
      f.for(:ru) do |l|
        l.rule(:accuse) do |base, _, r_meta|
          r_meta.inject(base) { |str, (k, t)| str.gsub("%{#{k}}", t) }
        end
      end
    end
  end
end
