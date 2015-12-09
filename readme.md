# Dos-T

Dos-T introduces a translation convention for a ruby web application (with a focus on the rails flow). The library is based on the next ideas:
- focus on a every day issues
- reduce amount of duplications inside translation files
- easy to use from day one & minimum to write (nobody likes to write a long and obvious method names)
- have a clear defaults

## Requirements

Dos-T is tested against Ruby 1.9.3+. If your application uses Ruby on Rails the framework version should be 3.2+

## Setup

Just add `gem "t_t"` into your Gemfile and run `bundle`.

## Usage

Dos-T adds an extra helper method `tt` into your controllers, mailers & views (for a "non-rails" case look at [Configuration](#configuration) section below).
The best way to show its features is to show a problem and how Dos-T solves it.

#### Common translations

#### Attributes

#### Enums

#### Resources

#### Actions

#### Custom lookups

## Configuration

If an application uses the default rails stack (ActionPack + ActiveRecord) there is nothing to change.
