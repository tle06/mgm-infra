#!/usr/bin/shell
for FILE in /entrypoint/entrypoint.d/*.sh
do
  source ${FILE}
done

exec "$@"