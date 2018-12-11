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
 * $Revision:20171 $ $Date:2007-09-05 20:45:54 +0200 (Mi, 05 Sep 2007) $
--%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="acltaglib" prefix="acl" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<SCRIPT LANGUAGE="JavaScript" type="text/javascript">
<!-- Hide script from old browsers
function confirmDeleteLog(form) {
	var answer = submitIfSelected(form, 'log_id');
	if (answer) {
		return confirm('<spring:message code="build.logs.delete.confirm" />');
	}
	return false;
}
// -->
</SCRIPT>

<acl:isUserInRole var="isAdmin" value="${applicationScope.PERMISSION_BUILD_ADMIN}" />

<ui:showErrors />

<c:set var="buildId" value="${param.build_id}" />
<%--
<tag:buildLogList var="logs" build_id="${buildId}" />
--%>
<c:set var="builds" value="${requestScope.builds}" />

<spring:message var="toggleButton" code="search.what.toggle" text="Select/Clear All"/>

<c:set var="checkAll">
	<INPUT TYPE="CHECKBOX" TITLE="${toggleButton}" NAME="SELECT_ALL" VALUE="on"	ONCLICK="setAllStatesFrom(this, 'log_id')" class="noPrint"></INPUT>
</c:set>

<html:form action="/proj/build/listAndDeleteLogItems">

<html:hidden property="build_id" value="${buildId}" />

<div class="actionBar">
	<script LANGUAGE="JavaScript" type="text/javascript">
		function viewLogsOf(build_id) {
			if (build_id != "") {
				// alert("viewing logs of build_id=" + build_id);
				document.location.href= contextPath + "/proj/build.do?build_id=" + build_id + "&orgDitchnetTabPaneId=build-logs";
			}
		}
	</script>

	<spring:message code="build.logs.select.title" text="Viewing logs of:"/> &nbsp;
	<select id="buildSelector" onchange="viewLogsOf(this.value);" style="min-width: 10em;">
		<option value=""><spring:message code="build.logs.select.label" text="Select a build..."/></option>
		<c:forEach items="${builds}" var="build" >
			<option value="${build.id}"
				<c:if test="${build.id eq buildId}">
					selected="selected"
					<c:set var="selectedBuildName" value="${build.name}" />
				</c:if>
			>
				<spring:message code="build.${build.name}.label" text="${build.name}"/>
			</option>
		</c:forEach>
	</select>

	<c:if test="${! empty buildId}">
		&nbsp;
		<spring:message var="refreshButton" code="build.logs.refresh.label" text="Refresh"/>
		<input type="button" class="button" value="${refreshButton}" onclick="viewLogsOf(document.getElementById('buildSelector').value);" />

		<c:if test="${isAdmin}">
			&nbsp;&nbsp;
			<spring:message var="deleteTitle" code="build.logs.delete.tooltip" text="Delete selected logs"/>
			<html:submit styleClass="button" property="DELETE" title="${deleteTitle}" onclick="return confirmDeleteLog(this.form);">
				<spring:message code="button.delete"/>
			</html:submit>
		</c:if>
	</c:if>
</div>

<div class="onlyInPrint">
	<c:if test="${! empty selectedBuildName}">
		<spring:message code="build.logs.select.title" text="Viewing logs of:"/>&nbsp;<b>${selectedBuildName}</b>
	</c:if>
</div>

<c:if test="${! empty buildId}">

<display:table requestURI="/proj/build.do?orgDitchnetTabPaneId=build-logs" name="${logs}" id="log" cellpadding="0"
	defaultsort="6" pagesize="20" defaultorder="descending" export="true">

	<ui:actionGenerator builder="buildLogActionMenuBuilder" actionListName="buildLogActions" subject="${log}" >

		<display:column title="${checkAll}" decorator="com.intland.codebeamer.ui.view.table.TrimmedColumnDecorator" media="html" class="noPrint">
			<c:if test="${isAdmin}">
				<html:checkbox property="log_id" value="${log.id}" />
			</c:if>
		</display:column>

		<display:column media="excel xml csv pdf rtf" title="Build Name" property="build.name" sortable="true" />

		<spring:message var="nameTitle" code="build.name.label" text="Build Name"/>
		<display:column title="${nameTitle}" media="html" sortProperty="build.name" sortable="true"	headerClass="textData expand" class="textData">
			<c:set var="customizeAction" value="${buildLogActions.customizeBuild}" />
			<spring:message var="customizeTitle" code="${customizeAction.toolTip}"/>
			<html:link title="${customizeTitle}" href="${customizeAction.url}"><spring:message code="build.${log.build.name}.label" text="${log.build.name}"/></html:link>
		</display:column>

		<display:column media="html" class="action-column-minwidth columnSeparator">
			<ui:actionMenu actions="${buildLogActions}"/>
		</display:column>

		<c:choose>
			<c:when test="${log.status == 'Successful' || log.status == 'SUCCESSFUL'}">
				<c:set var="statusStyle" value="STATUS_SUCCESSFUL" />
			</c:when>

			<c:otherwise>
				<c:set var="statusStyle" value="STATUS_FAILED" />
			</c:otherwise>
		</c:choose>

		<spring:message var="statusTitle" code="build.run.status.label" text="Status"/>
		<display:column media="html" title="${statusTitle}" sortProperty="status" sortable="true"
			headerClass="textData" class="textData ${statusStyle} columnSeparator" >
			<c:set var="viewLogAction" value="${buildLogActions.viewLog}" />
			<spring:message var="viewLogTitle" code="${viewLogAction.toolTip}"/>
			<html:link title="${viewLogTitle}" onclick="${viewLogAction.onClick}" href="${viewLogAction.url}">
				<spring:message code="build.run.status.${log.status}" text="${log.status}"/>
			</html:link>
		</display:column>

		<display:column media="excel xml csv pdf rtf" title="${statusTitle}" property="status" sortable="true" />

		<spring:message var="startTitle" code="build.run.startDate.label" text="Start Date"/>
		<display:column title="${startTitle}" sortProperty="startDate" headerClass="dateData" class="dateData columnSeparator" sortable="true" media="html">
			<tag:formatDate value="${log.startDate}" />
		</display:column>

		<display:column title="${startTitle}" property="startDate" media="excel xml csv pdf rtf" />

		<spring:message var="endTitle" code="build.run.endDate.label" text="End Date"/>
		<display:column title="${endTitle}" sortProperty="endDate" headerClass="dateData" class="dateData" sortable="true"	media="html">
			<tag:formatDate value="${log.endDate}" />
		</display:column>

		<display:column title="${endTitle}" property="endDate" media="excel xml csv pdf rtf" />
	</ui:actionGenerator>
</display:table>

<br/>
<div class="explanation" style="width:70%;">
	<c:url var="newBuildUrl" value="/proj/build/addBuild.do"/>
	<c:url var="documentsUrl" value="/proj/doc.do"/>
	<spring:message code="build.tooltip" arguments="${newBuildUrl},${documentsUrl}"/>
</div>

</c:if>

</html:form>



