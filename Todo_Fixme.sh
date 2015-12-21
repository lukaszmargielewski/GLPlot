#!/bin/sh

#  Todo_Fixme.sh
#  Accel
#
#  Created by Lukasz Margielewski on 24/08/2014.
#
echo "SRCROOT: ${SRCROOT}"
KEYWORDS="TODO:|FIXME:"
find "${SRCROOT}" \( -name "*.h" -or -name "*.m" \) -print0 | xargs -0 egrep --with-filename --line-number --only-matching "($KEYWORDS).*\$" | perl -p -e "s/($KEYWORDS)/ warning: \$1/"

