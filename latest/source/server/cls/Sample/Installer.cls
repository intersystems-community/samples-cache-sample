Include %occInclude

/// Sample Installer
Class Sample.Installer
{

/// Application Definition
XData MyApp [ XMLNamespace = INSTALLER ]
{
<Manifest>
<If Condition='$L("${NAMESPACE}")=0'>
<!-- Report an error if the namespace wasn't specified -->
<Error Status="$$$NamespaceDoesNotExist">
<Arg Value="${NAMESPACE}"/>
</Error>
</If>

<Namespace Name="SAMPLES">
<!-- Invoke a helper method on this installer class -->
<Invoke Class="Sample.Installer" Method="Message" CheckStatus="0"/>
</Namespace>

<!-- Do some setup -->
<Var Name="MYAPPDIR" Value="${MYAPPDIR}/myapp"/>
<Var Name="DBRESOURCE" Value="%DB_${NAMESPACE}"/>
<Var Name="MYAPPRESOURCE" Value="%DB_MYAPP"/>
<Var Name="PRODUCTION" Value="MyApp.Production"/>

<!-- Create the namespace, yes it's Ensemble enabled for MyApp -->
<Namespace Name="${NAMESPACE}"
          Create="yes"
          Code="${NAMESPACE}"
          Data="${NAMESPACE}"
          Ensemble="1"
          EnsemblePortalPrefix="myapp"
          EnsemblePortalSuffix="ensemble"
          EnsemblePortalGrant="${DBRESOURCE}"
		  >

<Configuration>

<!-- Create a "data" database -->
<Database Name="${NAMESPACE}"
		 Dir="${MGRDIR}/${NAMESPACE}"
		 Create="yes"
		 Resource="${DBRESOURCE}"
		 PublicPermissions=""/>

<!-- Add the existing MyApp database as the code database for this namespace -->
<Database Name="MYAPP"
		 Dir="${MYAPPDIR}/db"
		 Create="no"
		 Resource="${MYAPPRESOURCE}"
		 PublicPermissions=""/>

<!-- MyApp mappings back to the MYAPP DB.
-->
<GlobalMapping Global="MyAppData.*"    	From="MYAPP"/>
<GlobalMapping Global="cspRule"  		From="MYAPP"/>

<ClassMapping Package="MyApp"    		From="MYAPP"/>

<RoutineMapping Routines="MYAPP" Type="INC" From="MYAPP"/>
</Configuration>

<!-- Check for an upgrade vs install -->
<Invoke Class="Sample.Installer" Method="IsUpgrade" Return="ISUPGRADE"/>

<!-- MyApp setup, load some data in -->
<Import File="${MYAPPDIR}/data/Defaults.gof"/>

<!-- Load patch classes (if they exist) -->
<If Condition='#{##class(%File).DirectoryExists("${MYAPPDIR}/patch/")}'>
<!-- Load a directory full of files, ignore error 5202 ... -->
<Import File="${MYAPPDIR}/patch/" IgnoreErrors="5202" Flags="ck"/>
</If>

<!-- Configure MyApp -->
<Invoke Class="Sample.Installer" Method="SetupDefaults" CheckStatus="1">
<Arg Value="${NAMESPACE}"/>
<Arg Value="${ISUPGRADE}"/>						<!-- True if upgrading -->
</Invoke>

<If Condition="'${ISUPGRADE}">
<!-- Compile the production for a new install -->
<Compile Class="${PRODUCTION}" Flags="ck"/>

<!-- Configure the production -->
<Production Name="${PRODUCTION}">
<Setting Item="FOO"
		Target="Host"
		Setting="Upgraded"
		Value="${ISUPGRADE}"/>
<Setting Item="FOO"
	    Target="Host"
	    Setting="Namespace"
	     Value="${NAMESPACE}"/>
</Production>
</If>

<!-- System settings changes required for MyApp -->
<SystemSetting Name="Config.Miscellaneous.EnableLongStrings" Value="1"/>

<!-- Create a CSP application for the namespace -->
<Var Name="URL" Value='/csp/myapp/#{$ZCVT("${NAMESPACE}","L")}'/>
<Var Name="DIR" Dir='${CSPDIR}myapp/#{$ZCVT("${NAMESPACE}","L")}'/>

<CSPApplication Url="${URL}"
			   Directory="${DIR}"
	           Resource=""
	           Grant="${DBRESOURCE}"
	           Description="MyApp CSP Interface"
	           Recurse="1"
	           CookiePath="/csp/myappp"
	           AuthenticationMethods="32"
	 />

</Namespace>
</Manifest>
}

/// This is a method generator whose code is generated by XGL.
ClassMethod setup(ByRef pVars, pLogLevel As %Integer, pInstaller As %Installer.Installer, pLogger As %Installer.AbstractLogger) As %Status [ CodeMode = objectgenerator, Internal ]
{
	#; Let our XGL document generate code for this method. 
	Quit ##class(%Installer.Manifest).%Generate(%compiledclass, %code, "MyApp")
}

ClassMethod Message()
{
	WRITE $TR($J("",60)," ","="),!
	WRITE $ZV,!
	WRITE $TR($J("",60)," ","="),!
}

/// Setup defaults for this MyApp system
ClassMethod SetupDefaults(pNamespace As %String = {$ZU(5)}, pUpgrading As %Boolean) As %Status
{
	#dim tSC As %Status
	Set tSC=$$$OK,$ZT="Trap"
	Do {
	
	    // Do whatever here ...
		
	} While (0)
Exit
	Quit tSC
Trap
	Set $ZT="",tSC=$$$ERROR($$$CacheError,$ZE)
	Goto Exit
}

ClassMethod IsUpgrade(pNamespace As %String = {$ZU(5)}) As %Boolean [ CodeMode = expression ]
{
$RANDOM(2)
}

/// Invoke the installer passing in some variables
ClassMethod RunInstall() As %Status
{
	#dim tVars
	#dim tStatus As %Status
	#dim tLogLevel As %Integer = 1
	
	// Initialize any variables we want to pass to the installer
	Set tVars("NAMESPACE") = "TEST"
	
	// Invoke the installer
	Set tStatus = ..setup(.tVars,tLogLevel)
	
	Do:$$$ISERR(tStatus) $system.OBJ.DisplayError(tStatus)
	
	Quit tStatus
}

/// Invoke the installer passing in some variables
ClassMethod RunInstallWithLog(pLogfile As %String) As %Status
{
	#dim tVars
	#dim tStatus As %Status
	#dim tLogLevel As %Integer = 1
	
	// Initialize any variables we want to pass to the installer
	Set tVars("NAMESPACE") = "TEST"

	// Construct a file logger
	#dim tLogger As %Installer.FileLogger = ##class(%Installer.FileLogger).%New(1,pLogfile)
	
	// Invoke the installer
	Set tStatus = ..setup(.tVars,tLogLevel,,tLogger)
	
	Do:$$$ISERR(tStatus) $system.OBJ.DisplayError(tStatus)
	
	Quit tStatus
}

}