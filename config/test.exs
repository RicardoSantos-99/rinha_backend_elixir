import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
# config :load_test, LoadTest.Repo,
#   username: "postgres",
#   password: "postgres",
#   hostname: "localhost",
#   database: "load_test_test#{System.get_env("MIX_TEST_PARTITION")}",
#   pool_size: 10
