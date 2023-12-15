const DOCKERFILE_NAME = "Dockerfile_mine"
const IMAGE_DIFF_POST = "init"
const CODE_DIR = "service"
const PLATFORM = "linux/amd64"
const PACKUP_DIR = ".packup"

mkdir $PACKUP_DIR

let components_dir = $"($PACKUP_DIR)/components" | path expand

mkdir $components_dir

let meta_data_zip = $"($PACKUP_DIR)/meta_data_zip" | path expand

mkdir $meta_data_zip

let meta_data = $"($PACKUP_DIR)/meta_data" | path expand

mkdir $meta_data

let meta_data_cus = $"($PACKUP_DIR)/meta_data_cus" | path expand

let meta_dir = $"($meta_data)/META" | path expand
let manifest_file = $"($meta_data)/manifest.json" | path expand
let licence_map_file = $"($meta_data)/licenceMap.json" | path expand
let meta_components_file = $"($meta_dir)/components.json" | path expand
let meta_interfaces_file = $"($meta_dir)/interfaces.json" | path expand
let meta_permissions_file = $"($meta_dir)/permissions.json" | path expand
let meta_privileges_file = $"($meta_dir)/privileges.json" | path expand

def "read meta" [] {
    if ($meta_data_cus | path exists) {
        cp -fr $"($meta_data_cus)/*" $meta_data
    } else if (ls $meta_data_zip | is-empty | not $in) {
        ls $meta_data_zip | get 0.name | ^unzip -d $meta_data -o $in
    } else {
        error make {msg: "lack of custom meta data or zip meta data"}
    }

    {
        app_id: (open $manifest_file | get id),
        pre_cap: (open $manifest_file | get id | split row '.' | last),
        components: (open $meta_components_file | items {|key,item| {
            component_id:$key, 
            component_version:($item | get version), 
            component_name: ($item | get name),
        }}),
    }
}

def "clean images" [] {
    ^docker images | from ssv | where REPOSITORY == '<none>' and TAG == '<none>' | each {|it| docker rmi $it.'IMAGE ID' }
}

def "packup init" [] {
    let data = (read meta)
    let pwd = (pwd)
    for item in $data.components {
        let component_id = $item.component_id
        let component_version = $item.component_version
        let tag_name = $"($component_id | str downcase)_($IMAGE_DIFF_POST)"

        cd $"($component_id)/($CODE_DIR)"
        
        open Dockerfile | lines | split list '' | get 0 | to text | save -f $"($DOCKERFILE_NAME)_($IMAGE_DIFF_POST)"

        ^docker build $"--platform=($PLATFORM)" -f $"($DOCKERFILE_NAME)_($IMAGE_DIFF_POST)" . -t $"($tag_name):($component_version)"
        cd $pwd
    }

    mkdir $PACKUP_DIR

    touch .gitignore; open .gitignore | lines | append ['packup.nu', $PACKUP_DIR, 'Makefile', ".docker", ".cache"] | uniq | save -f .gitignore

    clean images
}

def "packup exec" [] {
    [
        $"($PACKUP_DIR)"
        $manifest_file
        $licence_map_file
        $meta_components_file
        $meta_interfaces_file
        $meta_permissions_file
        $meta_privileges_file
    ] | each {|it| if not ($it | path exists ) { error make {msg: $"($it) does not exists"} } }

    let pwd = (pwd)

    let data = (read meta)

    for item in ($data.components) {
        let component_id = $item.component_id
        let component_version = $item.component_version
        let component_name = $item.component_name

        let dist_component_dir = $"($PACKUP_DIR)/($component_id)" | path expand
        mkdir $dist_component_dir
        rm -fv $"($dist_component_dir)/*"

        let ca_file = $"($components_dir)/($component_id).ca" | path expand
        rm -fv $ca_file

        let tag_name = ($component_id | str downcase)

        let component_dir = $"./($component_id)" | path expand

        let meta_json = {
            "appId": $data.app_id,
            "id": $component_id,
            "name": $component_name,
            "version": $component_version,
            "type": "service",
            "source": $"file://service-($component_id)-($component_version)",
            "internal": false
        }

        $meta_json | to json | save $"($dist_component_dir)/meta.json"

        cd $"($component_dir)/($CODE_DIR)"

        open Dockerfile
        | str replace 'npm i && ' ''
        | str replace 'sh build.sh' 'npx tsc' 
        | lines 
        | update 0 ($in.0 | str replace -r "(?i)FROM .* AS" $"FROM ($tag_name)_($IMAGE_DIFF_POST):($component_version) AS") 
        | save -f $DOCKERFILE_NAME

        ^docker build $"--platform=($PLATFORM)" -f $DOCKERFILE_NAME . -t $"($tag_name):($component_version)"
        ^docker save -o $"($dist_component_dir)/service-($component_id)-($component_version)" $"($tag_name):($component_version)"
        cd $"($dist_component_dir)"
        ^zip $"($components_dir)/($component_id).ca" meta.json $"service-($component_id)-($component_version)"
        cd $pwd
    }
    cd $PACKUP_DIR

    ^zip -r $"($data.pre_cap)_(date now | format date '%Y%m%d_%H%M%S').cap" $manifest_file $manifest_file $components_dir $meta_dir

    clean images
}