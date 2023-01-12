#!/bin/bash
json=`curl -s http://127.0.0.1:8080/people.json`
if [ $# -eq 0 ];
then
    echo "Available profiles:"
    echo $json | jq -r '.people | keys | .[]'
else
    combined_name=""
    combined_email=""
    for i in "$@"; do
        if [ "$(echo "$json" | jq '.people | has("'$i'")')" == "true" ];
        then
            current_name=`jq -r '.people.'$i'.name' <(echo "$json")`
            current_email=`jq -r '.people.'$i'.email' <(echo "$json")`
            if [ "$combined_name" == "" ];
            then
                combined_name=$current_name
                combined_email=$current_email
            else
                combined_name="$combined_name, $current_name"
                combined_email="$combined_email, $current_email"
            fi
        else
            echo "Profile for $i not found"
            exit 1
        fi
    done
    echo "[INFO] Setting Git global user name to: $combined_name"
    git config --global user.name "$combined_name"
    echo "[INFO] Setting Git global user email to: $combined_email"
    git config --global --replace-all user.email "$combined_email"
fi
