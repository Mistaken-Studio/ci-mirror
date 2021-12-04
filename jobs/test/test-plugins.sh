#!/bin/bash
sudo chown gitlab-runner:gitlab-runner /home/scpsl/server_files/CI\ Tester
mv ./CI\ Tester /home/scpsl/server_files/CI\ Tester
cd /home/barwa/.config

git clone https://oauth2:$GIT_KEY@git.mistaken.pl/scp-sl/dependencies.git
rm /home/barwa/.config/dependencies/*Publicized*.dll
rm /home/barwa/.config/EXILED/Plugins/*.dll

#Plugins
mv /home/barwa/.config/dependencies/Exiled.* /home/barwa/.config/EXILED/Plugins/
mv /home/barwa/.config/dependencies/Mistaken.* /home/barwa/.config/EXILED/Plugins/
mv /home/barwa/.config/dependencies/0Mistaken.* /home/barwa/.config/EXILED/Plugins/
mv /home/barwa/.config/dependencies/MistakenSocket.Client.SL.Plugin.dll /home/barwa/.config/EXILED/Plugins/

#Dependencies
mv /home/barwa/.config/dependencies/MistakenSocket.Client.SL.Lib.dll /home/barwa/.config/EXILED/Plugins/dependencies/
mv /home/barwa/.config/dependencies/MistakenSocket.Client.dll /home/barwa/.config/EXILED/Plugins/dependencies/
mv /home/barwa/.config/dependencies/MistakenSocket.Shared.dll /home/barwa/.config/EXILED/Plugins/dependencies/
mv /home/barwa/.config/dependencies/Discord_Webhook.dll /home/barwa/.config/EXILED/Plugins/dependencies/
mv /home/barwa/.config/dependencies/UnidecodeSharpFork.dll /home/barwa/.config/EXILED/Plugins/dependencies/
mv /home/barwa/.config/dependencies/NetCoreServer.dll /home/barwa/.config/EXILED/Plugins/dependencies/
mv /home/barwa/.config/dependencies/Exiled.API.dll /home/barwa/.config/EXILED/Plugins/dependencies/

#Loader
mv /home/barwa/.config/dependencies/Exiled.Loader.dll /home/barwa/.config/EXILED/

rm -rf /home/barwa/.config/dependencies/

echo $CI_PROJECT_DIR
echo $CI_PROJECT_TITLE
echo $CI_PROJECT_NAME

mv $CI_PROJECT_DIR/$CI_PROJECT_NAME/build/* /home/barwa/.config/EXILED/Plugins/
sudo chmod -R 777 /home/barwa/.config/EXILED
cd /home/scpsl/server_files
sudo chmod 777 ./CI\ Tester
sudo chown barwa:barwa CI\ Tester
sudo -u barwa ./CI\ Tester
exit
