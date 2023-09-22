def "make build" [
    --platform: string = "linux/amd64"
    --repository: string = "yuexclusive"
    --name: string
    --version: string = "latest"
] {
    cd $name
    ^docker build ["--platform", $platform, "-t", $"($repository)/($name):($version)"] .
    make clear
}


def "make clear" [] {
    ^docker images | from ssv | where TAG == '<none>' and REPOSITORY != 'kindest/node' | each {|it| docker rmi $it.'IMAGE ID'}
}

def "make push" [
    --repository: string = "yuexclusive"
    --name: string
    --version: string = "latest"
] {
    ^docker push $"($repository)/($name):($version)"
}

def "make run" [
    --repository: string = "yuexclusive"
    --name: string
    --version: string = "latest"
] {
    ^docker run --rm -it $"($repository)/($name):($version)"
}
