#! /Users/yu/.cargo/bin/nu
def main [
    ...names
] {
    $names | filter {|item|$"(glob $item | is-empty)" == "true"} | each {|item|
        print $"($item) missing!"
    }

    let available = $names | filter {|item|$"(glob $item | is-empty)" == "false"} | each {|item|
        # start
        match $item {
            "fluvio" => {
                sh -c 'fluvio cluster start --namespace fluvio 2>/dev/null'
                $item
            } ,
            _ => {
                cd $item
                ^kubectl apply -f .
                $item
            }
        }
    } | each {|item|
        # check
        print $"waiting for ($item) start......."
        let namespace = if $item == "fluvio" { "fluvio" } else { "stateful" }
        loop {
            let status = $"(kubectl get pod -n $namespace | from ssv | where NAME =~ $item | get 0.STATUS | str downcase)"
            if $status == "running" {
                break
            }
            sleep 1sec
        }
        print $"($item) start success!"
    }
}