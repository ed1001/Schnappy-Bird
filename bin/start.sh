#!/bin/bash
brew list sdl2 >/dev/null 2>/dev/null || (echo "installing sdl2..." && brew install sdl2 >/dev/null)
if ! bundle check >/dev/null 2>/dev/null; then
  echo "installing dependencies..."
  bundle install >/dev/null
fi
ruby main.rb
