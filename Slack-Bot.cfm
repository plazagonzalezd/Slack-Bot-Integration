<cftry>
	<!---Local Variables--->
	<cfset channel = "##YourChanelName">
	<cfset permalink = "">
	<cfset token = "YourToken">
	<cfset filename = getClientFileName()>
	<cfset inputFile = "#form.YourFileInputID#">
	<!---Fix channel--->
	<!---Use this if you have more than one channel--->
	<cfif form.radioInput_23722 EQ "Website" OR form.radioInput_23722 EQ "Campus Suite">
		<cfset channel = "##req-cs-updates">
	<cfelseif form.radioInput_23722 EQ "Form Manager">
		<cfset channel = "##req-form-manager">
	<cfelseif form.radioInput_23722 EQ "CASHNet">
		<cfset channel = "##req-cashnet">
	</cfif>

	<!---
		Send the file First;
		Get the permalink;
		Attach it to the Payload too for safe keeping
	--->
<cfif isDefined("filename")>
	<cfhttp url="https://slack.com/api/files.upload" method="POST" result="postFile">
		<cfhttpparam type="FormField" name="token" value="#token#">
		<cfhttpparam type="FormField" name="filename" value ="#filename#">
		<cfhttpparam type="FormField" name="channels" value ="#channel#">
		<cfhttpparam type="file" name="file" file="#inputFile#">
	</cfhttp>

	<cfset postFile = deserializeJSON(postFile.fileContent)>
	<!--- Get the filename from the file Upload Response --->
	<cfset permalink = postFile.file.permalink>
</cfif>
	<!---Format Form--->
	<cfset attachments = [
		{
			"fallback": "Web Update from #form.NAMEBLOCKINPUT_2102_FIRST# #form.NAMEBLOCKINPUT_2103_LAST# - Details #form.textareaInput_785#",
			"color": "warning",
			"title": "Quick Web Update",
			"fields": [
				{
					"title": "User:",
					"value": "#form.NAMEBLOCKINPUT_2102_FIRST# #form.NAMEBLOCKINPUT_2103_LAST#",
					"short": true
				},
				{
					"title": "Email:",
					"value": "#form.textInput_783#",
					"short": true
				},
				{
					"title": "Department:",
					"value": "#form.textInput_782#",
					"short": true
				},
				{
					"title": "Phone:",
					"value": "(#form.phoneBlockInput_2105_Area#) #form.phoneBlockInput_2106_3#-#form.phoneBlockInput_2107_4#",
					"short": true
				},
				{
					"title": "System:",
					"value": "#form.radioInput_23722#",
					"short": true
				},
				{
					"title": "Site URL:",
					"value": "#form.textInput_784#",
					"short": true
				},
				{
					"title": "File:",
					"value": #permalink#,
					"short": true
				},
				{
					"title": "More Files:",
					"value": "#form.selectInput_2108#",
					"short": true
				},
				{
					"title": "Details:",
					"value": "#form.textareaInput_785#",
					"short": false
				},
				{
					"title": "IP Address:",
					"value": "#CGI.REMOTE_ADDR#",
					"short": true
				}
			]
		}
	]>

	<!---Post Form Information--->
	<cfhttp url="https://slack.com/api/chat.postMessage" method="POST" result="postForm">
		<cfhttpparam type="FormField" name="token" value="#token#">
		<cfhttpparam type="FormField" name="as_user" value="false">
		<cfhttpparam type="FormField" name="username" value="XavierBot">
		<cfhttpparam type="FormField" name="icon_url" value="https://avatars.slack-edge.com/2016-05-24/45473586274_376024d10197210f48b9_48.jpg">
		<cfhttpparam type="FormField" name="channel" value="#channel#">
		<cfhttpparam type="FormField" name="attachments" value="#serializeJSON(attachments)#">
	</cfhttp>

	<!---Helper Function to get file name--->
	<cffunction name="getClientFileName" returntype="string" output="false" hint="">
		<cfset parts = Form.getPartsArray()>
		<cfloop array="#parts#" index="local.tmpPart">
			<cfif local.tmpPart.isFile()>
				<cfreturn local.tmpPart.getFileName() />
			</cfif>
		</cfloop>
	</cffunction>

	<cfcatch>
		<cfmail from="Slack Error <nobody@xavier.edu>" to="plazagonzalezd@xavier.edu" subject="Web Update Request Error" type="html">
			<h2>SLACK INTEGRATION ERROR:</h2>
			<p>Request was not sent to slack.</p>
			<cfdump var="#cfcatch#" label="Catch">
			<p>#listGetAt(structFind(GetHttpRequestData().headers,'X-forwarded-for'),1)#</p>
			<cfdump var="#variables#" label="variables">
			<cfdump var="#session#" label="sesion">
			<cfdump var="#cgi#" label="CGI">
		</cfmail>
	</cfcatch>
</cftry>
