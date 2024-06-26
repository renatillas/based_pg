# based_pg

[![Package Version](https://img.shields.io/hexpm/v/based_pg)](https://hex.pm/packages/based_pg)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/based_pg/)

## WIP

This package should be used with [`based`](https://github.com/stndrs/based)

```sh
gleam add based_pg
```
```gleam
import based
import based_pg

const sql = "DELETE FROM users WHERE id=$1;"

pub fn main() {
  let config = load_config()

  use db <- based.register(based_pg.with_connection, config)

  based.new_query(sql)
  |> based.with_args([based.int(1)])
  |> based.exec(db)
}
```

Further documentation can be found at <https://hexdocs.pm/based_pg>.

## Development

```sh
docker-compose up # Starts postgres and adminer in docker containers. Required for running tests
gleam run         # Run the project
gleam test        # Run the tests
gleam shell       # Run an Erlang shell
```
