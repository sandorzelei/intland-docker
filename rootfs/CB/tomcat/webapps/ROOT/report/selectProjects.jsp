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
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-logic" prefix="logic" %>

<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<%@ taglib uri="acltaglib" prefix="acl" %>
<%@ taglib uri="taglib" prefix="tag" %>
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

<c:set var="form" value="${addUpdateTrackerReportForm}" />
<c:set var="projects" value="${form.availableProjects}" />

<html:form action="/proj/report/selectProjects">

	<html:hidden property="page" value="2" />
	<html:hidden property="proj_id" />
	<html:hidden property="dir_id" />
	<c:if test="${doc_id != -1}">
		<html:hidden property="doc_id" value="${doc_id}" />
	</c:if>

	<c:set var="actionMenuBodyPart">
			<ui:breadcrumbs showProjects="false"><span class='breadcrumbs-separator'>&raquo;</span>
				<ui:pageTitle prefixWithIdentifiableName="false"><spring:message code="report.step2.title" text="{0} - Step 2" arguments="${title}"/></ui:pageTitle>
			</ui:breadcrumbs>
	</c:set>
	<c:set var="actionMenuRightPart">
		<span class="filterForm">
			<label>
				<spring:message code="project.category.label" text="Category"/>
				<spring:message var="categoryTitle" code="project.category.filter" text="Filter projects by Category"/>
				<html:select property="projectCategoryFilter" title="${categoryTitle}">
					<html:optionsCollection property="categories" />
				</html:select>
			</label>

			<label>
				<%--Filter --%>
				<spring:message var="filterTitle" code="project.name.filter" text="Filter projects by name"/>
				<html:text styleId="projectFilter" property="projectFilter" title="${filterTitle}"/>
			</label>

			<spring:message var="filterHint" code="filter.input.box.hint" text="Filter..."/>
			<script type="text/javascript">
				applyHintInputBox("#projectFilter", "${filterHint}");
			</script>

			<spring:message var="filterButton" code="search.submit.tooltip" text="Apply filters"/>
			<html:submit styleClass="button" property="ITEMFILTER" title="${filterButton}">
				<spring:message code="search.submit.label" text="GO"/>
			</html:submit>
		</span>
	</c:set>
<ui:actionMenuBar>
	<jsp:attribute name="rightAligned">${actionMenuRightPart}</jsp:attribute>
	<jsp:body>${actionMenuBodyPart}</jsp:body>
</ui:actionMenuBar>

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

	<spring:message var="toggleButton" code="search.what.toggle" text="Select/Clear All"/>
	<c:set var="checkAll">
		<input type="checkbox" title="${toggleButton}" name="select_all" value="on"	onclick="setAllStatesFrom(this, 'selectedProjectId')">
	</c:set>

	<display:table requestURI="/proj/report/selectProjects.do" excludedParams="*" name="${projects}" id="project" cellpadding="0"
		export="false" defaultsort="2" decorator="com.intland.codebeamer.ui.view.table.ProjectSelectorDecorator">

		<display:column title="${checkAll}" media="html" headerClass="checkbox-column-minwidth" class="checkbox-column-minwidth" sortable="false">
			<html:checkbox property="selectedProjectId(${project.id})" value="true" />
			<html:hidden property="selectedProjectId(${project.id})" value="false"/>
		</display:column>

		<spring:message var="projectTitle" code="project.label" text="Project" />
		<display:column title="${projectTitle}" property="name" sortProperty="sortName" sortable="true" media="html" headerClass="textData" class="textData columnSeparator" />

		<spring:message var="categoryTitle" code="project.category.label" text="Category"/>
		<display:column title="${categoryTitle}" headerClass="textData" class="textData columnSeparator" sortable="false">
			<spring:message code="project.category.${project.category}.label" text="${project.category}"/>
		</display:column>

		<spring:message var="createdTitle" code="project.createdAt.label" text="Created"/>
		<display:column title="${createdTitle}" sortProperty="createdAt" headerClass="dateData" class="dateData" sortable="false" media="html xml csv pdf rtf">
			<tag:formatDate value="${project.createdAt}" />
		</display:column>
	</display:table>

</html:form>

