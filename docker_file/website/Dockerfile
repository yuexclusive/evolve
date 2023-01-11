from alpine
run apk update
run apk add git
run apk add hugo
workdir /work
run hugo new site quickstart
workdir quickstart
run git init
run git submodule add https://github.com/theNewDynamic/gohugo-theme-ananke.git themes/ananke
run echo "theme = \"ananke\"" >> config.toml
run hugo new posts/my-first-post.md
entrypoint ["/bin/sh","-c","hugo server --bind=0.0.0.0 -D"]