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
<meta name="module" content="queries"/>
<meta name="moduleCSSClass" content="newskin queriesModule"/>

<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>
<%@ taglib uri="wysiwyg" prefix="wysiwyg" %>

<link rel="stylesheet" href="<ui:urlversioned value='/queries/queries.less' />" type="text/css" media="all" />

<script type="text/javascript" src="<ui:urlversioned value='/js/reportPage.js'/>"></script>

<wysiwyg:froalaConfig />

<ui:UserSetting var="newWindowTarget" setting="NEW_BROWSER_WINDOW_TARGET" />

<ui:actionMenuBar>
	<ui:pageTitle prefixWithIdentifiableName="false">
		<c:choose>
			<c:when test="${queryId gt 0}">
				<c:out value="${query.name}" />
			</c:when>
			<c:when test="${queryId eq 0}">
				<spring:message code="query.default.${defaultQueryName}.label" text="${defaultQueryName}"/>
			</c:when>
			<c:otherwise>
				<spring:message code="query.predefined.${query.name}.label" text="${query.name}"/>
			</c:otherwise>
		</c:choose>
	</ui:pageTitle>
</ui:actionMenuBar>
<input type="hidden" id="queryId" value="${queryId}">
<c:set var="isStarred" value="${fn:contains(starredIds, queryId)}"></c:set>

<c:set var="queryContainer">
	<div class="queryContainer">
		<div class="header">
			<div class="headerTop">
				<div class="title">
					<span class="name">
						<c:choose>
							<c:when test="${queryId gt 0}">
								<c:out value="${query.name}" />
							</c:when>
							<c:when test="${queryId eq 0}">
								<spring:message code="query.default.${defaultQueryName}.label" text="${defaultQueryName}"/>
							</c:when>
							<c:otherwise>
								<spring:message code="query.predefined.${query.name}.label" text="${query.name}"/>
							</c:otherwise>
						</c:choose>
					</span>

					<c:if test="${queryId > 0 and not isAnonymous}">
						<span id="querySettingContextMenu" class="settings"></span>
					</c:if>

					<c:if test="${editMode and not isAnonymous and isEditable}">
						<span class="buttons"><a href="#" id="saveButton"><spring:message code="button.save" text="Save"/></a></span>
					</c:if>

					<c:if test="${editMode and queryId > 0}">
						<span id="unsavedWarning" class="warning"><spring:message code="queries.unsaved.warning.label"/></span>
					</c:if>

					<c:if test="${queryId gt 0 and not empty query.description and not editMode}">
						<div class="queryDescription"><c:out value="${query.description}"/></div>
					</c:if>

				</div>
			</div>

			<%-- Disabled Query Condition Widget taglib --%>
			<%-- <ui:queryConditionWidget resultContainerId="queryResultTable" queryString="${queryString}" advancedMode="${advancedMode}"></ui:queryConditionWidget> --%>

			<jsp:include page="queryWidget.jsp"/>

		</div>
		<c:if test="${not isAnonymous}">
			<div id="queriesAccordion" class="accordion">
				<h4 class="search-title accordion-header opened"><span class="icon"></span><spring:message code="queries.my.queries.label" text="My Queries"/></h4>
				<div class="myQueriesAccordion accordion-content">
					<table class="queryListTable">
						<tr>
							<td class="predefinedColumn">
								<h3><spring:message code="queries.predefined.label" text="Predefined Queries"/></h3>
								<ul class="queryList">
									<c:forEach var="predefinedQuery" items="${predefinedQueries}">
										<li>
											<span class="image"><img src="${contextPath}${predefinedQuery.imageUrl}"></span>
											<span class="text" data-queryid="${predefinedQuery.id}"><spring:message code="query.predefined.${predefinedQuery.name}.label" text="${predefinedQuery.name}"/></span>
										</li>
									</c:forEach>
								</ul>
							</td>
							<td class="starredColumn">
								<h3><spring:message code="queries.my.starred.queries.label" text="My Starred Queries"/></h3>
								<ul class="queryList starredQueries">
									<c:forEach var="query" items="${starredQueries}">
										<fmt:formatDate var="lastModifiedAt" value="${query.lastModifiedAt}" pattern="${dataPattern}"/>
										<spring:message var="tooltip" code="queries.my.starred.queries.tooltip"  arguments="${query.owner};${lastModifiedAt}" argumentSeparator=";"/>
										<li title="${tooltip}">
											<span class="image" data-queryid="${query.id}" data-star="false"><img src="${contextPath}/images/newskin/action/star-active-12x12.png"></span>
											<span class="text" data-queryid="${query.id}">
												<c:choose >
													<c:when test="${fn:length(query.name) > 32}">
														<c:out value="${fn:substring(query.name, 0, 32)}"></c:out>...
													</c:when>
													<c:otherwise>
														<c:out value="${query.name}"></c:out>
													</c:otherwise>
												</c:choose>
											</span>
										</li>
									</c:forEach>
								</ul>
							</td>
						</tr>
					</table>
				</div>
			</div>
		</c:if>
		<div class="content">
			<div id="queryResultTable">
				<c:if test="${not empty errorMessage}">
					<ui:message type="error" isSingleMessage="true" containerId="globalMessages">
						<ul><li><c:out value="${errorMessage}" /> <spring:message code="query.cbQl.error.help" htmlEscape="false"/></li></ul>
					</ui:message>
				</c:if>
				<div class="contentWithMargins">
					<c:choose>
						<c:when test="${((not cbQlFromSession || not editMode) && not empty fn:trim(queryString) && !hasCurrentProject) || (not editMode && hasCurrentProject)}">
							<bugs:displaytagTrackerItems htmlId="trackerItems" layoutList="${layoutList}" items="${items}" export="false"
														 requestURI="${action}" browseTrackerMode="true" decorator="${decorator}" forceOpenInNewWindow="${newWindowTarget eq '_blank'}" 
														reportId="${queryId}" resizableColumns="${resizeableColumns}" disableResizableColumns="${not editMode}"/>
						</c:when>
						<c:when test="${editMode && hasCurrentProject}">
							<div class="information">
								<spring:message code="queries.search.notloaded" text="Please press GO button to execute the query"/>
							</div>
						</c:when>
						<c:when test="${not cbQlFromSession}">
							<div class="information">
								<spring:message code="queries.empty.query.alert" text="Please select some Query conditions or enter Query string!"/>
							</div>
						</c:when>
						<c:otherwise>
							<div class="information">
								<spring:message code="queries.search.notloaded" text="Please press GO button to execute the query"/>
							</div>
						</c:otherwise>
					</c:choose>
				</div>
			</div>
		</div>
	</div>
</c:set>

<c:choose>

<c:when test="${editMode}">

<ui:treeControl containerId="treePane" url="${pageContext.request.contextPath}/ajax/queries/getFields.spr" editable="false"
	populateFnName="codebeamer.ReportPage.populateFieldTree" disableContextMenu="true"/>

<div id="queriesPageContent">
	<ui:splitTwoColumnLayoutJQuery cssClass="layoutFullPage autoAdjustPanesHeight" disableCloserButtons="false" leftMinWidth="270">
		<jsp:attribute name="leftPaneActionBar">
			<ui:treeFilterBox treeId="treePane" cssStyle="margin-left:15px;width:38%;" disableNativeFiltering="true" disableEnter="true"/>
			<select class="fieldTypeSelector">
				<option value="all"><spring:message code="query.widget.all.types.label"/></option>
				<option value="choice"><spring:message code="query.widget.choice.label"/></option>
				<option value="member"><spring:message code="query.widget.member.label"/></option>
				<option value="reference"><spring:message code="query.widget.reference.label"/></option>
				<option value="date"><spring:message code="query.widget.date.label"/></option>
				<option value="text"><spring:message code="query.widget.text.label"/></option>
				<option value="number"><spring:message code="query.widget.number.label"/></option>
				<option value="duration"><spring:message code="query.widget.duration.label"/></option>
				<option value="table"><spring:message code="query.widget.table.label"/></option>
				<option value="bool"><spring:message code="tracker.field.valueType.bool.label"/></option>
				<option value="color"><spring:message code="tracker.field.valueType.color.label"/></option>
				<option value="url"><spring:message code="tracker.field.valueType.url.label"/></option>
			</select>
		</jsp:attribute>
		<jsp:attribute name="middlePaneActionBar">
			<ui:actionGenerator actionListName="actions" builder="reportPageActionMenuBuilder" subject="${queryId}">
				<ui:actionLink actions="${actions}" keys="newReport,findReports,exportReport${not isAnonymous and queryId gt 0 ? ',viewReport' : ''}"/>
			</ui:actionGenerator>
			<c:if test="${!isAnonymous && queryId > 0}">
				<a href="#" class="actionBarIcon actionBarIconWithLabel" title="<spring:message code="queries.subscribe.edit.subscription.label"/>" id="editSubscription" data-query-id="${queryId}" data-subscription-id="${empty existingSubscriptionId ? '' : existingSubscriptionId}"<c:if test="${empty existingSubscriptionId}"> style="display: none"</c:if>><spring:message code="queries.job.label" text="Job"/></a>
				<a href="#" class="actionBarIcon actionBarIconWithLabel" title="<spring:message code="queries.subscribe.query.label"/>" id="newSubscription"<c:if test="${not empty existingSubscriptionId}"> style="display: none"</c:if>><spring:message code="queries.job.label" text="Job"/></a>
			</c:if>
		</jsp:attribute>
		<jsp:attribute name="leftContent" >
			<div id="treePane" style="height: calc(100% - 26px);overflow:auto;"></div>
		</jsp:attribute>
		<jsp:body>
			${queryContainer}
		</jsp:body>
	</ui:splitTwoColumnLayoutJQuery>
</div>

<div id="aggregateFunctionDialog" title="<spring:message code="queries.summarize.title"/>" style="display:none">
	<ui:actionBar>
		<spring:message var="saveButton" code="button.ok" text="OK" />
		<spring:message var="cancelButton" code="button.cancel" text="Cancel" />

		<input type="submit" class="button okButton" name="save" value="${saveButton}" />
		<input type="submit" class="button cancelButton" name="cancel"
			value="${cancelButton}" />
	</ui:actionBar>
	<div class="warning computedFieldWarning"><spring:message code="queries.summarize.computed.warning"/></div>
	<table id="aggregateFunctionTable">
		<tr>
			<th style="width: 40%;"><spring:message code="queries.summarize.header.field" text="Field"/></th>
			<th style="width: 15%;"><spring:message code="queries.summarize.header.sum" text="Sum"/></th>
			<th style="width: 15%;"><spring:message code="queries.summarize.header.avg" text="Average"/></th>
			<th style="width: 15%;"><spring:message code="queries.summarize.header.max" text="Max"/></th>
			<th style="width: 15%;"><spring:message code="queries.summarize.header.min" text="Min"/></th>
		</tr>
		<tr>
			<td id="summaryFieldName"></td>
			<td><input type="checkbox" data-function="sum" value="value"></td>
			<td><input type="checkbox" data-function="avg" value="value"></td>
			<td><input type="checkbox" data-function="max" value="value"></td>
			<td><input type="checkbox" data-function="min" value="value"></td>
		</tr>
	</table>
</div>

<div id="fieldFormatDialog" title="<spring:message code="queries.contextmenu.format"/>" style="display:none">
	<ui:actionBar>
		<spring:message var="saveButton" code="button.ok" text="OK" />
		<spring:message var="cancelButton" code="button.cancel" text="Cancel" />

		<input type="submit" class="button okButton" name="save" value="${saveButton}" />
		<input type="submit" class="button cancelButton" name="cancel"
			value="${cancelButton}" />
	</ui:actionBar>
	<table id="fieldFormatTable">
		<tr>
			<th style="width: 40%;"><spring:message code="queries.summarize.header.field" text="Field"/></th>
			<th style="width: 20%;"><spring:message code="queries.format.type" text="Format"/></th>
			<th style="width: 40%;"><spring:message code="queries.format.decimals" text="Decimal Places"/></th>
		</tr>
		<tr>
			<td id="formatFieldName"></td>
			<td>
				<select id="numberFormat">
				    <option value="number"><spring:message code="queries.format.number" text="Number"/></option>
				    <option value="percent"><spring:message code="queries.format.percent" text="Percent"/></option>
				</select>
			</td>
			<td>
				<select id="decimalFormat">
					<% for(int i = 0; i < 4; i+=1) { %>
				        <option value="<%= i %>"><%= i %></option>
				    <% } %>
				</select>
			</td>
		</tr>
	</table>
</div>

</c:when>

<c:otherwise>

<div id="queriesPageContent" class="queryPageViewMode">
	<ui:actionBar>
		<ui:actionGenerator actionListName="actions" builder="reportPageActionMenuBuilder" subject="${queryId}">
			<ui:actionLink actions="${actions}" keys="${not isAnonymous and isEditable ? 'editReport,' :''}newReport,findReports,exportReport${!isAnonymous && queryId > 0 ? ',sendToReview,sendMergeRequest' : ''}"/>
		</ui:actionGenerator>
			<c:if test="${!isAnonymous && queryId > 0}">
				<a href="#" class="actionBarIcon actionBarIconWithLabel" title="<spring:message code="queries.subscribe.edit.subscription.label"/>" id="editSubscription" data-query-id="${queryId}" data-subscription-id="${empty existingSubscriptionId ? '' : existingSubscriptionId}"<c:if test="${empty existingSubscriptionId}"> style="display: none"</c:if>><spring:message code="queries.job.label" text="Job"/></a>
				<a href="#" class="actionBarIcon actionBarIconWithLabel" title="<spring:message code="queries.subscribe.query.label"/>" id="newSubscription"<c:if test="${not empty existingSubscriptionId}"> style="display: none"</c:if>><spring:message code="queries.job.label" text="Job"/></a>
			</c:if>
			<c:if test="${!isAnonymous}">
				<a href="#" class="actionBarIcon actionBarIconWithLabel" title="<spring:message code="queries.manage.subscriptions.label"/>" id="manageSubscriptions"><spring:message code="queries.jobs.label" text="Jobs"/></a>
			</c:if>
	</ui:actionBar>
	<div id="toolbarContainer" class="editor-wrapper"></div>
	${queryContainer}
</div>

</c:otherwise>

</c:choose>

<script type="text/javascript">
	(function($) {

		$(function() {
			codebeamer.ReportPage.init({
				"widgetContainer" : $("#reportPageWidget"),
				"resultContainer" : $('#queryResultTable'),
				"queryId" : $('#queryId').val(),
				"editMode" : ${editMode},
				"starred" : ${isStarred},
				"editable" : ${isEditable},
				"findQueries" : ${findQueries},
				"showResizeableColumns" : true
			});
		});

	})(jQuery);
</script>
