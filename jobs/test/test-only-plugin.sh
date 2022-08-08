#!/bin/bash


cd /home/container/.config
git clone --depth 1 https://oauth2:$GIT_KEY@git.mistaken.pl/scp-sl/dependencies.git
cd ..
rm ./.config/dependencies/*Publicized*.dll
rm ./.config/EXILED/Plugins/*.dll

#Loader
mv ./.config/dependencies/Exiled.Loader.dll ./.config/EXILED/

#Dependencies
mv ./.config/dependencies/MCS-Client.dll ./.config/EXILED/Plugins/dependencies/
mv ./.config/dependencies/MCS-Shared.dll ./.config/EXILED/Plugins/dependencies/
mv ./.config/dependencies/Discord_Webhook.dll ./.config/EXILED/Plugins/dependencies/
mv ./.config/dependencies/NetCoreServer.dll ./.config/EXILED/Plugins/dependencies/
mv ./.config/dependencies/Exiled.API.dll ./.config/EXILED/Plugins/dependencies/

#Plugins
mv ./.config/dependencies/Exiled.* ./.config/EXILED/Plugins/
mv ./.config/dependencies/0Mistaken.API.dll ./.config/EXILED/Plugins/
mv ./.config/dependencies/Mistaken.Updater.dll ./.config/EXILED/Plugins/
mv ./.config/dependencies/Mistaken.RoundLogger.dll ./.config/EXILED/Plugins/
mv ./.config/dependencies/Mistaken.CITester.dll ./.config/EXILED/Plugins/


#Plugin dependencies
echo "Test";
echo $REQUIED_PLUGINS;
files=$(echo $REQUIED_PLUGINS | tr ";" "\n")
echo $files;
for file in $files
do
    printf "Moving: %s\n" ${file}
    mv ./.config/dependencies/${file} ./.config/EXILED/Plugins/
done

rm -rf ./.config/dependencies/

echo $CI_PROJECT_DIR
echo $CI_PROJECT_TITLE
echo $CI_PROJECT_NAME

mv $CI_PROJECT_DIR/*/build/* ./.config/EXILED/Plugins/
chmod -R 777 ./.config/EXILED
./CI\ Tester
exit
