FROM bitwalker/alpine-elixir-phoenix:latest

WORKDIR /app

COPY mix.exs .
COPY mix.lock .

RUN mix deps.get

COPY . .

RUN mix compile
