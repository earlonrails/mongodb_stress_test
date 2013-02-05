mongodb_stress_test
===================

Stress test mongodb

To run with jruby

    export JRUBY_OPTS=--1.9
    bundle
    cp database.yml.sample database.yml
    ruby mongo_ruby_driver_test.rb
