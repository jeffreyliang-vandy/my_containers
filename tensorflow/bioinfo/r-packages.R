rspm::enable()

install.packages(c(
    'InterSIM'
    ,'IntNMF'
    ,'r.jive'

))

BiocManager::install(c(
    "iClusterPlus"
))

remotes::install_github("rdevito/MSFA")

reticulate::py_run_file("scikit-fusion/setup.py", args = "install --user")