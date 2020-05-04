#!/bin/sh

set -e

SCRIPT_PATH=$(readlink -f "$0")
BASEDIR=$(dirname "$SCRIPT_PATH")

BUILD_NUMBER=0
GIT_VER=
EOS_PRVSNR_VERSION=1.0.0

usage() { echo "Usage: $0 [-G <git short revision>] [-S <EOS Provisioner version>]" 1>&2; exit 1; }

# Install rpm-build package
rpm --quiet -qi git || yum install -q -y git && echo "git already installed."
rpm --quiet -qi python3-3.6.* || yum install -q -y python36 && echo "python36 already installed."
rpm --quiet -qi rpm-build || yum install -q -y rpm-build && echo "rpm-build already installed."
rpm --quiet -qi yum-utils || yum install -q -y yum-utils && echo "yum-utils already installed."

# Clean-up pycache
find . -name "*.py[co]" -o -name __pycache__ -exec rm -rf {} +

while getopts ":g:e:b:" o; do
    case "${o}" in
        g)
            GIT_VER=${OPTARG}
            ;;
        e)
            EOS_PRVSNR_VERSION=${OPTARG}
            ;;
        b)
            BUILD_NUMBER=${OPTARG}
            ;;
        *)
            echo "Usage: buildrpm.sh -g <git_commit_hash> -e <ees_prvsnr_version> -b <build_number>"
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${GIT_VER}" ]; then
    GIT_VER=`git rev-parse --short HEAD`
fi

echo "Using [EOS_PRVSNR_VERSION=${EOS_PRVSNR_VERSION}] ..."
echo "Using [GIT_VER=${GIT_VER}] ..."

mkdir -p ~/rpmbuild/SOURCES/
pushd ~/rpmbuild/SOURCES/

    rm -rf eos-prvsnr*

    # Setup the source tar for rpm build
    DEST_DIRNAME=eos-prvsnr-${EOS_PRVSNR_VERSION}-git${GIT_VER}
    mkdir -p ${DEST_DIRNAME}/{cli,files,pillar,srv,api}
    # cp -R ${BASEDIR}/../../cli/src/* ${DEST_DIRNAME}/cli
    cp -R ${BASEDIR}/../../files/conf ${DEST_DIRNAME}/files
    cp -R ${BASEDIR}/../../pillar ${DEST_DIRNAME}
    cp -R ${BASEDIR}/../../srv ${DEST_DIRNAME}
    cp -R ${BASEDIR}/../../api ${DEST_DIRNAME}


    tar -zcvf ${DEST_DIRNAME}.tar.gz ${DEST_DIRNAME}
    rm -rf ${DEST_DIRNAME}

    yum-builddep -y ${BASEDIR}/eos-prvsnr.spec

    rpmbuild -bb --define "_ees_prvsnr_version ${EOS_PRVSNR_VERSION}" --define "_ees_prvsnr_git_ver git${GIT_VER}" --define "_build_number ${BUILD_NUMBER}" ${BASEDIR}/eos-prvsnr.spec

popd

# Remove rpm-build package
#[[ $(rpm --quiet -qi rpm-build) == 0 ]] && yum remove -q -y rpm-build
