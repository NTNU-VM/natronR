.onAttach <- function(libname, pkgname){
  packageStartupMessage(
    '\n***************************\n
    Welcome to the package that lets you\n
    upload datasets to NaTron.\n\n
    Type vignette("user-instructions", package = "natronR") to learn more.\n

***************************\n'
  )
}




