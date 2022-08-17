copernicus
================

# copernicus

Provides download and access to
[Copernicus](https://marine.copernicus.eu/) marine datasets.

### Requirements

-   [R v4+](https://www.r-project.org/)
-   [rlang](https://CRAN.R-project.org/package=rlang)
-   [dplyr](https://CRAN.R-project.org/package=dplyr)
-   [ncdf4](https://CRAN.R-project.org/package=ncdf4)
-   [sf](https://CRAN.R-project.org/package=sf)
-   [stars](https://CRAN.R-project.org/package=stars)
-   [readr](https://CRAN.R-project.org/package=readr)
-   [twinkle](https://github.com/BigelowLab/twinkle)

### Installation

    remotes::install_github("oceanhackweek/ohw22-proj-xyzt",
                            subdir = "package/copernicus")

## Downloading

### Look Up Table (lut)

The variable names are a bit cryptic (at least to me) so we provide a
look-up table that associates the variable name with other information
available from the source.

``` r
lut <- copernicus::read_lut()
print(lut, n = nrow(lut))
```

    ## # A tibble: 11 × 3
    ##    name    longname                            units    
    ##    <chr>   <chr>                               <chr>    
    ##  1 mlotst  Density ocean mixed layer thickness m        
    ##  2 siconc  Ice concentration                   1        
    ##  3 thetao  Temperature                         degrees_C
    ##  4 usi     Sea ice eastward velocity           m s-1    
    ##  5 sithick Sea ice thickness                   m        
    ##  6 bottomT Sea floor potential temperature     degrees_C
    ##  7 vsi     Sea ice northward velocity          m s-1    
    ##  8 vo      Northward velocity                  m s-1    
    ##  9 uo      Eastward velocity                   m s-1    
    ## 10 so      Salinity                            1e-3     
    ## 11 zos     Sea surface height                  m
