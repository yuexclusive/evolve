const config = {
    image_diff: "init",
    docker_file_name: "Dockerfile_mine",
    platform: "linux/amd64",
    # dir
    packup_dir: ".packup",
    code_dir: "service",
    meta_data_dir: "meta_data",
    meta_data_zip_dir: "meta_data_zip",
    meta_data_cus_dir: "meta_data_cus",
    # meta file
    meta_dir: "META"
    components_dir: "components",
    component_config_file: "meta.json",
    manifest_file: "manifest.json",
    licence_map_file: "licenceMap.json",
    meta_components_file: "components.json",
    meta_interfaces_file: "interfaces.json",
    meta_permissions_file: "permissions.json",
    meta_privileges_file: "privileges.json"
}

def "check meta" [] {
    [
        $config.manifest_file,
        $config.licence_map_file,
        $config.meta_dir,
        $"($config.meta_dir)/($config.meta_components_file)",
        $"($config.meta_dir)/($config.meta_interfaces_file)",
        $"($config.meta_dir)/($config.meta_permissions_file)",
        $"($config.meta_dir)/($config.meta_privileges_file)"
    ] | each {|it| if not ($it | path exists ) { error make {msg: $"($it) does not exists"} } }
}


def "read meta" [] {
    let pwd = (pwd)

    touch .gitignore; open .gitignore | lines | append ['packup.nu', $config.packup_dir, 'Makefile', ".docker", ".cache"] | uniq | save -f .gitignore

    mkdir $config.packup_dir

    cd $config.packup_dir

    [$config.meta_data_dir,$config.meta_data_zip_dir,$config.meta_data_cus_dir ] | each {|it| mkdir $"($it)"}

    if (ls $config.meta_data_cus_dir | is-empty | not $in) {
        $config.meta_data_dir | cp -frv $"($config.meta_data_cus_dir)/*" $in
    } else if (ls $config.meta_data_zip_dir | is-empty | not $in) {
        ls $config.meta_data_zip_dir | get 0.name | ^unzip -d $config.meta_data_dir -o $in
    } else {
        error make {msg: "lack of custom meta data or zip meta data"}
    }

    cd $config.meta_data_dir

    mkdir $config.components_dir

    check meta
    
    let res = {
        app_id: (open $config.manifest_file | get id),
        components: (open $"($config.meta_dir)/($config.meta_components_file)" | items {|key,item| {
            component_id:$key, 
            component_version:($item | get version), 
            component_name: ($item | get name),
        }}),
    }

    cd $pwd

    $res
}

def "clean images" [] {
    ^docker images | from ssv | where REPOSITORY == '<none>' and TAG == '<none>' | each {|it| docker rmi $it.'IMAGE ID' }
}

def "packup init" [] {
    let pwd = (pwd)

    let data = (read meta)

    for item in $data.components {
        let component_id = $item.component_id
        let component_version = $item.component_version
        let tag_name = $"($component_id | str downcase)_($config.image_diff)"

        cd $"($component_id)/($config.code_dir)"

        let init_docker_file_name = $"($config.docker_file_name)_($config.image_diff)"
        
        open Dockerfile | lines | split list '' | get 0 | to text | save -f $init_docker_file_name

        ^docker build $"--platform=($config.platform)" -f $init_docker_file_name . -t $"($tag_name):($component_version)"
        cd $pwd
    }

    clean images
}

def "packup exec" [] {
    let pwd = (pwd)

    let data = (read meta)

    for item in ($data.components) {
        let component_id = $item.component_id
        let component_version = $item.component_version
        let component_name = $item.component_name

        let current_component_dir = $"($config.packup_dir)/($component_id)" 
        rm -fr $current_component_dir
        mkdir $current_component_dir

        let ca_file = $"($config.packup_dir)/($config.meta_data_dir)/($config.components_dir)/($component_id).ca" 
        rm -fv $ca_file

        let tag_name = ($component_id | str downcase)

        let meta_json = {
            "appId": $data.app_id,
            "id": $component_id,
            "name": $component_name,
            "version": $component_version,
            "type": "service",
            "source": $"file://service-($component_id)-($component_version)",
            "internal": false
        }

        $meta_json | to json | save $"($current_component_dir)/($config.component_config_file)"


        # build image
        cd $"($component_id)/($config.code_dir)"

        open Dockerfile
        | str replace 'npm i && ' ''
        | str replace 'sh build.sh' 'npx tsc' 
        | lines 
        | update 0 ($in.0 | str replace -r "(?i)FROM .* AS" $"FROM ($tag_name)_($config.image_diff):($component_version) AS") 
        | save -f $config.docker_file_name

        ^docker build $"--platform=($config.platform)" -f $config.docker_file_name . -t $"($tag_name):($component_version)"

        cd ../..

        ^docker save -o $"($current_component_dir)/service-($component_id)-($component_version)" $"($tag_name):($component_version)"

        cd $"($current_component_dir)"

        ^zip $"../($config.meta_data_dir)/($config.components_dir)/($component_id).ca" ($config.component_config_file) $"service-($component_id)-($component_version)"
        
        cd $pwd
    }

    cd $"($config.packup_dir)/($config.meta_data_dir)"

    let app_name = $data.app_id | split row '.' | last;

    ^zip -r $"../($app_name)_(date now | format date '%Y%m%d_%H%M%S').cap" $config.manifest_file $config.licence_map_file $config.meta_dir $config.components_dir

    clean images
}