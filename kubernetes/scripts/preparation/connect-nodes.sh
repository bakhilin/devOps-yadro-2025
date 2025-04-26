# generate new token
kubeadm token generate 
kubeadm token create token_name --print-join-command --ttl=0

# join node
kubeadm join 10.0.0.2:6443 --token token_name \
    --discovery-token-ca-cert-hash token_sha256