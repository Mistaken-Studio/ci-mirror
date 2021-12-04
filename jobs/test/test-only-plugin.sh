#!/bin/bash

sudo chown gitlab-runner:gitlab-runner /home/scpsl/server_files/CI\ Tester
mv ./CI\ Tester /home/scpsl/server_files/CI\ Tester
cd /home/barwa/.config

git clone https://oauth2:$GIT_KEY@git.mistaken.pl/scp-sl/dependencies.git
rm /home/barwa/.config/dependencies/*Publicized*.dll
rm /home/barwa/.config/EXILED/Plugins/*.dll

#Loader
mv /home/barwa/.config/dependencies/Exiled.Loader.dll /home/barwa/.config/EXILED/

#Dependencies
mv /home/barwa/.config/dependencies/MistakenSocket.Client.SL.Lib.dll /home/barwa/.config/EXILED/Plugins/dependencies/
mv /home/barwa/.config/dependencies/MistakenSocket.Client.dll /home/barwa/.config/EXILED/Plugins/dependencies/
mv /home/barwa/.config/dependencies/MistakenSocket.Shared.dll /home/barwa/.config/EXILED/Plugins/dependencies/
mv /home/barwa/.config/dependencies/Discord_Webhook.dll /home/barwa/.config/EXILED/Plugins/dependencies/
mv /home/barwa/.config/dependencies/UnidecodeSharpFork.dll /home/barwa/.config/EXILED/Plugins/dependencies/
mv /home/barwa/.config/dependencies/NetCoreServer.dll /home/barwa/.config/EXILED/Plugins/dependencies/
mv /home/barwa/.config/dependencies/Exiled.API.dll /home/barwa/.config/EXILED/Plugins/dependencies/

#Plugins
mv /home/barwa/.config/dependencies/Exiled.* /home/barwa/.config/EXILED/Plugins/
mv /home/barwa/.config/dependencies/0Mistaken.API.dll /home/barwa/.config/EXILED/Plugins/
mv /home/barwa/.config/dependencies/Mistaken.Updater.dll /home/barwa/.config/EXILED/Plugins/
mv /home/barwa/.config/dependencies/Mistaken.RoundLogger.dll /home/barwa/.config/EXILED/Plugins/
mv /home/barwa/.config/dependencies/Mistaken.CITester.dll /home/barwa/.config/EXILED/Plugins/


#Plugin dependencies
files=$(echo $REQUIED_PLUGINS | tr ";" "\n")
for file in files
do
    printf "Moving: %s\n" ${file}
    mv /home/barwa/.config/dependencies/${file} /home/barwa/.config/EXILED/Plugins/
done

rm -rf /home/barwa/.config/dependencies/

echo $CI_PROJECT_DIR
echo $CI_PROJECT_TITLE
echo $CI_PROJECT_NAME

mv $CI_PROJECT_DIR/*/build/* /home/barwa/.config/EXILED/Plugins/
sudo chmod -R 777 /home/barwa/.config/EXILED
cd /home/scpsl/server_files
sudo chmod 777 ./CI\ Tester
sudo chown barwa:barwa CI\ Tester
sudo -u barwa ./CI\ Tester
exit
