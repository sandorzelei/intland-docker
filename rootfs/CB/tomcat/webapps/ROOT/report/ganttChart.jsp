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
<meta name="decorator" content="main"/>
<meta name="module" content="tracker"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<%@ taglib uri="charttaglib" prefix="chart" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="acltaglib" prefix="acl" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<%@ page import="com.intland.codebeamer.persistence.dto.TrackerDto"%>
<%@ page import="com.intland.codebeamer.persistence.dto.TrackerItemDto"%>
<%@ page import="com.intland.codebeamer.persistence.dto.TrackerLayoutLabelDto"%>

<%
	pageContext.setAttribute("CATEGORY_LABEL_ID", new Integer(TrackerLayoutLabelDto.CATEGORY_LABEL_ID));
	pageContext.setAttribute("ASSIGNED_TO_LABEL_ID", new Integer(TrackerLayoutLabelDto.ASSIGNED_TO_LABEL_ID));
	pageContext.setAttribute("TASK_TRACKER", new Integer(TrackerDto.TASK), PageContext.REQUEST_SCOPE);
%>

<style type="text/css">
<!--
.gantt_complete {
	background-color: black;
}

.gantt_incomplete {
	background-color: #ff9700;
}
-->
</style>

<c:set var="geometry" value="${param.geometry}" />
<c:choose>
	<c:when test="${geometry == 'tight'}">
		<c:set var="whtd" value="700" />
	</c:when>

	<c:when test="${geometry == 'wide'}">
		<c:set var="whtd" value="900" />
	</c:when>

	<c:when test="${geometry == 'extra_wide'}">
		<c:set var="whtd" value="1400" />
	</c:when>

	<c:otherwise>
		<c:set var="whtd" value="800" />
	</c:otherwise>
</c:choose>

<c:set var="user" value="${pageContext.request.userPrincipal}" />

<c:set var="dateFormattingPattern" value="${user.datePattern}" />

<c:forEach items="${paramValues.proj_id}" var="proj_id" varStatus="for_status">
	<c:set var="projIds" value="${projIds}${proj_id}" />
	<c:if test="${!for_status.last}">
		<c:set var="projIds" value="${projIds}," />
	</c:if>
</c:forEach>

<c:if test="${empty projIds}">
	<c:set var="projIds" value="${param.projIds}" />

	<c:if test="${empty projIds}">
		<c:set var="projIds" value="${PROJECT_DTO.id}" />
	</c:if>
</c:if>

<tag:project var="projects" projectId="${projIds}" list="true" />

<ui:actionMenuBar>
		<ui:pageTitle>Gantt Tasks</ui:pageTitle> in Projects:
		<c:forEach items="${projects}" var="project" varStatus="for_status">
			<html:link page="/project/${project.id}" >
				<c:out value="${project.name}" />
			</html:link>
			<c:if test="${!for_status.last}">,</c:if>
		</c:forEach>
</ui:actionMenuBar>

<c:set var="action" value="${param.action}" />
<c:if test="${empty action}">
	<c:set var="action" value="/report/ganttChart.do" />
</c:if>

<ui:showErrors />

<html:form action="${action}">

<html:hidden property="action" />

<c:forTokens items="${projIds}" delims="," var="pid">
	<html:hidden property="proj_id" value="${pid}" />
</c:forTokens>

<TABLE BORDER="0" class="formTableWithSpacing" CELLPADDING="0">

<jsp:useBean id="ganttChartForm" class="com.intland.codebeamer.servlet.report.GanttChartForm" scope="session" />

<%
	ganttChartForm.setInitValues(request);
%>

<c:set var="orderBy" value="${ganttChartForm.map.orderBy}" />
<c:if test="${empty orderBy}">
	<c:set var="orderBy" value="start_date" />
</c:if>
<c:set var="assigned_to" value="${ganttChartForm.map.assigned_to}" />
<c:set var="status" value="${ganttChartForm.map.status}" />
<c:set var="category" value="${ganttChartForm.map.category}" />
<c:set var="timeDependency" value="${ganttChartForm.map.timeDependency}" />

<c:set var="parseDatePattern" value="yyyy-MM-dd" />
<c:set var="formatDatePattern" value="yyyyMMdd" />

<c:catch>
	<fmt:parseDate var="startDate" value="${ganttChartForm.map.startDate}"
		pattern="${parseDatePattern}" parseLocale="en" />
</c:catch>

<c:catch>
	<fmt:parseDate var="closeDate" value="${ganttChartForm.map.closeDate}"
		pattern="${parseDatePattern}" parseLocale="en" />
</c:catch>

<TR>
	<TD class="optional">Period Start:</TD>

	<TD NOWRAP VALIGN="top">
		<html:text property="startDate" size="12" styleId="startDate"/>
		<ui:calendarPopup textFieldId="startDate" otherFieldId="closeDate"/>
	</TD>

	<TD class="optional">Period End:</TD>

	<TD NOWRAP VALIGN="top" COLSPAN="2">
		<html:text property="closeDate" size="12" styleId="closeDate"/>
		<ui:calendarPopup textFieldId="closeDate" otherFieldId="startDate"/>
</TR>

<TR>
	<TD class="optional">Assigned to:</TD>

	<TD><html:select styleClass="fixSelectWidth" property="assigned_to">
		<html:optionsCollection property="assigneeList" />
		</html:select>
	</TD>

	<TD class="optional">Status:</TD>

	<TD><html:select styleClass="fixSelectWidth" property="status">
		<html:optionsCollection property="statusList" />
		</html:select>
	</TD>

	<TD class="optional">Category:</TD>

	<TD><html:select styleClass="fixSelectWidth" property="category">
		<html:optionsCollection property="categoryList" />
		</html:select>
	</TD>
</TR>

<TR>
	<TD class="optional">Order By:</TD>

	<TD><html:select styleClass="fixSelectWidth" property="orderBy" value="${orderBy}">
			<html:option value="category">Category</html:option>
<!--
			<html:option value="assigned_to_account">Assigned To</html:option>
-->
			<html:option value="id">ID</html:option>
			<html:option value="start_date">Start Date</html:option>
			<html:option value="edn_date">End Date</html:option>
			<html:option value="complete">Complete</html:option>

		</html:select>
	</TD>

	<TD class="optional">Schedule:</TD>

	<TD><html:select styleClass="fixSelectWidth" property="timeDependency">
		<html:optionsCollection property="timeDependentList" />
		</html:select>
	</TD>

	<TD class="optional">Geometry:</TD>

	<TD><html:select styleClass="fixSelectWidth" property="geometry">
			<html:option value="tight">Tight</html:option>
			<html:option value="normal">Normal</html:option>
			<html:option value="wide">Wide</html:option>
			<html:option value="extra_wide">Extra wide</html:option>
		</html:select>
	</TD>
</TR>

<TR>
	<TD NOWRAP>&nbsp;&nbsp;<html:submit styleClass="button" property="GO" value="GO" />
	</TD>
</TR>

</TABLE>

</html:form>

<c:set var="summaryLength" value="30" />

<chart:query name="ganttChart" var="tasks">
	<chart:param name="summaryLength" value="${summaryLength}" />
	<chart:param name="category_label_id" value="${CATEGORY_LABEL_ID}" />
	<chart:param name="assigned_to_label_id" value="${ASSIGNED_TO_LABEL_ID}" />
	<chart:param name="tracker_type" value="${TASK_TRACKER}" />
	<chart:param name="proj_id" value="${projIds}" className="java.util.ArrayList" />
	<chart:param name="onlyAvailableTrackerItems" value="true" />
	<chart:param name="user" value="${user}" />
	<chart:param name="timeDependency">
	<c:choose>
		<c:when test="${empty timeDependency || timeDependency == '#'}" />
		<c:otherwise>
			<chart:param name="timeDependency" value="${timeDependency}" />
		</c:otherwise>
	</c:choose>
	</chart:param>
	<chart:param name="startDate">
		<fmt:formatDate value="${startDate}" pattern="${formatDatePattern}" />
	</chart:param>
	<chart:param name="closeDate">
		<fmt:formatDate value="${closeDate}" pattern="${formatDatePattern}" />
	</chart:param>
	<c:choose>
		<c:when test="${empty status || status == '#'}" />
		<c:when test="${status == 'NULL'}">
			<chart:param name="status" value="NULL" />
		</c:when>
		<c:when test="${fn:startsWith(status, '-')}">
			<chart:param name="status" value="${fn:substring(status, 1, -1)}" />
			<chart:param name="notStatus" value="true" />
		</c:when>
		<c:otherwise>
			<chart:param name="status" value="${status}" />
		</c:otherwise>
	</c:choose>
	<c:choose>
		<c:when test="${empty category || category == '#'}" />
		<c:when test="${category == 'NULL'}">
			<chart:param name="category" value="NULL" />
		</c:when>
		<c:otherwise>
			<chart:param name="category" value="${category}" />
		</c:otherwise>
	</c:choose>
	<c:choose>
		<c:when test="${empty assigned_to || assigned_to == '#'}" />
		<c:when test="${assigned_to == 'NULL'}">
			<chart:param name="assigned_to" value="NULL" />
		</c:when>
		<c:otherwise>
			<chart:param name="assigned_to" value="${assigned_to}" />
		</c:otherwise>
	</c:choose>
	<chart:param name="orderBy" value="${orderBy}"/>
</chart:query>

<bean:size id="nr_of_tasks" name="tasks" />
<c:set var="hght" value="${60 + nr_of_tasks * 20}" />

<c:url var="urlPrefix" value="<%=TrackerItemDto.ISSUE_RESOURCE_PREFIX%>" />

<P>

<html:img border="0" page="/images/space.gif" width="16" height="10"
	styleClass="gantt_incomplete" /> Task remaining
<html:img border="0" page="/images/space.gif" width="16" height="10"
	styleClass="gantt_complete" /> Task done
<BR>

<%-- Create Chart --%>
<chart:create var="chart" type="gantt" width="${whtd}" height="${hght}"
	title="Gantt Chart"
	legend="false" tooltips="true" urls="true">

	<chart:dataset type="gant" value="${tasks}"
		categoryProperties="summary" valueProperties="start_date;close_date;percentage;task_id"
			seriesLabels="Tasks"
			URLprefix="${urlPrefix}" URLparams="task_id"
			tooltipDateFormat="${dateFormattingPattern}" />
<%--
	<chart:axis verticalTickLabels="${verticalTickLabels}"
		dateFormatOverride="${dateFormattingPattern}" dateTickUnits="true" />
--%>
	<chart:axis categoryLabelAlignLeft="true" dateTickUnits="true" axisOffset="0.0,0.0,10.0,10.0" />

	<chart:renderer series="0" paint="gray"
		seriesOutlinePaint="white" completePaint="black" incompletePaint="#FF9900" />
</chart:create>

