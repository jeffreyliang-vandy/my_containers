rspm::enable()

install.packages(c(
    'InterSIM'
    ,"RGCCA"
    ,'IntNMF'
    ,'r.jive'

))

BiocManager::install(c(
    "omicade4"
    ,"MOFA2"
))

remotes::install_github("rdevito/MSFA")

