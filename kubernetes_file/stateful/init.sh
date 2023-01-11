#! /bin/bash
# fluvio
# if kubectl get ns | grep ^fluvio | wc -l | xargs test 1 -eq; then
#     kubectl delete ns fluvio
# fi

# kubectl create ns fluvio

# fluvio cluster start --namespace=fluvio

# stateful
if kubectl get ns | grep ^stateful | wc -l | xargs test 1 -eq; then
    kubectl delete ns stateful
fi

kubectl create ns stateful

for dir in "postgres" "redis" "meilisearch"; do
    kubectl apply --wait=true -f $(pwd)/${dir}
done

mark=1
while test $mark -eq 1; do
    echo "waiting"
    mark=0
    sleep 1
    for item in $(kubectl get all -n stateful | awk 'BEGIN{ORS=" "}NR>=2 && NR<=4{print $3}'); do
        if test "$item" != "Running"; then
            mark=1
            break
        fi
    done
done

# init postgresql
kubectl cp $(pwd)/postgres/evolve.sql stateful/postgres-0:evolve.sql
kubectl exec -it -n stateful postgres-0 -- bash <<EOF
    psql -U postgres evolve<evolve.sql
EOF
