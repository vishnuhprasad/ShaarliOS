#!/bin/sh
#
#  Copyright (c) 2015-2016 Marcus Rohrmoser http://mro.name/me. All rights reserved.
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

name=onepassword-app-extension
git_url=https://github.com/AgileBits/$name.git
base_dir=$HOME/Downloads/3rdparty

git --version >/dev/null || { echo "oh, I need git." && exit 1; }

cd `dirname $0`
cwd=`pwd`

mkdir -p "$base_dir" 2> /dev/null
cd "$base_dir"
if [ -d "$name" ] ; then
	cd "$name"
	git pull
else
	git clone "$git_url" "$name"
	cd "$name"
fi

cd "$cwd"
rm -rf README.* LICENSE* *.? 1Password.xcassets 2> /dev/null

cd "$base_dir/$name"
cp -rp README* LICENSE* 1Password.xcassets OnePasswordExtension.? "$cwd"
git log -1 > "$cwd"/version.log
cd "$cwd"
