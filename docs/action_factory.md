# Overview

Dos-T provides the factory to generate 'action'-translations in a few lines.

```ruby
# config/locales/actions.rb

TT.define_actions(:en, :de) do |f|
  f.add :see_all, en: "See all %{rs}", de: "Siehe alle %{RS}"
end
```

From the example above you've understood the basic DSL's api, but started wondering what's a point of it due to fill
a yml file will be faster and easier. The reason comes when you will face a grammar rule which requires a different
texts. The most popular case is an English "a/an" rule. For example, an application has the next translation:

```ruby
# config/locales/actions.en.yml

en:
  actions:
    base:
      choose: "Please, choose a %{r}"
    agent:
      choose: "Please, choose an %{r}"
    article:
      choose: "Please, choose an %{r}"
    occupation:
      choose: "Please, choose an %{r}"
      #...
```

This grammar rule forces us to create n * m keys where:
- n is a count of actions with the rule
- m is a count of models which uses "an"
A plain translation file becomes large what makes the its maintenance hard. With Dos-T it's easy due to you
can teach DSL some grammar and it will generates all translation for you:

```ruby
# config/locales/actions.rb

TT.define_actions(:en) do |f|
  f.for(:en) do |l|
    # defines `a/an` rule for English where:
    # base   - a base action translation or a result of the previous rule processing
    # a_meta - a action-related metadata (specified on adding an action)
    # r_meta - a resource-related metadata (specified on marking a resource to use a rule)
    l.rule(:an) { |base, a_meta, r_meta| a_meta }

    # registers a resources which should use the rule
    l.use_rule_for(:an, :agent, :article, occupation: "a useless resource (`occupation`) metadata for the `an` rule")
  end

  # "Please, choose an %{r}" is an action metadata for the rule
  f.add :choose, en: f.with_rules("Please, choose a %{r}", an: "Please, choose an %{r}")
  f.add :create, en: f.with_rules("Create a %{r}", an: "Create an %{r}")
  f.add :delete_all, en: "Do you want to delete all %{rs}"
end
```

Here an another example with a more complex grammar rules:

```ruby
# de:
#   models:
#     article:
#       one: "Artikel"
#       other: "Artikel"
#     child:
#       one: "Kind"
#       other: "Kinder"
#     comment:
#       one: "Komment"
#       other: "Komments"
#     list:
#       one: "Liste"
#       other: "Listen"
#     log:
#       one: "Protokoll"
#       other: "Protokolle"
#     person:
#       one: "Person"
#       other: "Personen"
# ru:
#   models:
#     article:
#       one: "Статья"
#       other: "Статьи"
#     child:
#       one: "Ребенок"
#       other: "Дети"
#     comment:
#       one: "Комментарий"
#       other: "Комментарии"
#     list:
#       one: "Список"
#       other: "Списки"
#     log:
#       one: "Запись"
#       other: "Записи"
#     person:
#       one: "Персона"
#       other: "Персоны"

TT.define_actions(:de, :ru) do |f|
  f.for(:de) do |l|
    # German articles are sensitive to gender
    l.rule(:feminine) { |_, a_meta, _| a_meta }
    l.rule(:neuter)   { |_, a_meta, _| a_meta }

    l.use_rule_for(:feminine, :list, :person)
    l.use_rule_for(:neuter, :child, :log)
  end

  f.for(:ru) do |l|
    # Russian language has 6 noun cases(падежи)
    # for passive voice Accuse case(Винительный падеж - кого? что?) is used
    l.rule(:accuse) { |base, _, r_meta| r_meta.inject(base) { |str, (k, v)| str.gsub("%{#{ k }}", v) } }
    l.use_rule_for :accuse,
      article: { r: "статью", R: "Статью" }, # the plural version is not changing
      child: { r: "ребенка", rs: "детей", R: "Ребенка", RS: "Детей" },
      person: { r: "персону", rs: "персон", R: "Персону", RS: "Персон" }
  end

  f.add :add,
    de: f.with_rules("Neuen %{R} hinzufügen", feminine: "Neue %{R} hinzufügen", neuter: "Neues %{R} hinzufügen"),
    ru: f.with_rules("Добавить %{r}", :accuse)

  f.add :edit,
    de: f.with_rules("Den %{R} bearbeiten", feminine: "Die %{R} bearbeiten", neuter: "Das %{R} bearbeiten"),
    ru: f.with_rules("Изменить %{r}", :accuse)

  f.add :delete_all,
    de: "Alle %{RS} löschen"
    ru: f.with_rules("Удалить %{rs}", :accuse)
end
```

The generated list of actions is present in the following table:

||add-de|edit-de|delete-de|add-ru|edit-ru|delete-ru|
|---|---|---|---|---|---|---|
|article|Neuen Artikel hinzufügen|Den Artikel bearbeiten|Alle Artikel löschen|Добавить статью|Изменить статью|Удалить статьи|
|child|Neues Kind hinzufügen|Das Kind bearbeiten|Alle Kinder löschen|Добавить ребенка|Изменить ребенка|Удалить детей|
|comment|Neuen Komment hinzufügen|Den Komment bearbeiten|Alle Komments löschen|Добавить комментарий|Изменить комментарий|Удалить комментарии|
|list|Neue Liste hinzufügen|Die Liste bearbeiten|Alle Listen löschen|Добавить список|Изменить список|Удалить списки|
|log|Neues Protokoll hinzufügen|Das Protokoll bearbeiten|Alle Protokolle löschen|Добавить запись|Изменить запись|Удалить записи|
|person|Neue Person hinzufügen|Die Person bearbeiten|Alle Personen löschen|Добавить персону|Изменить персону|Удалить персону|

With the factory you get a flexibility in resource renaming - just change of a few lines. A possibility to make a typo
in a similar translations down to zero. All shown rules a included in the factory, but not activated.
To do it, do the next:

```ruby
TT.define_actions(:en, :de, :ru) do |f|
  # the naming convention is similar to BEM
  f.activate_rules(:en__an, :de__gender, :ru__accuse)
end
```

If you would like to add another grammar rule feel free to make a pull request.

## Adding an exceptions

Dos-T was built to maximize the usage of patterns in translations. It helps to avoid typos and long files, but texts
become more technical. In the previous section, you probably noticed that translations like "Das Kind bearbeiten"
(change the child) or "Изменить персону"(change the person) better to replace by more human oriented
"Das Kind-Profile bearbeiten" (change the child's profile) and "Изменить биографию персоны" (change the person's bio).
For those situations the library allows to specify an exceptions:

```ruby
TT.define_actions(:de, :ru) do |f|
  # declaration of rules and actions

  f.add_exception(:child, ru: { edit: "Das Kind-Profile bearbeiten" }, de: { edit: "Изменить профиль ребенка" })
end
```
