FROM quay.io/barkerja/trusty_ruby_2_2

RUN echo "deb http://download.rethinkdb.com/apt trusty main" | sudo tee /etc/apt/sources.list.d/rethinkdb.list
RUN sudo apt-get update && apt-get install -y wget
RUN wget -O- http://download.rethinkdb.com/apt/pubkey.gpg | sudo apt-key add -
RUN sudo apt-get install -y --force-yes rethinkdb

RUN wget https://s3.amazonaws.com/bitly-downloads/nsq/nsq-0.3.6.linux-amd64.go1.5.1.tar.gz && tar xzvf nsq-0.3.6.linux-amd64.go1.5.1.tar.gz
RUN mv nsq-0.3.6.linux-amd64.go1.5.1/bin/* /usr/local/bin && rm -rf nsq-0.3.6.linux-amd64.go1.5.1*

RUN gem update --system
RUN gem install bundler

ADD . /app
WORKDIR /app
RUN bundle install

EXPOSE 5000
CMD ["foreman", "start"]
