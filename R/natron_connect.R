# Function for creating database connection
# creating db connection object

natron_connect <- function(username, database = "natron_sandbox") {

pg_drv <- "PostgreSQL"
pg_db <- "natron_sandbox"
pg_host <- "vm-srv-zootron.vm.ntnu.no"

pg_db <- database

con<-dbConnect(pg_drv,
               host=pg_host,
               dbname=pg_db,
               user=username,
               password=getPass::getPass("Please enter password"))
return(con)
}
