FROM ruby:2.4
VOLUME /opt/tt
VOLUME /root/.ssh
WORKDIR /opt/tt
RUN gem install bundler
CMD bash
