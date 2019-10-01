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


### PubSub Adapter setup

- Generate your JSON keyfile for your service account following [this instructions](https://cloud.google.com/iam/docs/creating-managing-service-account-keys)
- Create the file `/config/google_cloud.keyfile.json` and load the created json in it.
- Lookup your project in [this link](https://console.cloud.google.com/apis/api/pubsub.googleapis.com/) and enable your API usage.
- Edit your credentials by running in console: 

```bash
	EDITOR=vim rails credentials:edit
```

### Start PubSub Worker

```bash
	rake pubsub
```

### Watch Metrics

In rails console: 

```
	JobMetric.get_metrics
```

By API:

Start server (let's assume it runs in localhost:3000)

```
	GET localhost:3000/job_metrics
```


Change the topic and subscription keys for your own.

## About

This project is maintained by [Nicolas Buchhalter](https://github.com/NicoBuchhalter)
