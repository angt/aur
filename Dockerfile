FROM archlinux/archlinux

RUN pacman -Syq --noconfirm git base-devel

COPY . /root

RUN useradd user \
 && echo "user ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/user \
 && chown -R user /root

RUN for x in /root/*/PKGBUILD; do [ -r "$x" ] && ( \
        cd "${x%/*}"; \
        sudo -u user makepkg -s --noconfirm \
    ) done
