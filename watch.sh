#!/bin/bash
find . -name "*.rb" | entr -cr bundle exec rspec **/*_spec.rb
