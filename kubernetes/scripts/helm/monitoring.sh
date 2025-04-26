#!/bin/bash

info() {
	 echo -e "\033[32m[INFO]\033[0m $1"
}

get_pods() {
	info
	kubectl get pods -o wide -n $1
}

info "Starting logging..."
get_pods bakhilin
get_pods ingress-nginx
