FROM public.ecr.aws/lambda/ruby:2.7

RUN yum install -y amazon-linux-extras
RUN amazon-linux-extras install postgresql14

RUN yum install -y postgresql-devel gcc make

COPY Gemfile* ./

RUN bundle config set --local deployment 'true'
RUN bundle install

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

COPY . ./

CMD [ "handler.main" ]
