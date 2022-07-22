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

**fuzzball-substrate** packages can be pulled with oras.

	oras pull us-west1-docker.pkg.dev/fuzzball-dev/fuzzball/fuzzball-substrate-packages:v1.2.7-rc-14

Do not commit artifacts to this repository.
