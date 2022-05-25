set -ex

kubeadm init --pod-network-cidr=$POD_CIDR --apiserver-advertise-address=$MASTERIP

export digest=`openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'`
export token=`kubeadm token list | grep "default bootstrap" | awk '{print $1}'`

test ! -d /vagrant/tmp && mkdir /vagrant/tmp
echo "kubeadm join --token $token $MASTERIP:6443 --discovery-token-ca-cert-hash sha256:$digest" | tee /vagrant/tmp/join.sh

cat << 'EOF' | tee -a /home/vagrant/.bashrc $HOME/.bashrc >/dev/null
alias k=kubectl
complete -F __start_kubectl k
EOF

cat << 'EOF' | tee /home/vagrant/.vimrc $HOME/.vimrc >/dev/null
set expandtab
set tabstop=2
set shiftwidth=2
EOF

mkdir -p /home/vagrant/.kube
cp -f /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

kubectl completion bash > /etc/bash_completion.d/kubectl
kubeadm completion bash > /etc/bash_completion.d/kubeadm
crictl completion bash > /etc/bash_completion.d/crictl

kubectl create -f https://projectcalico.docs.tigera.io/manifests/tigera-operator.yaml
kubectl apply -f /vagrant/templates/calico.yml
