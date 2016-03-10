# Dos-T

[![Build Status](https://travis-ci.org/jalkoby/tt.svg?branch=master)](https://travis-ci.org/jalkoby/tt)
[![Gem Version](https://badge.fury.io/rb/t_t.svg)](https://badge.fury.io/rb/t_t)

Dos-T introduces a translation convention for a ruby web application (with a focus on the rails flow). The library is based on the next ideas:
- focus on a every day issues
- reduce amount of duplications inside translation files
- easy to use from day one & minimum to write (nobody likes to write a long and obvious method names)
- have a clear defaults

## Usage

Dos-T adds an extra helper method `tt` into your controllers, mailers & views. The best way to explain all features
is to look at [Cheatsheet](./cheatsheet.md). The below is shown a brief overview:

```Haml
# en:
#   actions:
#     base:
#       add: "Add a new %{r}"
#   attributes:
#     user:
#       name: "Name"
#       email: "Email"
#       role: "Role"
#   common:
#     actions: "Actions"
#     confirm: "Are you sure?"
#     edit: "Edit"
#     delete: "Delete"
#   enums:
#     user:
#       role:
#         a: "Admin"
#         g: "Guest"
#         m: "Manager"
#   models:
#     user:
#       one: "User"
#       other: "Users"

# app/views/users/index.haml
%h2= tt.rs :user

%table
  %thead
    %th= tt.attr :name
    %th= tt.attr :email
    %th= tt.attr :role
    %th= tt.c :actions

  %tbody
    - @users.each do |user|
      %tr
        %td= user.name
        %td= user.email
        %td= tt.enum :role, user.role
        %td
          = link_to tt.c(:edit), edit_user_path(user)
          = link_to tt.c(:delete), user_path(user), method: :delete, confirm: tt.c(:confirm)

= link_to tt.a(:add), new_user_path
```

The result will be the next:
```Haml
%h2 Users

%table
  %thead
    %th Name
    %th Email
    %th Role
    %th Actions

  %tbody
    - @users.each do |user|
      %tr
        %td= user.name
        %td= user.email
        %td= { 'a' => 'Admin', 'g' => 'Guest', 'm' => 'Manager' }[user.role]
        %td
          = link_to 'Edit', edit_user_path(user)
          = link_to 'Delete', user_path(user), method: :delete, confirm: 'Are you sure?'

= link_to 'Add a new user', new_user_path
```

## Additional features

#### [The action factory](./docs/action_factory.md)

#### [Synchronisation of a translation files](./docs/synchronisation.md)

## Setup

Just add `gem "t_t"` into your Gemfile and run `bundle`.

## Requirements

Dos-T is tested against Ruby 1.9.3+ & JRuby(1.9+ compatible). If your application uses Ruby on Rails the framework version should be 3.2+

## Changelog
- 1.2.0
  - Deprecate TT::Translator in favour of TT::Base & TT::Rails
  - Introduce a real-time watcher for [translation file synchronisation](./docs/synchronisation.md)
- 1.1.0:
  - Added [the action factory](./docs/action_factory.md)
  - Improve #attr, #r, #rs methods to make them more compatible with ActiveModel methods
  - Fix a documentation mismatching
- 1.0.1
  - fix the activerecord integration
