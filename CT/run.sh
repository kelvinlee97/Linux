#!/bin/bash

#target_group="aws2_xxcpwap"
#serv="wap"
#version=""

#ANSIBLE_HOST_KEY_CHECKING=False

target_group=$1
serv=${2}
version=${3}

if [ ! ${version} ]; then
    ziplist="$(cat ~/frontend_deploy_script/.cache_jms|jq .${target_group}.vars.service.${serv}.spathPkg | awk -F '"' "{print \$2}" )*.zip"
    version=$(ls 2>/dev/null -lt $ziplist | awk {'print $NF'} | head -1 | awk -F '/' {'printf $NF'} | awk -F '-' {'print $NF'} | awk -F '.zip' {'print $1'})
fi
ansible-playbook -i $HOME/frontend_deploy_script/jms.py $HOME/frontend_deploy_script/run.yml --extra-vars "target_group=${target_group} serv=${serv} version=${version}" || exit $?

spath="$(cat ~/frontend_deploy_script/.cache_jms|jq .${target_group}.vars.service.${serv}.spathPkg | awk -F '"' "{print \$2}" )"${version}".zip"
dpath="/data/wwwroot/""$(cat ~/frontend_deploy_script/.cache_jms|jq .${target_group}.vars.service.${serv}.dpathWeb | awk -F '"' "{print \$2}" )"
dpathUnzipInput="$(cat ~/frontend_deploy_script/.cache_jms|jq .${target_group}.vars.service.${serv}.dpathUnzip | awk -F '"' "{print \$2}" )"
echo $spath
echo $dpath
echo $dpathUnzipInput
if [[ ${serv} == "web" || ${serv} == "wap" || ${serv} == "ipis_sport_wap" || ${serv} == "mwbrl_wap" || ${serv} == "mssmh_wap"  || ${serv} == "dsfwap" || ${serv} == "apiweb" || ${serv} == "wap_demo" || ${serv} == "web_demo" ]] && [ ${target_group} != "uat01_wap" ] && [ ${target_group} != "uat04_wap" ] && [ ${target_group} != "uat05_wap" ]
then

#        if ( grep -w ${target_group} /home/deploy/frontend_deploy_script/qiniu-backup-list.txt ); then
#                echo "Yezhu in CDN frozen list"
#                destpath="$(grep -w ${target_group} /home/deploy/frontend_deploy_script/qiniu-backup-list.txt | grep web | awk '{print $2}')"
                if [[ ${serv} == "web" ]]
                then
                        destpath="$(grep -w ${target_group} /home/deploy/frontend_deploy_script/qiniu-backup-list.txt | grep web | awk '{print $2}')"
                        srcpath="$(grep -w ${target_group} /home/deploy/frontend_deploy_script/qiniu-backup-list.txt | grep web | awk '{print $1}')"
                                                echo "source=$srcpath"
                                                echo "destination=$destpath"
                                                                                                rm -rf /home/deploy/package/qiniu/static/${srcpath}/pcwap/${srcpath}
                                                                                                unzip ${spath} -d /home/deploy/package/qiniu/static/${srcpath}/pcwap/
                                                                                                mv /home/deploy/package/qiniu/static/${srcpath}/pcwap/dist /home/deploy/package/qiniu/static/${srcpath}/pcwap/${srcpath}
                                                ansible -i /home/deploy/ansible/hosts qiniu_backup --key-file "/home/deploy/.key/automation_support.key" -m synchronize -a "src=/home/deploy/package/qiniu/static/${srcpath}/pcwap dest=/mnt/${destpath}/"
                                                ansible -i /home/deploy/ansible/hosts qiniu_backup --key-file "/home/deploy/.key/automation_support.key" -m synchronize -a "src=/home/deploy/package/qiniu/static/${srcpath}/pcwap/${srcpath}/assets/static dest=/mnt/${destpath}/assets/"
                                                ansible -i /home/deploy/ansible/hosts qiniu_backup --key-file "/home/deploy/.key/automation_support.key" -m command -a "/root/awsupload.sh ${destpath}"
                elif [[ ${serv} == "ipis_sport_wap" ]]
                then
                        destpath="$(grep -w ${target_group}_ipis /home/deploy/frontend_deploy_script/qiniu-backup-list.txt | grep wap | awk '{print $2}' | head -n1)"
                        srcpath="$(grep -w ${target_group}_ipis /home/deploy/frontend_deploy_script/qiniu-backup-list.txt | grep -v web | awk '{print $1}')"
                                                echo "source=$srcpath"
                                                echo "destination=$destpath"
                                                                                                rm -rf /home/deploy/package/qiniu/static/${srcpath}/pcwap/${srcpath}
                                                                                                unzip ${spath} -d /home/deploy/package/qiniu/static/${srcpath}/pcwap/
                                                                                                mv /home/deploy/package/qiniu/static/${srcpath}/pcwap/www /home/deploy/package/qiniu/static/${srcpath}/pcwap/${srcpath}
                                                ansible -i /home/deploy/ansible/hosts qiniu_backup --key-file "/home/deploy/.key/automation_support.key" -m synchronize -a "src=/home/deploy/package/qiniu/static/${srcpath}/pcwap dest=/mnt/${destpath}/"
                                                ansible -i /home/deploy/ansible/hosts qiniu_backup --key-file "/home/deploy/.key/automation_support.key" -m synchronize -a "src=/home/deploy/package/qiniu/static/${srcpath}/pcwap/${srcpath}/static/media dest=/mnt/${destpath}/static/"
                                                ansible -i /home/deploy/ansible/hosts qiniu_backup --key-file "/home/deploy/.key/automation_support.key" -m command -a "/root/awsupload.sh ${destpath}"
                elif [[ ${serv} == "mwbrl_wap" ]]
                then
                        destpath="$(grep -w ${target_group}_brl /home/deploy/frontend_deploy_script/qiniu-backup-list.txt | grep wap | awk '{print $2}' | head -n1)"
                        srcpath="$(grep -w ${target_group}_brl /home/deploy/frontend_deploy_script/qiniu-backup-list.txt | grep -v web | awk '{print $1}')"
                                                echo "source=$srcpath"
                                                echo "destination=$destpath"
                                                                                                rm -rf /home/deploy/package/qiniu/static/${srcpath}/pcwap/${srcpath}
                                                                                                unzip ${spath} -d /home/deploy/package/qiniu/static/${srcpath}/pcwap/
                                                                                                mv /home/deploy/package/qiniu/static/${srcpath}/pcwap/www /home/deploy/package/qiniu/static/${srcpath}/pcwap/${srcpath}
                                                ansible -i /home/deploy/ansible/hosts qiniu_backup --key-file "/home/deploy/.key/automation_support.key" -m synchronize -a "src=/home/deploy/package/qiniu/static/${srcpath}/pcwap dest=/mnt/${destpath}/"
                                                ansible -i /home/deploy/ansible/hosts qiniu_backup --key-file "/home/deploy/.key/automation_support.key" -m synchronize -a "src=/home/deploy/package/qiniu/static/${srcpath}/pcwap/${srcpath}/static/media dest=/mnt/${destpath}/static/"
                                                ansible -i /home/deploy/ansible/hosts qiniu_backup --key-file "/home/deploy/.key/automation_support.key" -m command -a "/root/awsupload.sh ${destpath}"
                elif [[ ${serv} == "mssmh_wap" ]]
                then
                        destpath="$(grep -w ${target_group}_smh /home/deploy/frontend_deploy_script/qiniu-backup-list.txt | grep wap | awk '{print $2}' | head -n1)"
                        srcpath="$(grep -w ${target_group}_smh /home/deploy/frontend_deploy_script/qiniu-backup-list.txt | grep -v web | awk '{print $1}')"
                                                echo "source=$srcpath"
                                                echo "destination=$destpath"
                                                                                                rm -rf /home/deploy/package/qiniu/static/${srcpath}/pcwap/${srcpath}
                                                                                                unzip ${spath} -d /home/deploy/package/qiniu/static/${srcpath}/pcwap/
                                                                                                mv /home/deploy/package/qiniu/static/${srcpath}/pcwap/build /home/deploy/package/qiniu/static/${srcpath}/pcwap/${srcpath}
                                                ansible -i /home/deploy/ansible/hosts qiniu_backup --key-file "/home/deploy/.key/automation_support.key" -m synchronize -a "src=/home/deploy/package/qiniu/static/${srcpath}/pcwap dest=/mnt/${destpath}/"
                                                ansible -i /home/deploy/ansible/hosts qiniu_backup --key-file "/home/deploy/.key/automation_support.key" -m synchronize -a "src=/home/deploy/package/qiniu/static/${srcpath}/pcwap/${srcpath}/static/media dest=/mnt/${destpath}/static/"
                                                ansible -i /home/deploy/ansible/hosts qiniu_backup --key-file "/home/deploy/.key/automation_support.key" -m command -a "/root/awsupload.sh ${destpath}"
                else
                        destpath="$(grep -w ${target_group} /home/deploy/frontend_deploy_script/qiniu-backup-list.txt | grep wap | awk '{print $2}' | head -n1)"
                        srcpath="$(grep -w ${target_group} /home/deploy/frontend_deploy_script/qiniu-backup-list.txt | grep -v web | awk '{print $1}')"
                                                echo "source=$srcpath"
                                                echo "destination=$destpath"
                                                                                                rm -rf /home/deploy/package/qiniu/static/${srcpath}/pcwap/${srcpath}
                                                                                                unzip ${spath} -d /home/deploy/package/qiniu/static/${srcpath}/pcwap/
                                                                                                mv /home/deploy/package/qiniu/static/${srcpath}/pcwap/www /home/deploy/package/qiniu/static/${srcpath}/pcwap/${srcpath}
                                                ansible -i /home/deploy/ansible/hosts qiniu_backup --key-file "/home/deploy/.key/automation_support.key" -m synchronize -a "src=/home/deploy/package/qiniu/static/${srcpath}/pcwap dest=/mnt/${destpath}/"
                                                ansible -i /home/deploy/ansible/hosts qiniu_backup --key-file "/home/deploy/.key/automation_support.key" -m synchronize -a "src=/home/deploy/package/qiniu/static/${srcpath}/pcwap/${srcpath}/static/media dest=/mnt/${destpath}/static/"
                                                ansible -i /home/deploy/ansible/hosts qiniu_backup --key-file "/home/deploy/.key/automation_support.key" -m command -a "/root/awsupload.sh ${destpath}"
                fi

fi


if [[ ${serv} == "nmgt" ]] && [[ ${target_group} == "uat01_mgt" ]]
then
   echo "sync the package to uat07admin.513xyz.com too"
   for target_host in `jq .${target_group}.children[] ~/frontend_deploy_script/.cache_jms | xargs -I{} jq .{}.hosts[] ~/frontend_deploy_script/.cache_jms | sed 's/"//g'`
   do
        /usr/bin/ssh jms@${target_host} /usr/bin/rm -rf /data/wwwroot/uat07admin.513xyz.com-last
        /usr/bin/ssh jms@${target_host} /usr/bin/mv /data/wwwroot/uat07admin.513xyz.com /data/wwwroot/uat07admin.513xyz.com-last
        /usr/bin/ssh jms@${target_host} /usr/bin/cp -rp /data/wwwroot/nmgt-uat /data/wwwroot/uat07admin.513xyz.com
   done
fi



  $HOME/frontend_deploy_script/version/manage_version.py ${target_group} ${serv} ${version} && scp /home/deploy/frontend_deploy_script/version/frontend_version.json jms@13.250.32.155:/data/wwwroot/deploy_out/frontend_version.json
