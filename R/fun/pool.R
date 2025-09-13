db_host <- Sys.getenv("db_host")
db_port <- Sys.getenv("db_port")
db_name <- Sys.getenv("db_dbname")
db_user <- Sys.getenv("db_user")
db_password <- Sys.getenv("db_password")
db_table_cred <- Sys.getenv("db_table_cred")
db_table_patients <- Sys.getenv("db_table_patients")

pool <- dbPool(
  drv = MariaDB(),
  host = db_host,
  port = db_port,
  dbname = db_name,
  user = db_user,
  password = db_password,
  maxSize = 10
)

onStop(function() {
  poolClose(pool)
})

patients_tbl <- tbl(pool, db_table_patients)