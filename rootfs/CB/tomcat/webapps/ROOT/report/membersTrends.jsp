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

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="charttaglib" prefix="chart" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<chart:query name="projectTrends" var="data">
	<chart:param name="proj_id" value="${proj_id}" className="java.util.ArrayList" />
	<chart:param name="startDate">
		<fmt:formatDate value="${startDate}" pattern="${formatDatePattern}" />
	</chart:param>
	<chart:param name="closeDate">
		<fmt:formatDate value="${closeDate}" pattern="${formatDatePattern}" />
	</chart:param>
</chart:query>

<%-- Create Chart --%>
<spring:message var="chartTitle" code="project.membersTrends.chart.title" text="Members by Date"/>
<spring:message var="chartYAxis" code="project.membersTrends.chart.yaxis" text="Number of Members"/>

<chart:create var="chart" type="timeSeries" width="${whtd}" height="${hght}"
	legend="false" tooltips="false" title="${chartTitle}" yaxisLabel="${chartYAxis}" >

	<chart:dataset type="xy" value="${data}" categoryProperties="dtm" valueProperties="nr_usr" />

	<chart:axis createIntegerTickUnits="true" index="0" dateTickUnits="true" />
</chart:create>

