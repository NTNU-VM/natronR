# natronR

This is a collection of functions to batch-upload data to [NaTron](https://wiki.vm.ntnu.no/display/INH/NaTron). 

All the documentation and instructions are found in the vignette called 'user-instructions'. First, doenload the source package from Github (remember to build vignette):

```r
install.packages("devtools")
devtools::install_github("NTNU-VM/natronR", build_vignettes = T)


```
You may need to install ```knitr``` manually if you haven't already. 

Now you can view the vignette like this:

```r
vignette("user-instructions", package = "natronR")

```
Good luck.

