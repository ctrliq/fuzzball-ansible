## Provisioning hosts for an iqube deployment of fuzzball

    cp hosts.yaml-example hosts.yaml # customize hosts.yaml
    ansible-playbook setup-iqube.yaml --inventory hosts.ini \
        --extra-vars="oauth2accesstoken=$(gcloud --quiet auth print-access-token)"


## Generating an ssh key

iqube requires passwordless ssh connectivity between the admin host
and the kubernetes cluster nodes.

    ssh-keygen -t ed25519 -C 'iqube' -f ~/.ssh/iqube -N ''


## Artifacts

Artifacts required for deployment should be placed in the `artifacts/`
directory.

**iqube** can be pulled with oras.

    oras pull us-west1-docker.pkg.dev/fuzzball-dev/iqube/iqube-packages:v1.0.0-rc-3

Available artifacts can be listed with `gcloud`.

    gcloud artifacts docker tags list us-west1-docker.pkg.dev/fuzzball-dev/iqube/iqube-packages

**fuzzball-substrate** packages can be pulled with oras.

    oras pull us-west1-docker.pkg.dev/fuzzball-dev/fuzzball/fuzzball-substrate-packages:v1.2.7-rc-28

Available artifacts can be listed with `gcloud`.

    gcloud artifacts docker tags list us-west1-docker.pkg.dev/fuzzball-dev/fuzzball/fuzzball-substrate-packages

Other artifacts are pulled by Ansible directly.

    apptainer pull oras://us-west1-docker.pkg.dev/fuzzball-dev/iqube/fuzzball-stack:v1.2.7-rc-21
    apptainer pull oras://us-west1-docker.pkg.dev/fuzzball-dev/iqube/kubernetes-substrate:v1.2.7-rc-21

And their artifacts can also be listed with `gcloud`.

    gcloud artifacts docker tags list us-west1-docker.pkg.dev/fuzzball-dev/iqube/fuzzball-stack
    gcloud artifacts docker tags list us-west1-docker.pkg.dev/fuzzball-dev/iqube/kubernetes-substrate

Or the CLI with `curl`.

    curl -LO https://artifacts.ciq.dev/fuzzball/builds/fuzzball-v1.2.7-rc-22.linux-amd64.rpm
    curl -L https://artifacts.ciq.dev/fuzzball/builds/

Do not commit artifacts to this repository.
