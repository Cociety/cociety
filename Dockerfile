# Dockerfile
ARG BUNDLE_WITHOUT=''
ARG FOREMAN_FILE=''
ARG FUNCTION_DIR="/app"
ARG RUBY_VERSION

FROM public.ecr.aws/amazonlinux/amazonlinux:2023 AS base
# don't install docs with dnf packages
ENV RPMTRANS_FLAG_NODOCS 1
RUN dnf update -y && dnf clean all

#####################
#### Ruby
#### build specific version of ruby to match our Gemfile deps
#####################
FROM base AS ruby-build
ARG RUBY_VERSION
RUN test -n ${RUBY_VERSION:?}
WORKDIR /tmp
# required for new ruby 3.2.0 compiler https://www.ruby-lang.org/en/news/2022/12/25/ruby-3-2-0-released/ 
#   libffi-devel https://sourceware.org/libffi/
#   libyaml-devel https://github.com/yaml/libyaml
RUN dnf install -y tar gzip gcc-c++ libffi-devel libyaml-devel openssl-devel zlib-devel \
  && dnf clean all \
  && RUBY_MAJOR_MINOR_VERSION=${RUBY_VERSION%.*} \
  && curl --remote-name --location https://cache.ruby-lang.org/pub/ruby/$RUBY_MAJOR_MINOR_VERSION/ruby-${RUBY_VERSION}.tar.gz \
  && tar -xf ruby-${RUBY_VERSION}.tar.gz \
  && cd ruby-${RUBY_VERSION} \
  && mkdir /ruby \
  && ./configure --disable-install-doc --prefix=/ruby \
  && make -j4 \
  && make btest -j4 \
  && make install
FROM base AS ruby
COPY --from=ruby-build /ruby /ruby
ENV PATH "${PATH}:/ruby/bin"

#####################
#### Build Image
#### install/compile ruby gems
#####################
FROM ruby AS build-image-dev
ARG BUNDLE_WITHOUT
ARG FOREMAN_FILE
ARG FUNCTION_DIR
WORKDIR ${FUNCTION_DIR}
# Install OS packages
# libpq-devel zlib-devel gcc-c++: compiling pq gem
# git: for bundler to install gems from git
RUN dnf install -y libpq-devel zlib-devel gcc-c++ git
COPY Gemfile ${FUNCTION_DIR}/
COPY Gemfile.lock ${FUNCTION_DIR}
COPY .ruby-version ${FUNCTION_DIR}
ENV BUNDLE_WITHOUT ${BUNDLE_WITHOUT}
RUN bundle config --global frozen 1 \
  && bundle install --no-cache

#####################
#### Dev Runtime Image
#### copy the rest of the app over and ruby gems
#####################
FROM ruby AS runtime-image
ARG BUNDLE_WITHOUT
ARG FOREMAN_FILE
ARG FUNCTION_DIR
ENV BUNDLE_WITHOUT ${BUNDLE_WITHOUT}
ENV FOREMAN_FILE ${FOREMAN_FILE}
# Install OS packages
# create "cociety" user. this is the user our app will run as
# shadow-utils: useradd command
# libpq-devel: libpq.so for postgres gem
RUN gem install foreman \
  && dnf install -y shadow-utils libpq-devel \
  && dnf clean all \
  && useradd --no-log-init --system --create-home --user-group --uid 900 cociety
COPY --from=build-image-dev /ruby /ruby
COPY --from=build-image-dev --chown=cociety:cociety ${FUNCTION_DIR} ${FUNCTION_DIR}
COPY --chown=cociety:cociety . ${FUNCTION_DIR}
WORKDIR ${FUNCTION_DIR}
USER cociety
CMD ["./bin/start"]
