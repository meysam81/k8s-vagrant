copy_binaries() {
    for binary in `ls $1`; do
        sudo install -o root -g root -m 0755 $1/$binary /usr/local/bin/$binary
    done
}

mkdir /etc/containerd/
cp /vagrant/configs/containerd/config.toml /etc/containerd/config.toml

if [[ -d /vagrant/containerd ]]; then
    copy_binaries /vagrant/containerd/bin/
else
    wget https://github.com/containerd/containerd/releases/download/v1.6.4/containerd-1.6.4-linux-amd64.tar.gz
    tar xvf containerd-1.6.4-linux-amd64.tar.gz -C /tmp/
    copy_binaries /tmp/bin/
fi

cat << 'EOF' > /etc/systemd/system/containerd.service
# Copyright The containerd Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target local-fs.target

[Service]
ExecStartPre=-/sbin/modprobe overlay
Environment=CONFIG_FILE=/etc/containerd/config.toml
ExecStart=/usr/local/bin/containerd -c $CONFIG_FILE

Type=notify
Delegate=yes
KillMode=process
Restart=always
RestartSec=5
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNPROC=infinity
LimitCORE=infinity
LimitNOFILE=infinity
# Comment TasksMax if your systemd version does not supports it.
# Only systemd 226 and above support this version.
TasksMax=infinity
OOMScoreAdjust=-999

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now containerd
