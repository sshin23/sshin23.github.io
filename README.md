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

To generate the website, first enter into julia REPL:
```julia-repl
$ julia --project
```

Then, run the following command:
```julia-repl
julia> using ShinIO; ShinIO.build()
```

To locally host the website, run the following command in the Julia REPL and access it through `127.0.0.1:8000`:
```julia-repl
julia> ShinIO.serve()
```


Finally, to deploy the built website to the deployment branch `gh-pages`, run the following command in the Julia REPL:
```julia-repl
julia> ShinIO.deploy()
```

That's it! If you encounter any issues or have any questions, please report an [issue](https://github.com/sshin23/sshin23.github.io/issues).
