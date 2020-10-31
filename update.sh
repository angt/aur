#!/usr/bin/env bash
#shellcheck disable=SC1090,SC1091,SC2154

for i in *
do [ -d "$i" ] && (
	cd "$i" || exit
	. PKGBUILD
	oldpkgver="$pkgver"
	pkgver=$(curl -sSf "https://api.github.com/repos/angt/$pkgname/releases/latest" | jq -r .tag_name)
	pkgver=${pkgver#v}
	[ "$pkgver" ] || exit
	[ "$pkgver" = "$oldpkgver" ] || sed -i "s/$oldpkgver/$pkgver/g" PKGBUILD
	. PKGBUILD
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
	) >.SRCINFO
	echo " => $pkgname version $pkgver"; (
		rm -rf .git
		git init
		git remote add aur "aur:$i"
		git fetch --all
		git reset aur/master
		if [ "$oldpkgver" = "$pkgver" ]
			then git commit -sam "Update"
			else git commit -sam "Update to $pkgver"
		fi
	) >/dev/null 2>&1
) & done

wait

for i in *
do [ -d "$i" ] && (
	cd "$i" || exit
	git branch -r --contains HEAD | grep -sq aur/master || {
		git diff --staged --unified=0 aur/master
		push=
		read -r -p " => Push? (yes/no): " push
		[ "$push" = yes ] && git push aur master
	}
	rm -rf .git
) done
