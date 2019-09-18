#************************************#
# natron_connect                  ####
#************************************#



#' @title Connect to NaTron
#' @description  \code{natron_connect} establishes a connection between R and NaTron.
#'
#' @param username This is your NaTron username
#' @param database What database do you want to connect to? Options are "natron" and "natron_sandbox" (default). OBS: always test your upload to the sandbox before uploading to natron.
#' @return Formal class PostgreSQLConnection
#' @examples
#' \dontrun{
#' myUserName <- "JohnD"
#' myConnection <- natron_connect(myUserName)
#' }
#' @details You need to be connected via the NTNU network, either through eduroam or a vpn.
#' @import getPass
#' @import RPostgreSQL
#' @export

natron_connect <- function(username, database = "natron_sandbox") {

pg_drv <- "PostgreSQL"
pg_db <- database
pg_host <- "vm-srv-zootron.vm.ntnu.no"
password=getPass::getPass("Please enter password")

con<-RPostgreSQL::dbConnect(pg_drv,
               host=pg_host,
               dbname=pg_db,
               user=username,
               password=password)
return(con)
}
