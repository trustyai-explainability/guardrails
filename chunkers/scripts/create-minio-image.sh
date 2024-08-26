set -o pipefail
set -o nounset
set -o errtrace

source $(dirname "$(realpath "$0")")/../env.sh"

echo "Installing required Python libraries"
pip install -r ./requirements.txt

## Boostrap detector & chunker models ########################################################################
mdkir ${OUTPUT_MODEL_DIR}
python . -m="${MODEL_ID}" -o="${OUTPUT_MODEL_DIR}"

## Update Dockerfile with local and remote model path
sed -i "s/<output_model_dir>/${OUTPUT_MODEL_DIR}/g" ./Dockerfile | sed -i "s/<remote_model_dir>/${REMOTE_MODEL_DIR}/g" ./Dockerfile | tee ${BASE_DIR}/Dockerfile-current.yaml

## Build & push MinIO image to Quay ########################################################################
echo "Building MiNIO image"
podman build -t quay.io/${QUAY_USERNAME}/guardrails-detectors:${TAG} .

echo "Pushing image to Quay"
podman push quay.io/${QUAY_USERNAME}/guardrails-detectors:${TAG}
