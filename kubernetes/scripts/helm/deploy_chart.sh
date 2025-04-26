#!/bin/bash

info() {
	 echo -e "\033[32m[INFO]\033[0m $1";
}

package() {
    helm package currency-api-chart
}

login() {
    helm registry login registry-1.docker.io --username $1 --password $2
}

push() {
    helm push currency-api-0.1.0.tgz oci://registry-1.docker.io/$1
}

info "package chart"
package 

info "login to registry"
login $1 $2

info "push to registry"
push $1


