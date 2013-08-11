OpenSauna
=========

Filter your social streams. Find the fresh links. Share with your readers.

Sauna is a social news aggregator and curation tool.

It scans your Twitter stream and RSS feeds looking for links.
And it automatically extracts the important text and images from each link.
Over time, Sauna learns what types of links you like, and hides the ones you don't.

Sauna also allows you to curate the links you like with your friends, fans, or readers. Create a customized linkstream site (like [bruno.sauna.io](http://bruno.sauna.io) ). Built-in social sharing on Twitter and Facebook, with scheduled posting.


Installation
------------

Sauna runs on Ruby 1.9.x with Rails 3.2.

Prior to installing, you'll need [mongodb](http://www.mongodb.org/) and [Redis](http://redis.io/) installed on your machine.

1. Clone the repository
2. Copy `sample.env` to `.env`. Don't commit `.env` to git.
3. Fill in the required values in your `.env` file.
4. `bundle install`
5. `rake db:migrate`
6. `bundle exec foreman start -f Procfile.local`. (The app should now be running on `localhost:5000`)


Deploying to Heroku
-------------------

Required Heroku addons:

- rediscloud
- mongohq
- memcachier
- sendgrid

To Deploy to heroku:

1. Create a new Heroku app
2. Set the required variables from your local `.env` file on Heroku (using `heroku config:set`). You can also use the [heroku-config](https://github.com/ddollar/heroku-config) plugin to sync local and remote config vars.
3. Provision the required addons (see above)
4. Push your app to Heroku (`git push heroku`) and migrate (`heroku run rake db:migrate`)
