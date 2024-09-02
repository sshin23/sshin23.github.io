module ShinIO

using LiveServer

const root_dir = joinpath(@__DIR__, "..")
const content_dir = joinpath(root_dir, "content")
const template_dir = joinpath(root_dir, "template")
const people_dir = joinpath(root_dir, "people")
const img_dir = joinpath(root_dir, "img")
const css_dir = joinpath(root_dir, "css")
const bib_dir = joinpath(root_dir, "bib")
const ads_dir = joinpath(root_dir, "ads")
const tex_dir = joinpath(root_dir, "tex")
const output_dir = joinpath(root_dir, "build")
const extra_dir = joinpath(root_dir, "extra")

const ADS = [
    "ad1.html" 
 ]
const KEYWORDS = [
    "{ year }" => "2023",
    "{ email }" => "sushin@mit.edu",
]
const HYPERLINKS = [
    "MIT" => "https://web.mit.edu",
    "Massachusetts Institute of Technology" => "https://web.mit.edu",
    "Chemical Engineering Department" => "https://cheme.mit.edu",
    "Department of Chemical Engineering" => "https://cheme.mit.edu",
    "Julia Language" => "https://julialang.org/",
    "single instruction, multiple data" => "https://en.wikipedia.org/wiki/Single_instruction,_multiple_data",
    "nonlinear program" => "https://en.wikipedia.org/wiki/Nonlinear_programming",
    "nonlinear programs" => "https://en.wikipedia.org/wiki/Nonlinear_programming",
    "nonlinear programming" => "https://en.wikipedia.org/wiki/Nonlinear_programming",
    "MadNLP" => "https://github.com/MadNLP/MadNLP.jl",
    "ExaModels" => "https://github.com/sshin23/ExaModels.jl",
    "model predictive control" => "https://en.wikipedia.org/wiki/Model_predictive_control",
    "graph theory" => "https://en.wikipedia.org/wiki/Graph_theory",
    "statistics" => "https://en.wikipedia.org/wiki/Statistics",
    "reinforcement learning" => "https://en.wikipedia.org/wiki/Reinforcement_learning",
    "GPU computing" => "https://en.wikipedia.org/wiki/Graphics_processing_unit",
    "distributed computing" => "https://en.wikipedia.org/wiki/Distributed_computing",
    "email Sungho"=> "mailto:{sushin@mit.edu}",
    "numerical linear algebra"=>"https://en.wikipedia.org/wiki/Numerical_linear_algebra",
    "algebraic modeling platforms"=>"https://en.wikipedia.org/wiki/General_algebraic_modeling_system",
    "control theory"=> "https://en.wikipedia.org/wiki/Control_theory",
    "control"=> "https://en.wikipedia.org/wiki/Control_theory",
    "mathematical optimization"=>"https://en.wikipedia.org/wiki/Mathematical_optimization",
    "numerical optimization"=>"https://en.wikipedia.org/wiki/Mathematical_optimization",
    "machine learning"=>"https://en.wikipedia.org/wiki/Machine_learning",
    "process systems engineering"=>"https://en.wikipedia.org/wiki/Systems_engineering",
    "energy systems"=>"https://en.wikipedia.org/wiki/Energy_systems",
    "exascale supercomputers"=>"https://en.wikipedia.org/wiki/Exascale_computing",
    "Aurora"=>"https://en.wikipedia.org/wiki/Aurora_(supercomputer)",
    "Summit"=>"https://en.wikipedia.org/wiki/Summit_(supercomputer)",
    "Frontier"=>"https://en.wikipedia.org/wiki/Frontier_(supercomputer)",
    "high-performance computing"=>"https://en.wikipedia.org/wiki/High_performance_computing",
    "decision-making problems"=>"https://en.wikipedia.org/wiki/Optimization_problem",
    "mathematical optimization problems"=>"https://en.wikipedia.org/wiki/Optimization_problem",
    "automatic differentiation"=>"https://en.wikipedia.org/wiki/Automatic_differentiation",
]

const WATCHDIR = [
    "build",
    "content",
    "template",
    "img",
    "css",
]
const nav_items =  [
    "Home" => "/",
    "People" => "/people",
    "Research" => "/research",
    "Publications" => "/publications",
    "Software" => "/software",
    "Facilities" => "/facilities",
    "News" => "/news",
    # "Join Us!" => "/positions", 
]

const abbrvnames = [
    "S. Shin"
]

# const contents = [
#     "index.html",
#     "news.html",
#     "research.html",
#     "people.html",
#     "positions.html",
#     "software.html",
# ]

function cv()
    @info "building CV"
    run(`$(joinpath(tex_dir,"build-cv"))`)
end

function extra()
    @info "building Extra"
    run(`$(joinpath(extra_dir,"build-extra"))`)
end

function build(; build_cv = true, build_extra = true, clean = false)
    
    build_cv && cv()
    build_extra && extra()
    
    @info "building website"
    # setup the directory
    if clean
        rm(output_dir; recursive = true, force=true)
        mkpath(output_dir)
    end
    cp(joinpath(@__DIR__,"..","img"), joinpath(output_dir,"img"); force=true)
    cp(joinpath(@__DIR__,"..","css"), joinpath(output_dir,"css"); force=true)
    cp(joinpath(@__DIR__,"..","tex/shin.pdf"), joinpath(output_dir,"shin.pdf"); force=true)

    # Define the navbar items
    nav = nav_html(nav_items)

    # Write the publication.html file
    html_names = [
        replace(
            name,
            " "=>"&nbsp;"
        )
        for name in abbrvnames]

    prep = publication(joinpath(bib_dir,"prep.bib"); names = html_names, label="P")
    jrnl = publication(joinpath(bib_dir,"jrnl.bib"); names = html_names, label="J")
    conf = publication(joinpath(bib_dir,"conf.bib"); names = html_names, label="C")
    
    content = """
<h1>Publications</h1>
<h2>Preprints</h2>
$prep
<hr>
<h2>Journal Publications</h2>
$jrnl
<hr>
<h2>Conference Publications</h2>
$conf
"""
    write_html(nav, content, joinpath(output_dir,"publications"))


    # Read the markdown files and convert them to HTML
    for f in readdir(content_dir) 
        file = joinpath(content_dir,f)
        filename = splitext(basename(file))[1]
        # Write the HTML to a file
        write_html(
            nav,
            read(file, String),
            filename == "index" ? output_dir : joinpath(output_dir,filename)
        )
    end
end

function nav_html(nav_items)
    # Generate the navbar HTML
    nav_html = ""
    for (name, url) in nav_items
        nav_html *= """<li class="nav-item"><a class="nav-link" href="$(url)">$(name)</a></li>"""
    end
    return nav_html
end


function write_html(nav, content, output)
    html = replace(
        replace(
            read(joinpath(template_dir,"template.html"), String),
            "{ nav }" => nav,
            "{ content }" => content,
        ),
        "{ recent news }" => five_news(),
        "{ ads }" => join("<hr>" * read(joinpath(ads_dir,ad), String) for ad in ADS),
        KEYWORDS...,
        ("{ $a }" => "<a href=\"$b\">$a</a>" for (a,b)  in HYPERLINKS)...
    )

    mkpath(output)
    write(joinpath(output,"index.html"), html)
end

people(names) = join((_people(name) for name in names), "<br>")
function _people(name)
    bio = Markdown.html(
        Markdown.parse(
            read(joinpath(people_dir,"$name.md"), String)
        )
    )
    photo = "/img/$name.jpg"
    return """
<div class="full">
  <div class="left">
    <img class="profile-picture" src=$photo alt="photo" class="img-fluid">
  </div>
  <div class="right">
    $bio
  </div>
</div>
"""
end

function publication(f; names = String[], label="")
    path = tempname()
    output = path * ".html"
    run(`bibtex2html -nf pdf pdf -nf youtube YouTube -nf proquest ProQuest -nf preprint preprint -q -r -s abbrv -revkeys -nodoc -nofooter -nobibsource -o $path $f`)
    result = read(output, String)
    rm(output; force = true)

    
    return replace(
        result,
        (name => "<strong>$name</strong>" for name in names)...,
        "[<a name" =>"[$label<a name",
        "<sup>*</sup>" => "*",
        "http://arxiv.org/abs/arXiv:" => "https://arxiv.org/abs/",
    )
end

function serve()
    LiveServer.serve(
        dir= output_dir
    )
end

function commit(msg)
    # Commit and push the changes
    cd(@__DIR__) do
        run(`git add -A`)
        run(`git commit -m "$msg"`)
        run(`git push`)
    end
end

function deploy()
    # Define the repository URL and the branch to deploy to
    repo_url = "git@github.com:sshin23/sshin23.github.io.git"
    branch = "gh-pages"

    # Define the build directory
    build_dir = joinpath(@__DIR__,"..","build")

    # Clone the repository into a temporary directory
    tmp_dir = mktempdir()
    run(`git clone --depth 1 --branch $branch $repo_url $tmp_dir`)

    # Copy the contents of the build directory to the repository directory
    for f in readdir(build_dir, join=true)
        run(`cp -r $f $tmp_dir`)
    end

    # Commit and push the changes
    cd(tmp_dir) do
        run(`git add -A`)
        run(`git commit -m "Deploy website"`)
        run(`git push origin $branch`)
    end

    # Clean up the temporary directory
    rm(tmp_dir; recursive=true)
end

function five_news()
    news = read(joinpath(@__DIR__,"..","content","news.html"),String)
    items = [split(item, "</li>")[1] for item in split(news, "<li>")]
    items = strip.(items[2:min(6,length(items))])
    return """
<ul>
$(prod("<li>\n$item\n</li>\n" for item in items))</ul>
"""    
end

function develop()
    watch_folder(root_dir) do event
        for f in event.paths
            v = relpath(splitdir(f)[1], root_dir) 
            if v in ["tex", "extra"] && splitext(f)[2] != ".tex"
                return
            end
        end
        build()
    end
end

end # module


