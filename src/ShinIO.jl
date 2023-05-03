module ShinIO

using LiveServer

const content_dir = joinpath(@__DIR__, "..", "content")
const template_dir = joinpath(@__DIR__, "..", "template")
const people_dir = joinpath(@__DIR__, "..", "people")
const img_dir = joinpath(@__DIR__, "..", "img")
const css_dir = joinpath(@__DIR__, "..", "css")
const bib_dir = joinpath(@__DIR__, "..", "bib")
const tex_dir = joinpath(@__DIR__, "..", "tex")
const output_dir = joinpath(@__DIR__, "..", "build")

const nav_items =  [
    "Home" => "/",
    "Publications" => "/publications",
    "News" => "/news",
]

const abbrvnames = [
    "S. Shin"
]

const contents = [
    "news.html",
]

function cv()
    @info "building CV"
    run(`$(joinpath(tex_dir,"build-cv"))`)
end

function build(; build_cv = true)
    
    build_cv && cv()
    
    @info "building website"
    # setup the directory
    rm(output_dir; recursive = true, force=true)
    mkdir(output_dir)
    cp(joinpath(@__DIR__,"..","img"), joinpath(output_dir,"img"); force=true)
    cp(joinpath(@__DIR__,"..","css"), joinpath(output_dir,"css"); force=true)
    cp(joinpath(@__DIR__,"..","tex/shin.pdf"), joinpath(output_dir,"shin.pdf"); force=true)

    # Define the navbar items
    nav = nav_html(nav_items)

    # Write the index.html file
    write_html(nav, read(joinpath(content_dir,"index.html"), String), output_dir)

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
    for f in contents
        file = joinpath(content_dir,f)
        filename = splitext(basename(file))[1]
        # Write the HTML to a file
        write_html(nav, read(file, String), joinpath(output_dir,filename))
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
        read(joinpath(template_dir,"template.html"), String),
        "{ nav }" => nav,
        "{ content }" => content,
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
        "<sup>*</sup>" => "*"
    )
end


function serve()
    
    LiveServer.serve(
        ;
        dir= output_dir
    )
end

function deploy()
    # Define the repository URL and the branch to deploy to
    repo_url = "git@github.com:sshin23/sshin23.github.io.git"
    branch = "gh-pages"

    # Define the build directory
    build_dir = "build"

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

end # module


