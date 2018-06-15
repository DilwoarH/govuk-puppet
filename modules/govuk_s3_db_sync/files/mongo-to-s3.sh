#!/bin/bash
# mongo-to-s3.sh Script to backup mongo databases to s3 to use for
# backup and synchronisation
#
# Ensure to break on error and undefined variables
set -eu
# Have debug output for pipes
set -o pipefail

usage() {
    echo "$0 -d (mongo-db-a< mongo-db-b>..) -b aws-bucket-name -p aws-bucket-keys-prefix"
  exit 0
}

# Use getopts to define possible arguments and allocations
while getopts "d:b:p:h" opt
do
  case "$opt" in
    d) databases="$OPTARG" ;;
    b) bucket="$OPTARG" ;;
    p) prefix="$OPTARG" ;;
    *) usage ;;
  esac
done

# Make arguments mandatory
: "${databases?"Not specified (pass -d option)"}"
: "${bucket?"Not specified (pass -b option)"}"
: "${prefix?"Not specified (pass -p option)"}"

mkdir -p /var/lib/mongodb/.dumps

for database in "${databases[@]}"
do

  # Create a bash array of names of collections in the database
  IFS=',' read -r -a collections <<< \
          $(mongo --quiet --eval 'rs.slaveOk(); db.getCollectionNames();' localhost/$database)

  timestamp="$(date +%Y-%m-%d-%H:%M:%S)"

  for collection in "${collections[@]}"
  do

    workdir="$(mktemp --directory -p /var/lib/mongodb/.dumps)"

    filename="${timestamp}-${database}-${collection}.gz"

    mongodump="mongodump \
      --db ${database} \
      --collection ${collection} \
      --out ${workdir}"

    s3="envdir /etc/govuk_s3_db_sync/env.d aws s3 cp - s3://${bucket}/${prefix}/${filename} --sse"

    md5sum_tempfile="$(mktemp)"

    $mongodump
    cd ${workdir}
    tar --create --gzip $workdir | tee >(md5sum > "$md5sum_tempfile") | $s3

    md5sum=$(cut -d' ' -f1 < "$md5sum_tempfile")
    rm "$md5sum_tempfile"

    s3_md5=$(aws s3api head-object \
      --bucket "$bucket" \
      --key "${prefix}/${filename}" | jq -r '.ETag' | sed 's/"//g')

    if [[ "$md5sum" != "$s3_md5" ]]
    then
      echo "MD5: Local: $md5sum Remote: $s3_md5"
      exit 1
    fi
  done
done
