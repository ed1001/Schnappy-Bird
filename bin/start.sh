#!/bin/bash

brew list sdl2 || brew install sdl2
if ! bundle check; then
  bundle install
fi
ruby main.rb
