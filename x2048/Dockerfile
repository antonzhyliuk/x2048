FROM bitwalker/alpine-elixir-phoenix:latest

WORKDIR /app

COPY mix.exs .
COPY mix.lock .

RUN mix deps.get && mix deps.compile

COPY . .

RUN mix compile
