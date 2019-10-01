PubSub Adapter Example - Kisi Test Task
===============

## Running local server

### 1- Installing Ruby

- Clone the repository by running `git clone git@github.com:NicoBuchhalter/pubsub-adapter.git`
- Go to the project root by running `cd pubsub-adapter`
- Download and install [Rbenv](https://github.com/rbenv/rbenv#basic-github-checkout).
- Download and install [Ruby-Build](https://github.com/rbenv/ruby-build#installing-as-an-rbenv-plugin-recommended).
- Install the appropriate Ruby version by running `rbenv install [version]` where `version` is the one located in [.ruby-version](.ruby-version)

### 2- Installing Rails gems

- Install [Bundler](http://bundler.io/).

```bash
  gem install bundler
  rbenv rehash
```

- Install all the gems included in the project.

```bash
  bundle install
```

### 3- Database Setup

Run in terminal:

```bash
	psql postgres
  CREATE ROLE "pubsub_adapter" LOGIN CREATEDB PASSWORD 'pubsub_adapter';
```

Log out from postgres and run:

```bash
  bundle exec rake db:create db:migrate
```

Your server is ready to run. You can do this by executing `rails server` and going to [http://localhost:3000](http://localhost:3000). Happy coding!




## About

This project is maintained by [Nicolas Buchhalter](https://github.com/NicoBuchhalter)
