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
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab" %>

<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>

<%@ page import="com.intland.codebeamer.taglib.TableCellCounter"%>
<%@ page import="java.util.List"%>
<%@ page import="com.intland.codebeamer.persistence.util.TrackerItemFieldHandler" %>
<%@ page import="com.intland.codebeamer.controller.ControllerUtils" %>
<%@ page import="com.intland.codebeamer.persistence.dto.TrackerItemRevisionDto"%>
<%@ page import="com.intland.codebeamer.persistence.dto.TrackerItemDto"%>
<%@ page import="com.intland.codebeamer.ui.view.table.TrackerSimpleLayoutDecorator" %>

<meta name="decorator" content="main"/>
<meta name="module" content="project_browser"/>
<meta name="moduleCSSClass" content="projectModule newskin"/>

<style type="text/css">
	.preview-tab-container {
   		margin: 15px;
	}

	.trackerItems .textSummaryData {
		min-width: 250px;
	}

	.trackerItems .textDataWrap {
		max-width: 350px;
		min-width: 250px;
		white-space: normal !important;
		word-wrap: break-word !important;
	}

	.ditch-tab-pane-wrap{
		border: none !important;
	}

</style>

<ui:actionMenuBar>
	<ui:pageTitle><spring:message code="project.creation.reqif.preview" text="Create New Project - Reqif Import Preview"/></ui:pageTitle>
</ui:actionMenuBar>

<form:form action="${flowUrl}">
	<ui:actionBar>
		<input type="submit" class="hidden" name="_eventId_finish" value="Finish" style="display:none;"/>

		<spring:message var="nextButton" code="button.goOn" text="Next &gt;"/>
		&nbsp;&nbsp;<input type="submit" id="nextButton" class="button" name="_eventId_submit" value="${nextButton}" />

		<spring:message var="backButton" code="button.back" text="&lt; Back"/>
		<input type="submit" class="linkButton button" name="_eventId_back" value="${backButton}" />

		<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>
		<input type="submit" class="cancelButton" name="_eventId_cancel" value="${cancelButton}" />
	</ui:actionBar>
	<form:errors cssClass="error"/>
</form:form>

<div class="preview-tab-container">
	<tab:tabContainer id="preview-details" skin="cb-box" >

		<c:forEach items="${reqifTrackerlist}" var="trackerPreview">
		    <c:set var="trackerConfig" value="${trackerPreview.key}"/>
		    <c:set var="tracker" value="${trackerConfig.tracker}"/>

		    <tab:tabPane id="tracker-${tracker.name}" tabTitle="${tracker.name}">
				<c:set var="trackerItemList" value="${trackerPreview.value}"/>
				<c:set var="showIndent" value="false"/>

				<div class="tab-content">
					<bugs:displaytagTrackerItems layoutList="${trackerConfig.fields}" items="${trackerPreview.value}"
						pagesize="60" browseTrackerMode="true" export="false" selection="false" decorator="${reqifDecorator}"/>
				</div>
			</tab:tabPane>
		</c:forEach>

	</tab:tabContainer>
</div>



