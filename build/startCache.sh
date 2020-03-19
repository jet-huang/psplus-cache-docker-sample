#!/bin/bash
SOLACE_INSTALL_DIR=/usr/local/solace
SOLACE_CACHE_CONFIG_DIR=$SOLACE_INSTALL_DIR/SolaceCache/config
SOLACE_CACHE_CONFIG_TEMPLATE=$SOLACE_INSTALL_DIR/SolaceCache/template.conf
SOLACE_CACHE_CONFIG_LOG=/tmp/cacheConfig.log
SOLACE_CACHE_INSTANCE_LOG=/tmp/cacheInstance.log
SOLACE_IS_CONFIGURED=0

# Initialize PS+ cache configs if needed
## First time we start this container, it should always run into this status.
[ "$(ls -A $SOLACE_CACHE_CONFIG_DIR)" ] && SOLACE_IS_CONFIGURED=1 || SOLACE_IS_CONFIGURED=0


echo "Initialize configuration of instances on" `date`
echo "Initialize configuration of instances on" `date` > $SOLACE_CACHE_CONFIG_LOG
strDateSerial=$(date +"%Y%m%d%H%M%S")
source $SOLACE_INSTALL_DIR/SolaceCache/instances.sh

if [ $SOLACE_IS_CONFIGURED = "0" ]
then
    echo "The configuration for PSCache is not here, generating now..."
    echo "The configuration for PSCache is not here, generating now..." >> $SOLACE_CACHE_CONFIG_LOG
    ## I don't check if there is no instance defined yet...
    iIndex=0
    echo "Get $iInstanceNum instances to generate, serial is $strDateSerial"
    echo "Get $iInstanceNum instances to generate, serial is $strDateSerial" >> $SOLACE_CACHE_CONFIG_LOG
    for i in `seq 1 1 $iInstanceNum`
    do
        printf -v strCurrNum "%03d" $i
        strCurrHost=${aSessionHost[$iIndex]}
        strCurrVpnName=${aSessionVpnName[$iIndex]}
        strCurrClientName=${aSessionClientName[$iIndex]}-$strDateSerial
        strCurrInstanceName=${aCacheInstanceName[$iIndex]}
        strCurrApplicationDescription="$strSessionApplicationDescriptionPrefix $strCurrInstanceName running with clientName $strCurrClientName on $HOSTNAME ($REALHOSTNAME)"
        strCurrInstanceConfigName=$strCurrNum\_$strCurrVpnName\_$strCurrInstanceName\_$strDateSerial.conf
        # Generate a new cache config based on template
        ## No doubt there are many better tools to generate files from template (e.g. jinja2), but I would stay for compatibility and size first.
        cp $SOLACE_CACHE_CONFIG_TEMPLATE $SOLACE_CACHE_CONFIG_DIR/$strCurrInstanceConfigName
        sed -i "s/TEMPLATE_VAR_HOST/$strCurrHost/g" $SOLACE_CACHE_CONFIG_DIR/$strCurrInstanceConfigName
        sed -i "s/TEMPLATE_VAR_VPN_NAME/$strCurrVpnName/g" $SOLACE_CACHE_CONFIG_DIR/$strCurrInstanceConfigName
        sed -i "s/TEMPLATE_VAR_CLIENT_NAME/$strCurrClientName/g" $SOLACE_CACHE_CONFIG_DIR/$strCurrInstanceConfigName
        sed -i "s/TEMPLATE_VAR_INSTANCE_NAME/$strCurrInstanceName/g" $SOLACE_CACHE_CONFIG_DIR/$strCurrInstanceConfigName
        sed -i "s/TEMPLATE_VAR_APPLICATION_DESCRIPTION/$strCurrApplicationDescription/g" $SOLACE_CACHE_CONFIG_DIR/$strCurrInstanceConfigName
        echo "Instance" $strCurrInstanceName "connecting to" $strCurrHost "with clientName" $strCurrClientName "is created."
        echo "Instance config name:" $strCurrInstanceConfigName
        echo "Instance" $strCurrInstanceName "connecting to" $strCurrHost "with clientName" $strCurrClientName "is created." >> $SOLACE_CACHE_CONFIG_LOG
        echo "Instance config name:" $strCurrInstanceConfigName >> $SOLACE_CACHE_CONFIG_LOG
        let iIndex=$iIndex+1
    done
fi
echo "Initializing configuration of instances is done on" `date`
echo "Initializing configuration of instances is done on" `date` >> $SOLACE_CACHE_CONFIG_LOG

export LD_LIBRARY_PATH=$SOLACE_INSTALL_DIR/SolaceCache/lib:$SOLACE_INSTALL_DIR/solclient/lib:$LD_LIBRARY_PATH

echo Start SolaceCache on `date`
echo Start SolaceCache on `date` > $SOLACE_CACHE_INSTANCE_LOG
iIndex=0
for instanceConfig in "$SOLACE_INSTALL_DIR/SolaceCache/config"/*
do
    strCurrHost=${aSessionHost[$iIndex]}
    strCurrVpnName=${aSessionVpnName[$iIndex]}
    strCurrClientName=${aSessionClientName[$iIndex]}-$strDateSerial
    strCurrInstanceName=${aCacheInstanceName[$iIndex]}
    echo "Loading config:" $instanceConfig ...
    echo "Loading config:" $instanceConfig ... >> $SOLACE_CACHE_INSTANCE_LOG
    echo "Start instance:" $strCurrInstanceName "connecting to" $strCurrHost "with clientName" $strCurrClientName
    echo "Start instance:" $strCurrInstanceName "connecting to" $strCurrHost "with clientName" $strCurrClientName  >> $SOLACE_CACHE_INSTANCE_LOG
    #nohup $SOLACE_INSTALL_DIR/SolaceCache/bin/SolaceCache -f $instanceConfig &
    python $SOLACE_INSTALL_DIR/SolaceCache/bin/keepalive $SOLACE_INSTALL_DIR/SolaceCache/bin/SolaceCache -f $instanceConfig &
    echo Instance $strCurrInstanceName at $strCurrVpnName on $strCurrHost is running.
    echo Instance $strCurrInstanceName at $strCurrVpnName on $strCurrHost is running. >> $SOLACE_CACHE_INSTANCE_LOG
    let iIndex=$iIndex+1
done
echo SolaceCache service is started on `date`
echo SolaceCache service is started on `date` >> $SOLACE_CACHE_INSTANCE_LOG

tail -f /dev/null
