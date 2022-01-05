This project currently using Flutter Channel stable, 1.22.4

This is a basic example of standart pattern for Flutter

#how to build#

flutter build apk --debug --flavor develop -t lib/main_develop.dart //for develop

flutter build apk --debug --flavor staging -t lib/main_staging.dart //for staging

flutter build apk --release --flavor production -t lib/main_production.dart // for production


#how to update package name android#

flutter pub run change_app_package_name:main com.new.package.name


#how to update language and localization#

flutter pub run easy_localization:generate -S "assets/translations" -O "lib/translations"

then

flutter pub run easy_localization:generate -S "assets/translations" -O "lib/translations" -o "locale_keys.g.dart" -f keys


