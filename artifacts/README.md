A place to place artifacts until we have proper repositories.

Do not commit artifacts to this repository.

- iqube binary - must be pulled with oras

	  oras pull us-west1-docker.pkg.dev/fuzzball-dev/iqube/iqube-packages:v1.0.0-rc-1

- fuzzball-substrate RPM - must be pulled with oras

      oras pull us-west1-docker.pkg.dev/fuzzball-dev/fuzzball/fuzzball-substrate-packages:v1.2.7-rc-10

- fuzzball-stack.sif - must be pulled with apptainer

      apptainer pull oras://us-west1-docker.pkg.dev/fuzzball-dev/iqube/fuzzball-stack:latest

- kubernetes-substrate.sif - must be pulled with apptainer

      apptainer pull oras://us-west1-docker.pkg.dev/fuzzball-dev/iqube/kubernetes-substrate:latest

- fuzzball CLI RPM - installable from https://artifacts.ciq.dev/fuzzball/latest/
