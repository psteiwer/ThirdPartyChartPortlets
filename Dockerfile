ARG IMAGE=intersystemsdc/iris-community
FROM $IMAGE

USER root
WORKDIR /opt/irisapp
RUN chown ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /opt/irisapp

USER ${ISC_PACKAGE_MGRUSER}

# copy files
COPY ThirdPartyChartPortlets ThirdPartyChartPortlets
COPY Samples Samples
COPY Assets Assets
COPY iris.script /tmp/iris.script
COPY module.xml module.xml

# run iris and script
RUN iris start IRIS \
	&& iris session IRIS < /tmp/iris.script \
    && iris stop IRIS quietly

