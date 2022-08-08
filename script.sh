#!/bin/ash

if [ -z "$PLUGIN_USER" ]; then
  echo "ERR: user variable is empty"
  exit 1
fi

if [ -z "$PLUGIN_TOKEN" ]; then
  echo "ERR: token variable is empty"
  exit 1
fi

if [ -z "$PLUGIN_FILE" ]; then
  echo "ERR: file variable is empty"
  exit 1
fi

HASH=`echo "$DRONE_COMMIT" | cut -c-10`
if [ -z "$PLUGIN_VERSION" ]; then
  echo "INFO: version variable is empty defaulting to $HASH"
fi

API_URL=`echo "$DRONE_REPO_LINK" | grep -Eo '^http[s]?://[^/]+'`
PACKAGE_SUBPATH=packages/${DRONE_REPO_OWNER}/generic/${DRONE_REPO_NAME}/${PLUGIN_VERSION:-$HASH}
PACKAGE_URL=${API_URL}/api/$PACKAGE_SUBPATH
PACKAGE_API_URL=${API_URL}/api/v1/$PACKAGE_SUBPATH
echo "DEBUG: destination $PACKAGE_URL"

curl \
  --location \
  --user ${PLUGIN_USER}:${PLUGIN_TOKEN} \
  -X 'DELETE' \
  --silent --output /dev/null \
  $PACKAGE_API_URL

# requires https://github.com/go-gitea/gitea/pull/20661
for f in $PLUGIN_FILE; do
  BASE_FILENAME=`basename $f`
  echo "INFO: uploading $BASE_FILENAME to $API_URL"
  status_code=`curl --location --user ${PLUGIN_USER}:${PLUGIN_TOKEN} --upload-file $f --write-out %{http_code} --silent --output /dev/null $PACKAGE_URL/$BASE_FILENAME`

  if [ $status_code -ne 201 ]; then
    echo "ERR: failed to upload file ($status_code)"
    exit 1
  else
    echo "INFO: upload of $BASE_FILENAME successful to $PACKAGE_URL/${BASE_FILENAME}"
  fi
done

exit 0
