#! /bin/bash
#
# Inputs:
# - $1: A semantic version (e.g. "1.2.3") which will be used to set the Operator image tag
# - $2: An OCI image tag for the snyk-monitor (e.g. "discardable-1234" or "1.2.3")
#
# Outputs:
# - Creates a new directory under snyk-operator/deploy/olm-catalog/snyk-operator with the version provided as input $1
# - Updates snyk-operator.package.yaml to point to the new version that was provided as input $1
# - Updates the ClusterServiceVersion to point to inputs $1 and $2 for the snyk-operator and snyk-monitor image tags respectively
#
# Packages a new version of the Operator using the Operator template files in this repository.
# The template files should have been previously generated by using the operator-sdk.
#
# This produces files ready to be tested and then published to OperatorHub to release
# a new version of the Snyk monitor (and accompanying Operator).
#

set -e

NEW_OPERATOR_VERSION="$1"
NEW_MONITOR_VERSION="$2"

PWD=$(pwd)
CSV_LOCATION="${PWD}/snyk-operator/deploy/olm-catalog/snyk-operator"
OPERATOR_PACKAGE_YALM_LOCATION="${CSV_LOCATION}/snyk-operator.package.yaml"
CURRENT_TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

cp -r "${CSV_LOCATION}/VERSION_OVERRIDE" "${CSV_LOCATION}/${NEW_OPERATOR_VERSION}"

sed -i.bak "s|SNYK_OPERATOR_VERSION_OVERRIDE|${NEW_OPERATOR_VERSION}|g" "${OPERATOR_PACKAGE_YALM_LOCATION}"
rm "${OPERATOR_PACKAGE_YALM_LOCATION}.bak"

SOURCE_CSV="${CSV_LOCATION}/${NEW_OPERATOR_VERSION}/snyk-operator.vVERSION_OVERRIDE.clusterserviceversion.yaml"
TARGET_CSV="${CSV_LOCATION}/${NEW_OPERATOR_VERSION}/snyk-operator.v${NEW_OPERATOR_VERSION}.clusterserviceversion.yaml"
mv "${SOURCE_CSV}" "${TARGET_CSV}"

sed -i.bak "s|SNYK_MONITOR_VERSION_OVERRIDE|${NEW_MONITOR_VERSION}|g" "${TARGET_CSV}"
sed -i.bak "s|SNYK_OPERATOR_VERSION_OVERRIDE|${NEW_OPERATOR_VERSION}|g" "${TARGET_CSV}"
sed -i.bak "s|TIMESTAMP_OVERRIDE|${CURRENT_TIMESTAMP}|g" "${TARGET_CSV}"
rm "${TARGET_CSV}.bak"

echo "Packaged version ${NEW_OPERATOR_VERSION} of the Operator with version ${NEW_MONITOR_VERSION} of the snyk-monitor."