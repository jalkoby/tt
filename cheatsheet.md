# Dos-T cheatsheet

## Commons

The **widely used words** across the application such as "Back", "Cancel", "Save" are the prime candidates to put in **common**:

```ruby
# en:
#   common:
#     back: "Back"

tt.c :back # => "Back"
```

Time to time there is a need to **override commons** for a section (controller in rails environment). To do so, just **add 'common' sub-key** in the section translations:

```ruby
# en:
#   common:
#     copy: "Copy"
#   users:
#     common:
#       copy: "Duplicate"

# app/views/documents/index.haml
= tt.c :copy # => "Copy"

# app/views/users/index.haml
= tt.c :copy # => "Duplicate"
```

## Relative translation

Every rails developer is familiar with helper method **#t** which has a magic trick with a dot at the beginning. The
plug-in has an alternative for it **tt.t(key)** or **tt(key)** which is a little bit simple, faster and has a default
fallback. Let's look at a common scenario:

```ruby
# en:
#   blogs:
#     new:
#       help: "The content should not contain a markdown"

# app/views/blogs/new.haml
= t('.help')

# with the gem
= tt(:help)
```

At the first look there is not a big difference. Until you need to use a same translation in a few controller actions:
```ruby
# en:
#   blogs:
#     new:
#       help: "The content should not contain a markdown"

# app/views/blogs/new.haml
= t('.help')

# app/views/blogs/edit.haml
= t('blogs.new.help')
```

With Dos-T it's not a case, just put a common translation into `common` sub-key of a controller's translation namespace:

```ruby
# en:
#   blogs:
#     common:
#       help: "The content should not contain a markdown"

# app/views/blogs/new.haml
= tt(:help)

# app/views/blogs/edit.haml
= tt(:help)
```

## Attributes

You probably know that `active_model` based classes have handy method **#human_attribute_name**. The main problems with it are the long method name and `humanization` on translation missing. The gem provides an **almost compatible equivalent #attr**.

```ruby
# en:
#   attributes:
#     base:
#       email: "Email"
#     user:
#       email: "Login / Email"

# app/views/subscriptions/index.haml
# a base translation
tt.attr :email, :subscription # => "Email"

# app/views/users/index.haml
# a specific translation
tt.attr :email, :user # => "Login / Email"

# with 'current model reflection' (preferred): UsersController => :user
tt.attr :email # => "Login / Email"
```

`#attr` also looks into orm translations paths. If you place translations according to `active_record`:

```ruby
# en:
#   activerecord:
#     attributes:
#       user:
#         email: "Login / Email"
#   attributes:
#     user: "Email"

tt.c :email, :user # => "Login / Email"
```
For other `active_model` based orms please specify configuration in an initializator:

```ruby
# en:
#   mongoid:
#     attributes:
#       user:
#         email: "Login / Email"
#   attributes:
#     user: "Email"

# app/config/tt.rb
TT.config(prefix: :mongoid)
```

## Resources

There is another translation hard-to-use feature which are present in `active_model` - **.model_name.human**. It
returns a translated human name of a model. To get a plural version you should also provide the `count: 10` parameter.
With Dos-T you get two short methods which do the job - **#r** & **#rs** (human resource and resources):

```ruby
# en:
#   models:
#     user:
#       one: "User"
#       other: "Users"
#       zero: "Userz"

tt.r :user      # => "User"
tt.rs :user, 20 # => "Users"
tt.rs :user, 0  # => "Userz"

# app/views/users/show.haml
#  with 'current model reflection' and the default value (10)
tt.rs           # => "Users"
```

## Enums

Quite often a developer needs to provide a **human translation for the variants** of an enum attribute. Dos-T provides
a handy method **#enum**:

```ruby
# en:
#   enums:
#     base:
#       role:
#         a: "Admin"
#         u: "User"
#     subscription:
#       role:
#         c: "Subscriber"

# app/views/subscriptions/index.haml
tt.enum :role, :a, :user         # => "Admin"
tt.enum :role, :c, :subscription # => "Subscriber"

# with 'current model reflection'
tt.enum :role, :u                # => "User"
```
You can put enum translations inside orm translation namespace as with `#attr` method.

## Errors

Errors are an essential part of any application. Within `active_model` orms you have **errors.full_messages**
& **errors.full_messages_for** which are fine only for a few use-cases. To make it easier the gem has an
**almost compatible equivalent #e**:

```ruby
# en:
#   errors:
#     base:
#       blank: "is blank"
#       greater_than: "must be greater than %{count}"
#       password:
#         blank: "is empty"
#     user:
#       password:
#         blank: "is invalid"

# app/views/users/index.haml
tt.e(:password, :blank, :user)                  # => "is invalid"
tt.e(:password, :greater_than, :user, count: 4) # => "must be greater than 4"

# with 'current model reflection'
tt.e(:password, :blank)                         # => "is invalid"
tt.e(:password, :greater_than, count: 4)        # => "must be greater than 4"

tt.e(:password, :blank, :client)                # => "is empty"
tt.e(:name, :blank, :client)                    # => "is blank"
```

## Actions

The unique feature of the gem which helps to reduce amount of duplications in flash messages, warnings and other messages
related to notification about some action on resources. To get the idea let's look into a typical rails controller:

```ruby
def create
  if user.save
    flash[:notice] = "The user has been created"
  end
  # other code
end

def update
  if user.save
    flash[:notice] = "The user has been updated"
  end
  # other code
end

def destroy
  user.destroy
  flash[:notice] = "The user has been deleted"
  # other code
end
```

For one controller the situation looks fine, but a typical application has at least 10 to 15 controllers. As the result
these translations creates a long translation files with many duplications. To solve the problem method **#a**
comes on the scene:

```ruby
# en:
#   actions:
#     base:
#       create: "The %{r} has been created"
#       update: "The %{r} has been updated"
#       delete: "The %{r} has been deleted"
#   models:
#     user:
#       one: "User"
#       other: "Users"

def create
  if user.save
    flash[:notice] = tt.a(:create, :user) # => "The user has been created"
  end
  # other code
end

def update
  if user.save
    flash[:notice] = tt.a(:update, :user) # => "The user has been updated"
  end
  # other code
end

def destroy
  user.destroy
  # with 'current model reflection'
  flash[:notice] = tt.a(:delete)         # => "The user has been deleted"
  # other code
end
```

As you can see in translation you define a base translation for an action which expected at least the next variables:
- RS  - `tt.rs`
- R   - `tt.r`
- rs  - `tt.rs.downcase`
- r   - `tt.r.downcase`

If for some action one of the models should have a custom translation (a business logic, a grammar rule of a language)
just add a model name key in a action translations:

```ruby
# en:
#   actions:
#     base:
#       create: "The %{r} has been created"
#     photo:
#       create: "The %{r} has been uploaded"

tt.a(:create, :user)  # => "The user has been created"
tt.a(:create, :photo) # => "The photo has been uploaded"
```
Take a look at [examples folder](./examples/) for a more examples.

## Custom shortcuts

As an application grows `common` grows too. To avoid a long list of common words it's good to group them by group.
For example, words related to a user tips is good to place into `tips`, words related to forms into `forms`. To do it
the gem provides a configuration block:

```ruby
# app/config/tt.rb
TT.config do
  lookup_key_method :tip, :tips
  lookup_key_method :f, :forms
end
```
As the result your `tt` variable will have `#tip` & `#f` methods which behave like `#c`.

## Advanced usage & configuration

Dos-T was designed to be easy-as-possible for the default rails stack, but if you don't have it or don't have rails at
all it's not a problem. Let's look at a possible cases:

### You don't have ActionPack or want to use Dos-T outside the views

`tt` is an instance of `TT::Translator`. To create a variable you need `namespace` & `section` (optional) keys. In the rails
environment it's `controller_path` and `action_name`.

```ruby
class EmailApp < Sinatra::Base
  before do
    @tt = TT::Translator.new('emails')
  end

  post '/' do
    # processing
    { status: tt.t(:handled) }.to_json # { status: I18n.t('emails.handled') }.to_json
  end
end

class EmailSender
  attr_reader :tt

  def initialize
    @tt = TT::Translator.new('services/email_sender')
  end

  def work
    each_letter do |letter|
      send_mail(subject: tt.a(:confirm, :email, user: letter.user_name))
      # ...
    end
  end
end
```

### You use different to ActiveRecord orm

Just specify an orm i18n scope:
```ruby
# app/config/tt.rb
TT.config(prefix: :mongoid)
```
