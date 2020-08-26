#!/bin/sh
cd ./assets/ && yarn deploy && cd -
iex -S mix phx.server

