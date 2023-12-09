#!/bin/bash -ex

# Crea la versión inicial de cms.config, con todas las partes relevantes
# vacías que se irán rellenando en los siguientes scripts


initCMSConfig() {

    # Lo creamos a partir del ejemplo
    cp /home/cms/cmsCode/config/cms.conf{.sample,}

    # Borramos contenido
    patchLocalConfigFile.sh '.core_services.LogService=[]'
    patchLocalConfigFile.sh '.core_services.ResourceService=[]'
    patchLocalConfigFile.sh '.core_services.ScoringService=[]'
    patchLocalConfigFile.sh '.core_services.Checker=[]'
    patchLocalConfigFile.sh '.core_services.EvaluationService=[]'
    patchLocalConfigFile.sh '.core_services.Worker=[]'
    patchLocalConfigFile.sh '.core_services.ContestWebServer=[]'
    patchLocalConfigFile.sh '.core_services.AdminWebServer=[]'
    patchLocalConfigFile.sh '.core_services.ProxyService=[]'
    patchLocalConfigFile.sh '.core_services.PrintingService=[]'
    patchLocalConfigFile.sh '.database=""'
    patchLocalConfigFile.sh '.rankings=[]'

    # Instalamos
    installLocalConfigFile.sh
}

initCMSConfig
