import based.{
  type DB, type Query, type Returned, type Value, DB, Query, Returned,
}
import gleam/dynamic
import gleam/list
import gleam/option.{Some}
import gleam/pgo.{type Connection}
import gleam/result

pub type Config {
  Config(
    host: String,
    port: Int,
    database: String,
    username: String,
    password: String,
  )
}

pub fn with_connection(
  config: Config,
  callback: fn(DB(a, Connection)) -> t,
) -> t {
  let conn = connect(config)

  let result =
    DB(conn: conn, execute: execute)
    |> callback

  pgo.disconnect(conn)

  result
}

fn execute(query: Query(a), conn: Connection) -> Result(Returned(a), Nil) {
  let Query(sql, args, maybe_decoder) = query

  let values = to_pgo_values(args)

  let execution = case maybe_decoder {
    Some(decoder) -> {
      pgo.execute(sql, conn, values, decoder)
      |> result.map(fn(ret) { Returned(ret.count, ret.rows) })
    }
    _ -> {
      pgo.execute(sql, conn, values, dynamic.dynamic)
      |> result.replace(Returned(0, []))
    }
  }

  execution
  |> result.replace_error(Nil)
}

fn connect(config: Config) -> Connection {
  let Config(host, port, database, user, password) = config

  let conn =
    pgo.connect(
      pgo.Config(
        ..pgo.default_config(),
        host: host,
        port: port,
        database: database,
        user: user,
        password: Some(password),
        pool_size: 5,
      ),
    )

  conn
}

fn to_pgo_values(values: List(Value)) -> List(pgo.Value) {
  values
  |> list.map(fn(value) {
    case value {
      based.String(val) -> pgo.text(val)
      based.Int(val) -> pgo.int(val)
      based.Float(val) -> pgo.float(val)
      based.Bool(val) -> pgo.bool(val)
      based.Null -> pgo.null()
    }
  })
}
