#!/bin/bash

sed -i \
  -e 's/^#Font=Sans/Font=Noto Sans CJK JP/' \
  -e 's/^#MenuFont=Sans/Menu=Noto Sans CJK JP'/ \
  -e 's/^#FontLocale=zh_CN.UTF-8/FontLocale=ja_JP.UTF-8/' \
    ${HOME}/.config/fcitx/conf/fcitx-classic-ui.config

if [ ! -f ${HOME}/.config/lxsession/LXDE-pi/desktop.conf ]; then
  mkdir -p ${HOME}/.config/lxsession/LXDE-pi

  cat <<EOF >${HOME}/.config/lxsession/LXDE-pi/desktop.conf
[GTK]
sGtk/FontName=Noto Sans CJK JP 12
EOF
else
  if ! grep -q "^sGtk/FontName=" ${HOME}/.config/lxsession/LXDE-pi/desktop.conf 2>/dev/null; then
    if ! grep -q "^\[GTK\]" ${HOME}/.config/lxsession/LXDE-pi/desktop.conf 2>/dev/null; then
      cat <<EOF >>${HOME}/.config/lxsession/LXDE-pi/desktop.conf
[GTK]
sGtk/FontName=Noto Sans CJK JP 12
EOF
    else
      sed -i "/^\[GTK\]/asGtk/FontName=Noto Sans CJK 12" ${HOME}/.config/lxsession/LXDE-pi/desktop.conf
    fi
  else
    sed -i 's|^sGtk/FontName=.*|sGtk/FontName=Noto Sans CJK JP 12|' ${HOME}/.config/lxsession/LXDE-pi/desktop.conf
  fi
fi

exit 0
