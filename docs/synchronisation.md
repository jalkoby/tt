# Synchronisation of a translation files

When you work on a multi-language application it's easy to add a key for one language and forget to add for another.
With Dos-T you have a file watcher which watches on the main locale files (`:en` translations by default). Like the asset
pipeline in development environment, you can enable the file synchronisation and on each page reload the gem will check
if an English translation was changed and apply changes for other languages. To enable it add the next in
`config/environments/development.rb`:

```ruby
# config/environments/development.rb

Rails.application.configure do
  # other configuration
  config.tt.sync = true
end
```

If your default translation is not English or the translation files located not in `config/locales` use the next
configuration:

```ruby
# config/environments/development.rb

Rails.application.configure do
  # a custom default locale
  config.tt.sync = :de
  # a custom default glob
  config.tt.sync = { locale: :fr, glob: 'other/locale/folder/**/*.yml' }
end
```

Also you can synchronise files without a page reload. Add the next line at the bottom `%rails_root%/Rakefile`:

```ruby
require 't_t/tasks'
```

You will have two additional rake tasks - `tt:s` (synchronises the translation files) and `tt:m` (prints the missing
translations for all languages)
