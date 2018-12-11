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
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib prefix="bugs" uri="bugstaglib" %>

<meta name="decorator" content="main"/>
<meta name="module" content="${empty tracker.parent.id ? (tracker.category ? 'cmdb' : 'tracker') : 'docs'}"/>
<meta name="moduleCSSClass" content="newskin trackersModule"/>

<bugs:branchStyle branch="${tracker }"/>

<ui:actionMenuBar>
	<ui:breadcrumbs showProjects="false"/>
	<span class="breadcrumbs-summary  tail">
		<ui:pageTitle><span style="margin-left: 8px"><spring:message code="tracker.state.transition.chart.label" /></span></ui:pageTitle>
	</span>
</ui:actionMenuBar>

<ui:actionBar>
	<c:if test="${canCustomize}">
		<c:url var="customizeUrl" value="/proj/tracker/configuration.spr">
			<c:param name="tracker_id" value="${tracker.id}"/>
			<c:param name="orgDitchnetTabPaneId" value="tracker-customize-transitions"/>
		</c:url>

		<a class="actionLink" href="${customizeUrl}"><spring:message code="tracker.customize.label" text="Customize"/></a>
	</c:if>

	<a class="actionLink" href="<c:url value='${trackerLink}' />"><spring:message code="tracker.state.transition.chart.backTo.${trackerDefaultViewTypeName}.label" text="Browse Items"/></a>
</ui:actionBar>

<p />
<script type="text/javascript">
	function changeDistance(selector) {
		$('#stateTransitionChartContainer').load(contextPath + '/trackers/ajax/getTrackerStateTransitionDiagram.spr?readOnly=true&showObsolete=false&tracker_id=' + ${tracker.id} + '&distance=' + $("#stateTransitionChartDistanceSelector").val() + '&revision=${trackerRevision}', function( response, status, xhr ) {
		  if ( status == "error" ) {
		    var msg = "Sorry but there was an error: ";
		    $( "#error" ).html( msg + xhr.status + " " + xhr.statusText );
		  }
		});
	}
</script>

<spring:message var="chartTitle" code="tracker.state.transition.chart.label" text="Workflow Graph"/>
<div style="margin: 5px;">
	<fieldset id="stateTransitionChart" class="collapsingBorder collapsingBorder_expanded" style="margin-top: 24px">
		<legend class="collapsingBorder_legend" style="font-weight: bold;margin-left: 11px;">
			${chartTitle}
		</legend>
		<div class="collapsingBorder_content">
			<div class="distanceSelector" style="float: Right; position: relative; top: -24px; right: 10px; background-color: #ffffff; padding-left: 4px; padding-right: 4px;">
				<spring:message code="tracker.state.transition.chart.distance" text="Distance"/>:
	
				<select id="stateTransitionChartDistanceSelector" onchange="changeDistance(this);">
					<c:forEach begin="0" end="2" varStatus="status">
						<c:set var="selected" value=""/>
						<c:if test="${(empty param.distance ? 0 : param.distance) eq status.index}">
							<c:set var="selected" value="selected='selected'"/>
						</c:if>
						<option value="${status.index}" ${selected}>${status.index}</option>
					</c:forEach>
				</select>
			</div>
			
			<div id="stateTransitionChartContainer" style="margin: 5px;">
				${graphHtmlMarkup}
			</div>
		</div>
	</fieldset>
</div>
