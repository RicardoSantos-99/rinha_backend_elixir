FROM elixir:1.14-alpine
RUN mix local.hex --force && \
  mix local.rebar --force
WORKDIR /app
COPY mix.exs mix.lock ./
RUN mix deps.get
COPY . .
RUN mix compile
EXPOSE 4000
CMD ["mix", "run", "--no-halt"]

