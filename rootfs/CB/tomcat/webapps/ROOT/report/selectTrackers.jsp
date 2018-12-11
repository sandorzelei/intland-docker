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
--%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-logic" prefix="logic" %>

<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<%@ taglib uri="acltaglib" prefix="acl" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<meta name="decorator" content="main"/>
<meta name="module" content="${module}"/>
<meta name="moduleCSSClass" content="newskin ${moduleCSSClass}"/>

<c:set var="doc_id" value="-1" />
<spring:message var="title" code="report.create.${CMDB ? 'item' : 'issue'}.title"/>
<c:if test="${!empty param.doc_id}">
	<c:set var="doc_id" value="${param.doc_id}" />
	<spring:message var="title" code="report.edit.${CMDB ? 'item' : 'issue'}.title"/>
</c:if>
<spring:message var="trackerType" code="${CMDB ? 'cmdb.categories' : 'tracker.list'}.label"/>

<ui:actionMenuBar>
		<ui:breadcrumbs showProjects="false"><span class='breadcrumbs-separator'>&raquo;</span>
			<ui:pageTitle prefixWithIdentifiableName="false"><spring:message code="report.step3.title" text="{0} - Step 3 : Select {1}" arguments="${title},${trackerType}"/></ui:pageTitle>
		</ui:breadcrumbs>
</ui:actionMenuBar>

<html:form action="/proj/report/selectTrackers">

<html:hidden property="page" value="3" />
<html:hidden property="proj_id" />
<html:hidden property="dir_id" />

<ui:actionBar>
	<html:submit styleClass="button" property="PREVIOUS">
		<spring:message code="button.back" text="&lt; Back"/>
	</html:submit>
	&nbsp;&nbsp;
	<html:submit styleClass="button" property="NEXT">
		<spring:message code="button.goOn" text="Next &gt;"/>
	</html:submit>
	&nbsp;&nbsp;
	<html:cancel styleClass="cancelButton">
		<spring:message code="button.cancel" text="Cancel"/>
	</html:cancel>
</ui:actionBar>

<ui:showErrors />

<c:set var="form" value="${addUpdateTrackerReportForm}" />
<c:set var="trackers" value="${form.availableTrackers}" />

<c:if test="${doc_id != -1}">
	<html:hidden property="doc_id" value="${doc_id}" />
</c:if>

<spring:message var="toggleButton" code="search.what.toggle" text="Select/Clear All"/>
<c:set var="checkAll">
	<input type="checkbox" title="${toggleButton}" name="select_all" value="on" onclick="setAllStatesFrom(this, 'trackerId')">
</c:set>

<display:table id="tracker" name="${trackers}" export="false" cellpadding="0">

	<spring:message var="projectTitle" code="project.label" text="Project"/>
	<display:column title="${projectTitle}" property="project.name" sortable="false" media="html" headerClass="textData" class="textData columnSeparator" group="1" />

	<display:column title="${checkAll}" sortable="false" media="html" headerClass="checkbox-column-minwidth" class="checkbox-column-minwidth columnSeparator">
		<html:checkbox property="trackerId(${tracker.id})" value="${tracker.id}" />
	</display:column>

	<spring:message var="trackerTitle" code="${CMDB ? 'cmdb.category' : 'tracker'}.label" />
	<display:column title="${trackerTitle}" sortable="false" media="html" headerClass="textData" class="textData columnSeparator">
		<spring:message code="tracker.${tracker.name}.label" text="${tracker.name}" htmlEscape="true"/>
	</display:column>

	<spring:message var="typeTitle" code="tracker.type.label" />
	<display:column title="${typeTitle}" sortable="false" media="html" headerClass="textData" class="textData">
		<spring:message code="tracker.type.${tracker.type.name}" text="${tracker.type.name}"/>
	</display:column>

</display:table>

<%-- Disable any other selected trackers --%>
<c:forEach items="${form.trackerIds}" var="id">
<html:hidden property="trackerId(${id})" value="false" />
</c:forEach>

</html:form>
