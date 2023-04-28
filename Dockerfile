FROM ruby:3.2.0-alpine3.17

ENV HOME /root
ENV WORKDIR $HOME/app
ENV GEM_HOME="/usr/local/bundle"
ENV PATH $GEM_HOME/bin:$GEM_HOME/gems/bin:$PATH

RUN apk update --quiet &&\
 apk add --no-cache --quiet\
 build-base\
 bash\
 git\
 less\
 linux-headers\
 openssh \
 tzdata

RUN mkdir -p $WORKDIR

COPY . $WORKDIR

WORKDIR $WORKDIR

RUN $WORKDIR/bin/setup

CMD ["bin", "console"]
