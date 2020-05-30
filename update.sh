#!/usr/bin/env bash
#shellcheck disable=SC1090,SC2154

_latest() {
	curl -sSf "https://api.github.com/repos/angt/$1/releases/latest" \
		| jq -r .tag_name
}

for i in */PKGBUILD
do [ -r "$i" ] && (
	. "$i"
	latest=$(_latest "$pkgname")
	latest=${latest#v}
	[ "$latest" ] || exit
	[ "$latest" = "$pkgver" ] && exit
	echo "Updating $pkgname to $latest"
	sed -i "s/$pkgver/$latest/g" "$i"
	. "$i"
	cd "$pkgname" || exit
	(
		                      printf "pkgbase = %s\n"       "$pkgname"
		[ "$pkgdesc"     ] && printf "\tpkgdesc = %s\n"     "$pkgdesc"
		[ "$pkgver"      ] && printf "\tpkgver = %s\n"      "$pkgver"
		[ "$pkgrel"      ] && printf "\tpkgrel = %s\n"      "$pkgrel"
		[ "$url"         ] && printf "\turl = %s\n"         "$url"
		[ "$arch"        ] && printf "\tarch = %s\n"        "${arch[@]}"
		[ "$license"     ] && printf "\tlicense = %s\n"     "$license"
		[ "$makedepends" ] && printf "\tmakedepends = %s\n" "${makedepends[@]}"
		[ "$depends"     ] && printf "\tdepends = %s\n"     "${depends[@]}"
		[ "$source"      ] && printf "\tsource = %s\n"      "${source[@]}"
		[ "$md5sums"     ] && printf "\tmd5sums = %s\n"     "${md5sums[@]}"
		                      printf "\npkgname = %s\n"     "$pkgname"
	) > .SRCINFO
	git commit -sm "Update to $latest"
	git push origin master
) done
