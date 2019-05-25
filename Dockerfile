FROM ruby:2.6.3-slim

RUN mkdir /usr/src/people-in-space
WORKDIR /usr/src/people-in-space

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

CMD ["ruby", "app.rb"]
