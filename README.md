[![Build Status](https://jenkins.sonata-nfv.eu/buildStatus/icon?job=tng-gtk-vnv/master)](https://jenkins.sonata-nfv.eu/job/tng-gtk-vnv/master)
[![Join the chat at https://gitter.im/5gtango/tango-schema](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/5gtango/tango-schema)

<p align="center"><img src="https://github.com/sonata-nfv/tng-api-gtw/wiki/images/sonata-5gtango-logo-500px.png" /></p>

# 5GTANGO Gatekeeper Verification and Validation platform-specific component
This is the 5GTANGO Gatekeeper Verification and Validation platform specific components repository, which closely follows its [SP Platform counterpart](https://github.com/sonata-nfv/tng-gtk-sp), complementing the [common component repository](https://github.com/sonata-nfv/tng-gtk-common) .

Please see [details on the overall 5GTANGO architecture here](https://5gtango.eu/project-outcomes/deliverables/2-uncategorised/31-d2-2-architecture-design.html). 

## Installing / Getting started

This component is implemented in [ruby](https://www.ruby-lang.org/en/) (we're using version **2.4.3**). 

### Installing from code

To have it up and running from code, please do the following:

```shell
$ git clone https://github.com/sonata-nfv/tng-gtk-vnv.git # Clone this repository
$ cd tng-gtk-vnv # Go to the newly created folder
$ bundle install # Install dependencies
$ bundle exec rspec spec # Execute tests
$ PORT=5000 bundle exec rackup # Run the server
```

Everything being fine, you'll have a server running on that session, on port `5000`. You can use it by using `curl`, like in:

```shell
$ curl <host name>:5000/
```

### Installing from the Docker container

## Developing
This section covers all the needs a developer has in order to be able to contribute to this project.

### Built With
We are using the following libraries (also referenced in the [`Gemfile`](https://github.com/sonata-nfv/tng-gtk-vnv/Gemfile) file) for development:

* `puma` (`3.11.0`), an application server;
* `rack` (`2.0.4`), a web-server interfacing library, on top of which `sinatra` has been built;
* `rake`(`12.3.0`), a dependencies management tool for ruby, similar to *make*;
* `sinatra` (`2.0.2`), a web framework for implementing efficient ruby APIs;
* `sinatra-contrib` (`2.0.2`), several add-ons to `sinatra`;
* `sinatra-cross_origin` (`0.4.0`), a *middleware* to `sinatra` that helps in managing the [`Cross Origin Resource Sharing (CORS)`](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS) problem;


The following *gems* (libraries) are used just for tests:
* `ci_reporter_rspec` (`1.0.0`), a library for helping in generating continuous integration (CI) test reports;
* `rack-test` (`0.8.2`), a helper testing framework for `rack`-based applications;
* `rspec` (`3.7.0`), a testing framework for ruby;
* `rubocop` (`0.52.0`), a library for white box tests; 
* `rubocop-checkstyle_formatter` (`0.4.0`), a helper library for `rubocop`;
* `webmock` (`3.1.1`), which alows *mocking* (i.e., faking) HTTP calls;

These libraries are installed/updated in the developer's machine when running the command (see above):

```shell
$ bundle install
```

### Prerequisites
We usually use [`rbenv`](https://github.com/rbenv/rbenv) as the ruby version manager, but others like [`rvm`](https://rvm.io/) may work as well.

### Setting up Dev
Developing this micro-service is easy.

Routes within the micro-service are defined in the [`config.ru`](https://github.com/sonata-nfv/tng-gtk-vnv/blob/master/config.ru) file, in the root directory. It has two sections:

* The `require` section, where all used libraries must be required (**Note:** `controllers` had to be required explicitly, while `services` do not, due to a bug we have found to happened in some of the environments);
* The `map` section, where this micro-service's routes are mapped to the controller responsible for it.

This new or updated route can then be mapped either into an existing conctroller or imply writing a new controller. This new or updated controller can use either existing or newly written services to fullfil it's role.

For further details on the micro-service's architecture please check the [documentation](https://github.com/sonata-nfv/tng-gtk-vnv/wiki/micro-service-architecture).

Changes to the repository can be requested using [this repository's issues](/issues) and [pull requests](/pulls) mechanisms.

### Building

No special steps are needed for building this component.

### Deploying / Publishing
give instructions on how to build and release a new version
In case there's some step you have to take that publishes this project to a
server, this is the right time to state it.

```shell
packagemanager deploy your-project -s server.com -u username -p password
```

And again you'd need to tell what the previous code actually does.

## Versioning

The most up-to-date version is v4. For the versions available, see the [link to tags on this repository](/tags).

## Configuration
The configuration of the micro-service is done through just two environment variables, defined in the [Dockerfile](https://github.com/sonata-nfv/tng-gtk-vnv/blob/master/Dockerfile):

* `CATALOGUE_URL`, which should define the Catalogue's URL, where test descriptors are fetched from;
* `REPOSITORY_URL`, which should define the Repository's URL, where test plans and test results are fetched from;

## Tests
Unit tests are defined for both `controllers` and `services`, in the `/spec` folder. Since we use `rspec` as the test library, we configure tests in the [`spec_helper.rb`](https://github.com/sonata-nfv/tng-gtk-vnv/blob/master/spec/spec_helper.rb) file, also in the `/spec` folder.

Wider scope (integration and functional) tests involving this micro-service are defined in [`tng-tests`](https://github.com/sonata-nfv/tng-tests).

## Style guide
Our style guide is really simple:

1. We try to follow a [Clean Code](https://www.amazon.com/Clean-Code-Handbook-Software-Craftsmanship/dp/0132350882) philosophy in as much as possible, i.e., classes and methods should do one thing only, have the least number of parameters possible, etc.;
1. we use two spaces for identation.

## Api Reference

We have specified this micro-service's API in a [swagger](https://github.com/sonata-nfv/tng-gtk-vnv/blob/master/doc/swagger.json)-formated file. Please check it there.

## Licensing

This 5GTANGO component is published under Apache 2.0 license. Please see the [LICENSE](https://github.com/sonata-nfv/tng-gtk-vnv/blob/master/LICENSE) file for more details.
