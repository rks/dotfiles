# Given a name and a file glob:
#  1. generates a hash from the contents of the files matching the glob
#  2. archives the files matched by the glob and names the archive:
#     $name-$hash.tgz
#
# Potential uses:
#  1. Only generate a new archive if files have changed
#  2. Store archives based on the contents of the files they contain
function hashed-archive () {
    local _name=$1;
    local _glob=$2;

    local _hash=`find $_glob -type f -print0 | sort -z | xargs -0 sha1sum | sha1sum | sed -e 's/[^a-f0-9]//g'`;

    tar -czf $_name-$_hash.tgz $_glob;
}
