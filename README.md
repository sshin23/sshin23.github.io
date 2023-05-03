# ShinIO

This package is used for building and deploying website `sunghoshin.com`. 

Several dependencies need to be installed to use this package.
- [julia](https://julialang.org/)
- [git](https://git-scm.com/)
- [texlive](https://www.tug.org/texlive/)
- [bibtex2html](https://github.com/backtracking/bibtex2html)

Once all the dependencies are obtained, run the following to instantiate the package:
```shell
$ git clone git@github.com:sshin23/sshin23.github.io.git
$ cd sshin23.github.io.git
$ julia --project -e 'using Pkg; Pkg.instantiate()'
```

After entering into julia REPL,
```julia-repl
$ julia --project
```
Then, the website can be generated by
```julia-repl
julia> using ShinIO; ShinIO.build()
```

Then, the website can be locally hosted by
```julia-repl
julia> ShinIO.serve()
```
and accessed through `127.0.0.1:8000`.

Finally, the built website can be deployed to the deployment branch `gh-pages` by
```julia-repl
julia> ShinIO.deploy()
```