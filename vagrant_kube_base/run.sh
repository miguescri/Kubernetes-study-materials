rm kube-base.box
vagrant destroy -f
vagrant up
vagrant halt
vagrant package --output=kube-base.box kube-base
vagrant box add kube-base.box --name=kube-base --force
