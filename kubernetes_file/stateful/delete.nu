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
                if $"(sh -c 'fluvio cluster status 2>/dev/null' | lines | find stable | is-empty)" == "false" {
                    fluvio cluster delete --namespace fluvio
                }
                $item
            } ,
            _ => {
                cd $item
                ^kubectl delete -f .
                $item
            }
        }
    } | each {|item|
        # check
        print $"waiting for ($item) delete......."
        let namespace = if $item == "fluvio" { "fluvio" } else { "stateful" }
        loop {
            let empty = $"(kubectl get pod -n $namespace | from ssv | where NAME =~ $item | is-empty)"
            if $empty == "true" {
                break
            }
            sleep 1sec
        }
        print $"($item) delete success!"
    }
}