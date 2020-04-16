Class ThirdPartyChartPortlets.Samples.Mapbox.Installer
{

XData LocalInstall [ XMLNamespace = INSTALLER ]
{
<Manifest>
	<Namespace Name="${NAMESPACE}" Create="no" Ensemble="0">
		<!--Invoke Class="PivotSubscriptions.Installer" Method="ConfigureUnsubscribeWebApp" CheckStatus="1">
		</Invoke-->
		<Import File="${APPPATH}/Samples/Mapbox/" Flags="ck" Recurse="1"/>
		<Invoke Class="ThirdPartyChartPortlets.Samples.Mapbox.Installer" Method="ImportTermList" CheckStatus="1">
			<Arg Value="${APPPATH}/Assets/Mapbox/ISO3166.csv"/>
		</Invoke>
	</Namespace>
</Manifest>
}

ClassMethod setup(ByRef pVars, pLogLevel As %Integer = 3, pInstaller As %Installer.Installer, pLogger As %Installer.AbstractLogger) As %Status [ CodeMode = objectgenerator, Internal ]
{
	#; Let XGL document generate code for this method.
	Quit ##class(%Installer.Manifest).%Generate(%compiledclass,%code,"LocalInstall")
}

ClassMethod RunLocalInstall(pRootDir, pNamespace = {$Namespace}) As %Status
{
	Set tVars("APPPATH")=pRootDir
	Set tVars("NAMESPACE")=pNamespace
	Quit ..setup(.tVars,3)
}

ClassMethod ImportTermList(pFile As %String) As %Status
{
    Set tSC=##class(%DeepSee.TermList).%ImportCSV(pFile)
	
	Quit tSC
}

}
