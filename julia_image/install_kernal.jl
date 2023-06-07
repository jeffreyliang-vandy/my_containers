using Pkg
Pkg.add("IJulia")
Pkg.update()
Pkg.build("IJulia")
Pkg.add("Plots")