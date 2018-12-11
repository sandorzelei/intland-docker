<%--
 * Copyright by Intland Software
 *
 * All rights reserved.
 *
 * This software is the confidential and proprietary information
 * of Intland Software. ("Confidential Information"). You
 * shall not disclose such Confidential Information and shall use
 * it only in accordance with the terms of the license agreement
 * you entered into with Intland.
 *
 * $Revision$ $Date$
--%>
<meta name="decorator" content="main"/>
<meta name="module" content="build"/>
<meta name="moduleCSSClass" content="buildsModule"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="wysiwyg" prefix="wysiwyg" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<%@page import="com.intland.codebeamer.manager.ScmRepositoryManager"%>
<%@page import="com.intland.codebeamer.controller.ControllerUtils"%>
<%@page import="com.intland.codebeamer.scm.provider.ScmRepositoryController"%>
<%@page import="com.intland.codebeamer.scm.provider.ScmRepositoryControllerImpl"%>
<%@page import="com.intland.codebeamer.persistence.dto.ScmRepositoryDto"%>
<%@page import="com.intland.codebeamer.scm.ScmException"%>

<wysiwyg:froalaConfig />
<SCRIPT LANGUAGE="JavaScript" type="text/javascript">
<!-- Hide script from old browsers
function confirmDelete(form) {
	return confirm('<spring:message code="build.delete.confirm" />');
}
// -->
</SCRIPT>

<c:if test="${!empty param.build_id}">
	<c:set var="build_id" value="${param.build_id}" />
</c:if>

<c:if test="${empty build_id}">
	<c:set var="build_id" value="-1" />
</c:if>

<c:set var="modifyBuild" value="false" />
<spring:message var="title" code="build.create.title" text="Add New Build"/>
<spring:message var="addButton" code="button.add" text="Add"/>
<c:if test="${build_id != -1}">
	<c:set var="modifyBuild" value="true" />
	<spring:message var="title" code="build.edit.title" text="Customize"/>
	<spring:message var="addButton" code="button.save" text="Save"/>
</c:if>

<ui:actionMenuBar>
	<ui:breadcrumbs showProjects="false"><span class='breadcrumbs-separator'>&raquo;</span>
	<ui:pageTitle prefixWithIdentifiableName="false">${title}</ui:pageTitle>
	</ui:breadcrumbs>
</ui:actionMenuBar>

<html:form action="/proj/build/customizeItem" focus="name" styleId="buildSettingsForm">
<html:hidden property="build_id" value="${build_id}" />
<html:hidden property="forward" />

<jsp:useBean id="buildSettingsForm" class="com.intland.codebeamer.servlet.build.SettingsForm" scope="request" />
<%
	buildSettingsForm.setInitValues(request);
	int colspan = 2;
%>

<ui:actionBar>
	&nbsp;&nbsp;<html:submit styleClass="button" property="SUBMIT" value="${addButton}" />

	<c:if test="${build_id!=-1}">
		&nbsp;&nbsp;
		<html:submit styleClass="button" property="DELETE" onclick="return confirmDelete(this);">
			<spring:message code="button.delete" text="Delete..."/>
		</html:submit>
	</c:if>

	&nbsp;&nbsp;
	<html:cancel styleClass="button cancelButton" onclick="history.back();return false">
		<spring:message code="button.cancel"/>
	</html:cancel>
</ui:actionBar>

<ui:showErrors />

<TABLE BORDER="0" class="formTableWithSpacing" CELLPADDING="0">

<TR>
	<TD COLSPAN="<%=colspan%>">
		<spring:message var="buildTitle" code="build.file.title" text="Build File"/>
		<ui:title style="top-sub-headline-decoration" header="${buildTitle}" topMargin="0" />
	</TD>
</TR>

<TR>
	<TD class="mandatory"><spring:message code="build.name.label" text="Name"/>:</TD>
	<TD CLASS="expandText"><html:text styleClass="expandText" property="name" size="70"/></TD>
</TR>

<TR VALIGN="top">
	<TD class="mandatory">
		<spring:message code="build.description.label" text="Description"/>:
	</TD>
	<TD CLASS="expandTextArea">
		<wysiwyg:editor editorId="editor" formatSelectorStrutsProperty="descriptionFormat" height="200">
		    <html:textarea property="description" rows="5" cols="70" styleId="editor"/>
		</wysiwyg:editor>
	</TD>
</TR>

<spring:message var="logLevelTitle" code="build.logLevel.tooltip"/>
<TR title="${logLevelTitle}">
	<TD CLASS="optional"><spring:message code="build.logLevel.label" text="Ant Logging Level"/>:</TD>
	<TD>
		<html:radio property="level" value="0" /> <spring:message code="build.logLevel.quiet" text="Quiet"/>
		<html:radio property="level" value="1" /> <spring:message code="build.logLevel.normal" text="Normal"/>
		<html:radio property="level" value="2" /> <spring:message code="build.logLevel.verbose" text="Verbose"/>
		<html:radio property="level" value="3" /> <spring:message code="build.logLevel.debug" text="Debug"/>
	</TD>
</TR>

<spring:message var="fileTitle" code="build.file.tooltip" />
<TR title="${fileTitle}">
	<TD CLASS="mandatory"><spring:message code="build.file.label" text="Ant Build File"/>:</TD>
	<td>
<% 	ScmRepositoryDto repository = null; // TODO: set repository
	boolean distributed = false;
	ScmRepositoryControllerImpl controller = ((ScmRepositoryControllerImpl) ScmRepositoryManager.getInstance().getController(repository));
	distributed = controller.getProvider().isDistributed();
	pageContext.setAttribute("repository", repository);
	if (repository != null && distributed) {%>
		<html:text styleClass="expandText" property="build_filename" size="70" styleId="build_filename"/>
<% 	} else {%>
		<html:select property="build_filename" styleId="build_filename">
			<html:optionsCollection property="xmlFileCollection" />
		</html:select>
<% 	} %>
		<script type="text/javascript">
			function showBuildFile() {
				var url = contextPath + "/proj/build/showBuildFile.do?proj_id=${project.id}";
				var el = document.getElementById("build_filename");
				var buildFileName = el.value;
				if (buildFileName == "" || buildFileName == null) {
					alert("Please select/enter a build-file first!");
					return false;
				}
				url += "&buildFileName=" + escape(buildFileName);
				launch_url(url);
				return false;
			}
		</script>

		&nbsp;&nbsp;
		<spring:message var="scriptTitle" code="build.file.contents.tooltip" text="View the content of this build file in a popup."/>
		<a href="#" onclick="return showBuildFile();" target="_blank" title="${scriptTitle}"><spring:message code="build.file.contents.label" text="View"/></a>
	</td>
</TR>

<spring:message var="targetsTitle" code="build.targets.tooltip" />
<TR title="${targetsTitle}">
	<TD CLASS="optional"><spring:message code="build.targets.label" text="Ant Targets"/>:</TD>
	<TD CLASS="expandText"><html:text styleClass="expandText" property="targets" size="70" /></TD>
</TR>

<spring:message var="propertiesTitle" code="build.properties.tooltip" />
<TR TITLE="${propertiesTitle}" VALIGN="top">
	<TD CLASS="optional"><spring:message code="build.properties.label" text="Ant Properties"/>:</TD>
	<TD CLASS="expandTextArea"><html:textarea styleClass="expandTextArea" property="properties"	rows="5" cols="70" /></TD>
</TR>

<TR>
	<TD class="optional"><spring:message code="build.status.label" text="Status"/>:</TD>
	<TD><html:checkbox property="status" /> <spring:message code="build.status.enabled" text="Enabled"/></TD>
</TR>

<%--
<TR VALIGN="top">
	<TD class="optional" >Ant Class path:</TD>

	<TD><html:textarea property="classpath" rows="5" cols="70" /></TD>
</TR>
--%>

<TR>
	<TD COLSPAN="<%=colspan%>">
		<spring:message var="schedulerTitle" code="build.schedule.title" text="Build Scheduler"/>
		<ui:title style="top-sub-headline-decoration" header="${schedulerTitle}" topMargin="10" />
	</TD>
</TR>

<%-- since CB-5.7 repository synchronization is independent of builds
<TR>
	<TD class="optional"><spring:message code="build.synchronization.label" text="Synchronization"/>:</TD>

	<TD>
		<html:checkbox property="synchronization" />
		<spring:message code="build.synchronization.tooltip" text="Synchronize with source code repository before build is started"/>
	</TD>
</TR>
--%>

<%--
	Modified the fields : for Metrics Option and the run Build periodically.
--%>

<spring:message var="scheduleTitle" code="build.schedule.tooltip"/>
<TR TITLE="${scheduleTitle}" VALIGN="TOP">
	<TD CLASS="optional"><spring:message code="build.schedule.label" text="Scheduler"/>:</TD>
	<TD>
		<tag:formatDate var="nextRunDate" value="${startBuildDate}" />
		<html:radio property="server_run" value="period" />
		<spring:message code="build.schedule.periodically" arguments="${nextRunDate}"/>
		<P>
		<html:radio property="server_run" value="every" />
		<spring:message code="build.schedule.every.label" text="Run this build every"/>
		<html:text  property="build_interval" size="2" maxlength="3" />&nbsp;
		<spring:message code="build.schedule.every.hours" text="hours"/>
		<P>
		<html:checkbox property="server_run_after_commit" />
		<spring:message code="build.schedule.after.label" text="Run this build after"/>
		<html:text  property="delay_after_commit" size="3" maxlength="4" />&nbsp;
		<spring:message code="build.schedule.after.commit" text="minutes of last Source-Code Commit"/>
	</TD>
</TR>

<TR>
	<TD COLSPAN="<%=colspan%>">
		<spring:message var="notificationTitle" code="build.notification.title" text="Build Notification Forums"/>
		<ui:title style="top-sub-headline-decoration" header="${notificationTitle}" topMargin="10" />
	</TD>
</TR>

<TR>
	<TD class="optional"><spring:message code="build.onSuccess.label" text="On Success"/>:</TD>

	<TD NOWRAP>&nbsp;
		<html:select property="success_notif_forum_id">
			<html:optionsCollection property="forumCollection" />
		</html:select>
	</TD>
</TR>

<TR>
	<TD class="optional"><spring:message code="build.onError.label" text="On Error"/>:</TD>

	<TD NOWRAP>&nbsp;
		<html:select property="failed_notif_forum_id">
			<html:optionsCollection property="forumCollection" />
		</html:select>
	</TD>
</TR>

<TR>
	<TD COLSPAN="<%=colspan%>">
		<spring:message var="metricsTitle" code="build.metrics.title" text="Project Statistics and Metrics"/>
		<ui:title style="top-sub-headline-decoration" header="${metricsTitle}" topMargin="10" />
	</TD>
</TR>

<TR>
	<TD class="optional"><spring:message code="build.metrics.label" text="Update"/>:</TD>

	<TD>
		<html:checkbox property="metrics_run" />
		<spring:message code="build.metrics.tooltip" text="Update Project statistics and metrics after this build"/>
	</TD>
</TR>

<%--
<TR>
	<TD WIDTH="600" CLASS="tdf" COLSPAN="2">
		CodeBeamer will additional set the <STRONG>Properties</STRONG> as follows:
		<STRONG>CB_HOME</STRONG>,<STRONG>CB_PROJ_ID</STRONG>,<STRONG>CB_PROJECT</STRONG>,
		<STRONG>CB_SRCDIR</STRONG>,<STRONG>CB_DOCDIR</STRONG>,<STRONG>CB_KIT_ID</STRONG>,
		<STRONG>CB_JDBC_DRIVER</STRONG>,<STRONG>CB_JDBC_URL</STRONG>,
		<STRONG>CB_JDBC_USER</STRONG> and <STRONG>CB_JDBC_PASSWORD</STRONG>.
	</TD>
</TR>
--%>

</TABLE>

</html:form>

<%--
<BR><STRONG>Target Release Kit:</STRONG> After a successful build, this value will be
used by the Ant task <STRONG>CBRelease</STRONG> (this task is already a known
Ant task, when the build is executed by CodeBeamer) to create a new Release.
--%>

<br/>
<div class="descriptionBox">
	<spring:message code="build.tasks.tooltip"/>
</div>
