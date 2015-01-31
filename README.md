## About

The main goal of Dos-T is reducing time on supporting a multi-language web application by providing a few conventions and a short method names. We believe that it's a primary reason which slows down development. Cause it's boring to write a long path like `t('namespace.controller_name.action_name.section.key')`. Let's better spend time on something more interesting.

So what's makes Dos-T such a good tool(on our opinion):

### Global commons

`tt.c` - in every application there are some elements which are present in every page. For example, if a page has "delete some resource" button/link, it's good to have a confirmation message which tells a user "Are you sure?". At this point you add a key for this page, for example, in "admin.users.index.confirm" path and on page call `t('.confirm')`. Rails is smart enough to prepend a full path to ".confirm" key. But then you need to add confirmation on `admin/users#show` and you, probably, will not duplicate it for "show" page and move it into a common section. After that the translation helper can't help us and we need to provide a full path – `t('common.confirm')`. We reduce a duplication of translation keys, but have to write a long methods. Well, as always, programming is a compromise. But not this time, with Dos-T you can have both – just call `tt.c(:confirm)`. At first it will look into a section's common node(description of a section see below). If Dos-T doesn't find a translation there it will look into the global *common* >>> *common.confirm*. You, probably, are interested what's a section. By a section Dos-T means I18n path of the current controller(mailer). Let's review the previous example. If our current controller is `Admin::UsersController`, the section is *admin.users*. That's why if we want for deleting users a special confirmation we just add "admin.users.common.confirmation" key and it's done.

`tt.f` - the global `common` section could fast become a huge and you will add some namespaces into it. We prefer a facts over a supposes, but there is a 100% assumption that you will have this subsection - `common.form` with `save`, `edit`, `delete` and etc. Cause we don't know any application which doesn't have that. That's why Dos-T has another method `tt.f` which like `tt.c` -  first looks into the current section(*controller_path.form*) and fallbacks into the global("form").

And finally, Dos-T allows you to define a new "common-used" sections. For example, for breadcrumbs. Just place "tt.rb" file in config/initializations that:

```ruby
ActiveSupport.on_load(:tt) do
  shortcut(:crumbs, :breadcrumbs) # => tt.crumbs(:index) which looks into `breadcrumbs` sections
  shortcut(:tip, :tooltips) # => tt.tip(:readonly) which looks into `tooltips` sections
end
```

### Section's commons

`tt` - let's back to our example with user management pages. Our clients decided to add a gravatar support. To make this feature more clear to admins we should put a tooltip with a description on index and show page, next to label "Gravatar". It brings a problem where to put a translation. If we put it into 'admin.users.index' we can use `t('.gravatar')` on index page, but have to use `t('admin.users.index.gravatar')` on show page and vice versa. And there Dos-T helps us. Just put `tt(:gravatar)` and put the tip into 'admin.users.common'. First it will act like a `t('.gravatar')` and fallbacks into section's common. And yes, `tt(:key)` is one symbol shorter than t('.key') – you can't avoid `t` in a favour to `tt`.

### Resource translations

`tt.attr` - we think every developer enjoys how `form_for` easily translates column's label - `f.label :column_name` - and Rails will magically translate it. But then we have to use an ugly way(`User.human_attribute_name(:column_name)`) to reuse these translations on index and show pages. It's become boring to type again and again this `human_attribute_name`. Dos-T provides a shortcut `tt.attr :column_name, User`. But it could be a shorter, cause if you call it in `UsersController` in 9/10 you closely work with User model. That's why, a second argument in `#attr` method is an optional and default value is a context class. A context class is computed on a controller name. If it's `users_controller`, Dos-T expects for a User model presence. If it's `Admin::UsersController` a context class is still User model.

### Other useful methods

* `tt.record([context_class])` – returns the singular human name of a model class(alias - resource)
* `tt.records([context_class])` – returns the plural human name of a model class(alias – resources)
* `tt.no_records([context_class])` – returns the zero form human name of a model class(alias – no_resources)
* `tt.enum(attr_name, variant, [context_class])` – returns a human variant name of an attribute. It looks for human  attribute name of "%attr_name%_%variant%"

### Example of page

```haml
/ users#index
= link_to tt.c(:new_resource, model: tt.resource), new_user_path, "data-tooltip" => tt(:new_user_tip)

%table
  %tr
    %th= tt.attr :name
    %th= tt.attr :email
    %th= tt.attr :phone
    %th= tt.attr :role
    %th= tt.c :actions
  - @users.each do |user|
    %tr
      %td= user.name
      %td= user.email
      %td= user.phone
      %td= tt.enum :role, user.role
      %td
        = link_to tt.f(:edit), edit_user_path(user)
        = link_to tt.f(:delete), user_path(user), method: :delete, confirm: tt.c(:confirm)

/ tt.c looks in 'users.common', 'common'
/ tt.f looks in 'users.form', 'form'
/ tt looks in 'users.index', 'users.common'
/ tt.attr - calls human_attribute_name on User
/ tt.enum - calls human_attribute_name on User with role_%value%
/ tt.resource - User.model_name.human(count: 1)
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 't_t'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install t_t


## Contributing

1. Fork it ( https://github.com/jalkoby/t_t/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
