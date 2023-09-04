FROM elixir:1.14-alpine
RUN mix local.hex --force && \
  mix local.rebar --force
WORKDIR /app
COPY mix.exs mix.lock ./
RUN mix deps.get
COPY . .
RUN mix compile
COPY entrypoint.sh /app/entrypoint.sh
EXPOSE 4000
ENTRYPOINT ["/app/entrypoint.sh"]
