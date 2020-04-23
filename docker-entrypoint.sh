#!/bin/bash

# developed by Florian Kleber for terms of use have a look at the LICENSE file

# terminate on errors
set -xe

cat > /etc/php7/conf.d/00_custom.ini <<EOF

EOF

cat <<- EOF > /etc/php7/conf.d/zzz_custom.ini
    max_execution_time = 0
    upload_max_filesize = 2000M
    post_max_size = 2000M
    memory_limit = -1
EOF

# execute CMD[]
exec "$@"
