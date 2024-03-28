#!/bin/sh

cd $(dirname $0)

SUPPORTED_LANGUAGES=$(grep ^translations ../doc/Makefile.in | cut -d= -f2)
#SUPPORTED_LANGUAGES="ja de fr zh_Hans" # restrict built translations

TARGETS="check-xml html cheatsheets check-cheatsheets pdf"

cat docs.yml | sed '/DO NOT EDIT/q' > docs.yml.new

exec >> docs.yml.new
for target in ${TARGETS}
do
  echo "### TARGET ${target}"
  for lang in ${SUPPORTED_LANGUAGES};
  do
    case ${target} in
      check-xml)
        depends_on=prepare
        ;;
      html|cheatsheets)
        depends_on=check-xml-${lang}
        ;;
      pdf)
        depends_on="[ build-images, check-xml-${lang} ]"
        ;;
      check-cheatsheets)
        depends_on="[ cheatsheets-${lang}, build-cheatsheets ]"
        ;;
      *)
        echo "Unexpected target ${target}" >&2
        exit 1
    esac
    sed "s/@LANG@/${lang}/;s/@TARGET@/${target}/;s/@DEP@/${depends_on}/" docs-localized.yml.in
  done
done

mv -b docs.yml.new docs.yml
