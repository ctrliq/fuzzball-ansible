## Provisioning hosts for an iqube deployment of fuzzball

    ansible-playbook setup-iqube.yaml --inventory hosts.ini \
	  --extra-vars="apptainer_oauth2accesstoken=$(gcloud auth print-access-token)"
