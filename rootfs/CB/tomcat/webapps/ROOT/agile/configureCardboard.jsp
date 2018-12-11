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
--%>
<meta name="decorator" content="main"/>
<meta name="module" content="cmdb"/>
<meta name="moduleCSSClass" content="newskin CMDBModule"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="callTag" prefix="ct" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab" %>

<script type="text/javascript" src="<ui:urlversioned value='/js/configureCardboard.js'/>"></script>
<link rel="stylesheet" href="<ui:urlversioned value="/agile/cardboard.less" />" type="text/css" media="all" />

<style type="text/css">
	#userStories ul {
		list-style: none;
	}

	#userStories .issueIcon {
		position: relative;
		top: 3px;
	}

	table#userStories td {
		min-width: 200px;
	}

	.lane {
		padding: 0 10px 0 10px !important;
	}

	#top-box {
		padding: 10px;
	}

	.issueHandle {
		padding: 0px !important;
		padding-left: 10px !important;
		background-image: url("../images/newskin/action/dragbar-dark.png");
		background-position: 3px center;
		background-color: #d1d1d1;
		background-repeat: no-repeat;
		height: 20px;
		display: inline-block;
		margin-left: -4px;
		top: 6px;
		position: relative;
		margin-right: 4px;
		margin-top: -7px;
	}

	.card-config {
		margin-top: 5px;
	}

	.card-config input {
		position: relative;
		top: 2px;
	}

	.card-config-header {
		font-weight: bold;
		margin-bottom: 15px;
	}

	.card-config-header.inner-element {
		margin-top: 15px;
	}

	/* Tab styles */

	#tabs {
		margin-top: 15px;
	}

</style>

<script type="text/javascript">
	$(document).ready(function () {
		$(".minMaxInput").keydown(function(event) {
			var charCode = event.keyCode;
			var charStr = String.fromCharCode(charCode);
			if(charCode > 46 && !/^\d+$/.test(charStr) || event.shiftKey){
				event.preventDefault();
			}
		});
	});
</script>

<c:url value="${cardboardUrl }" var="cardboardUrl"/>
<ui:actionMenuBar>
	<ui:breadcrumbs showProjects="false" projectAware="${subject}">
		<span class='breadcrumbs-separator'>&raquo;</span><a href='${cardboardUrl}'><spring:message code="tracker.view.layout.cardboard.for.release.label" arguments="${subject.name}" htmlEscape="true"/></a>
		<span class='breadcrumbs-separator'>&raquo;</span><span><spring:message code="cardboard.configuration.label" text="Configuration"/></span>
		<ui:pageTitle prefixWithIdentifiableName="false" printBody="false" >
			<spring:message code="cardboard.configure.page.title" arguments="${subject.name}" htmlEscape="true"/>
		</ui:pageTitle>
	</ui:breadcrumbs>
</ui:actionMenuBar>

<c:url value="/cardboard/configureCardboard.spr?${urlParam }=${subject.id}" var="actionUrl"/>
<form:form method="POST" commandName="command" action="${actionUrl}">
	<input type="hidden" value="${subject.id}" name="${urlParam }"/>
	<div class="actionBar">
		<div class="okcancel" style="margin-top: 0px;">
			<input type="submit" class="button" value='<spring:message code="button.save"/>' />
			<a href="#" onclick="location.href='${cardboardUrl}'; return false;"><spring:message code="button.cancel"/></a>
		</div>
	</div>

	<ui:message type="information" isSingleMessage="true" messageId="reached-column-maximum" style="display: none;" >
		<c:set var="maxColumnsDocUrl" value="https://codebeamer.com/cb/wiki/199575#section-Changing+the+maximum+number+of+columns" scope="page" />
		<ul>
			<li>
				<spring:message code="cardboard.configuration.maximum.columns.reached.message" arguments="${maximumColumns},${maxColumnsDocUrl}"
								text="The maximum number of columns is {0}. If you need more, you need to edit the general.xml file. For more information see <a href='{1}'>the documentation</a>."/>
			</li>
		</ul>
	</ui:message>

	<tab:tabContainer id="tabs" skin="cb-box">

		<spring:message code="cardboard.column.tab" text="Column Configuration" var="columnTabTitle"/>
		<tab:tabPane id="columns" tabTitle="${columnTabTitle}">

			<spring:message code="cardboard.configuration.draggable.tooltip" text="Drag this status to an other column to change the mapping" var="tooltip"/>

			<form:errors cssClass="error"/>
			<spring:message code="cardboard.configuration.insert.colum.title" text="Insert new olumn after this" var="insertTitle"/>
			<table id="userStories" style="margin-top: 15px;">
				<tbody>
				<tr class="header">
					<c:forEach items="${columns}" var="option" varStatus="iterationStatus">
						<td class="${!iterationStatus.last ? 'notLast' : 'last' } ${option.id == 3 ? 'done' : ''} ${option.defaultColumn ? 'default' : ''}" id="header_${option.id}" style="width: 20%; height: 30px;"
							data-id="${option.id}">
							<span class="insert-column-icon" title="${insertTitle}"></span>
							<c:if test="${!option.defaultColumn }"><span class="remove-column-icon"></span></c:if>
							<c:if test="${option.defaultColumn }"><span class="icon-placeholder"></span></c:if>
							<c:set var="columnHeader" value="${not empty columnNames[option] ? columnNames[option] : option.name}"/>
							<div class="column-title"><input name="names" value="${columnHeader}" type="text"></div>
							<input type="hidden" name="ids" value="${option.id}"/>
							<c:if test="${option.id != 3}">
								<strong class="wip-title"><spring:message code="cardboard.work.in.progress.label" text="Work in Progress limits"/></strong>
								<div class="header-separator">
									<c:if test="${iterationStatus.first}">
										<span class="subtext" style="font-weight: normal;"><spring:message code="cardboard.work.in.progress.hint"/></span>
									</c:if>
								</div>
								<div class="wip">
									<label class="minLabel"><spring:message code="cardboard.configure.minimum.label"/></label>
									<input type="text" maxlength="7" value="${minValues[option]}" name="minimum" class="minMaxInput minInput">&nbsp;
									<label class="maxLabel"><spring:message code="cardboard.configure.maximum.label"/></label>
									<input type="text" maxlength="7" value="${maxValues[option]}" name="maximum" class="minMaxInput maxInput">&nbsp;
								</div>
							</c:if>
							<c:if test="${option.id == 3}">
								<div class="wip"></div>
							</c:if>
						</td>
					</c:forEach>
				</tr>
				<tr class="body">
					<c:forEach items="${columns}" var="option" varStatus="iterationStatus">
						<c:set var="columnHeader" value="${not empty columnNames[option] ? columnNames[option] : option.name}"/>
						<td class="lane ${!iterationStatus.last ? 'notLast' : 'last' }" id="${option.id}" data-id="${option.id}">
							<input type="hidden" value="" name="statuses"/>
							<div class="mappings">
								<strong><spring:message code="cardboard.status.mapping.label" text="Statuses displayed as ${columnHeader}" arguments="${columnHeader}"/></strong>
								<c:set var="extraStyle" value=""/>
								<c:if test="${empty explicitStatusesPerColumn[option]}"><c:set var="extraStyle" value="display: none;"/></c:if>
								<ul class="moved-group" style="padding-left: 2px; ${extraStyle}">
									<li>
										<strong><spring:message code="cardboard.configuration.explicit.mapping" text="Mapped to this column explicitly"></spring:message></strong>
										<c:choose>
											<c:when test="${empty explicitStatusesPerColumn[option]}">
												<ul class="tracker-list">

												</ul>
											</c:when>
											<c:otherwise>
												<ul  style="padding-left: 2px;">
													<c:forEach items="${explicitStatusesPerColumn[option]}" var="projectsPerColumn">
														<li>${projectsPerColumn.key.name}
															<ul class="tracker-list">
																<c:forEach items="${projectsPerColumn.value}" var="trackersPerProject">
																	<li class="tracker" data-id="${trackersPerProject.key.id}">
																		<label title='<spring:message code="tracker.choiceList.title" arguments="${statusTitle}"/>'>${trackersPerProject.key.name}</label>
																		<ul style="padding-left: 10px;" class="status-list">
																			<c:forEach items="${trackersPerProject.value}" var="status">
																				<li class="status" data-id="${status.tracker.id}-${status.id}" title="${tooltip }">
																					<div class="issueHandle"></div>${status.name}
																				</li>
																			</c:forEach>
																		</ul>
																	</li>
																</c:forEach>
															</ul>
														</li>
													</c:forEach>
												</ul>
											</c:otherwise>
										</c:choose>
									</li>
								</ul>

								<div style="margin-top: 20px; padding-left: 2px;"><strong><spring:message code="cardboard.configuration.default.mapping" text="Mapped to this column based on the status flags"/></strong></div>
								<c:forEach items="${trackersGrouped}" var="entry">
									<ul  style="padding-left: 2px;">
										<li>${entry.key.name}
											<ul style="padding-left: 10px;" class="tracker-list">
												<c:forEach items="${entry.value}" var="tracker" varStatus="stat">
													<li class="tracker" data-id="${tracker.id}">
														<spring:message var="statusTitle" code="tracker.field.Status.label"/>
														<label title='<spring:message code="tracker.choiceList.title" arguments="${statusTitle}"/>'>${tracker.name}</label>
														<ul style="padding-left: 10px;" class="status-list">
															<c:set var="statusMap" value="${statusesPerColumns[tracker.id]}"/>
															<c:forEach items="${statusMap[option]}" var="status">
																<li class="status" data-id="${status.tracker.id}-${status.id}" title="${tooltip }">
																	<div class="issueHandle"></div>${status.name}
																</li>
															</c:forEach>
														</ul>
													</li>
												</c:forEach>
											</ul>
										</li>
									</ul>
								</c:forEach>
							</div>
						</td>
					</c:forEach>
				</tr>
				</tbody>
			</table>

		</tab:tabPane>

		<spring:message code="cardboard.general.tab" text="Card Configuration" var="cardTabTitle"/>
		<tab:tabPane id="general" tabTitle="${cardTabTitle}">
			<div id="top-box">

				<div class="card-config-header">
					<spring:message code="cardboard.general.card.config" text="Configure content of Kanban Cards"/>
				</div>

				<div class="card-config">
					<form:checkbox path="displayUserPhoto" id="displayUserPhoto"/><label for="displayUserPhoto"><spring:message code="cardboard.display.user.photo" text="Show User Photo on Cards"/></label>
				</div>
				<div class="card-config">
					<form:checkbox path="displayStoryPoint" id="displayStoryPoint"/><label for="displayStoryPoint"><spring:message code="cardboard.display.story.point" text="Show Story Point on Cards"/></label>
				</div>
				<div class="card-config">
					<form:checkbox path="displayPriority" id="displayPriority"/><label for="displayPriority"><spring:message code="cardboard.display.priority" text="Show Priority on Cards"/></label>
				</div>
				<div class="card-config">
					<form:checkbox path="displayUserStory" id="displayUserStory"/><label for="displayUserStory"><spring:message code="cardboard.display.user.story" text="Show referenced User Story on Cards"/></label>
				</div>
				<div class="card-config">
					<form:checkbox path="displayReleases" id="displayReleases"/><label for="displayReleases"><spring:message code="cardboard.display.releases" text="Show referenced Releases on Cards"/></label>
				</div>
				<div class="card-config">
					<form:checkbox path="displayAssignees" id="displayAssignees"/><label for="displayAssignees"><spring:message code="cardboard.display.assignees" text="Show Assignees on Cards"/></label>
				</div>
				<div class="card-config">
					<label for="displayCardNumber"><spring:message code="cardboard.display.cardnumber" text="Number of cards:"/></label>
					<form:select path="displayCardNumber" id="displayCardNumber">
						<form:option value="100" label="100"/>
						<form:option value="250" label="250"/>
						<form:option value="500" label="500"/>
					</form:select>
				</div>

				<c:if test="${isVersionCategory}">

					<div class="card-config-header inner-element">
						<spring:message code="cardboard.release.tracker.card.config" text="Release Tracker specific Kanban Board configuration"/>
					</div>

					<div class="card-config">
						<form:checkbox path="recursive" id="recursive"/><label for="recursive"><spring:message code="cardboard.display.recursive" text="Release Tracker only: Include Work Items from child Sprints on this Kanban Board"/></label>
					</div>

				</c:if>
			</div>
		</tab:tabPane>

	</tab:tabContainer>

</form:form>

<div style="display: none;" id="column-header-template">
	<span class="insert-column-icon" title="${insertTitle}"></span>
	<span class="remove-column-icon"></span>
	<div class="column-title"><input name="names" value="New column" type="text"></div>
	<input type="hidden" name="ids" value="-1"/>
	<strong class="wip-title"><spring:message code="cardboard.work.in.progress.label" text="Work in Progress limits"/></strong>
	<div class="header-separator">
	</div>
	<div class="wip">
		<label class="minLabel"><spring:message code="cardboard.configure.minimum.label"/></label>
		<input type="text" value="" name="minimum" class="minMaxInput minInput">&nbsp;
		<label class="maxLabel"><spring:message code="cardboard.configure.maximum.label"/></label>
		<input type="text" value="" name="maximum" class="minMaxInput maxInput">&nbsp;
	</div>
</div>

<div style="display: none;" id="column-body-template">
	<input type="hidden" value="" name="statuses"/>
	<div class="mappings">
		<strong><spring:message code="cardboard.status.mapping.label" text="Statuses displayed as new column" arguments="new column"/></strong>
		<div style="height: 15px;">
			<ul class="moved-group" style="padding-left: 2px; display: none;">
				<li>
					<strong><spring:message code="cardboard.configuration.explicit.mapping" text="Mapped to this column explicitly"></spring:message></strong>
					<ul class="tracker-list">

					</ul>
				</li>
			</ul>
		</div>
	</div>
</div>

<script type="text/javascript">
	$(document).ready(function () {
		codebeamer.cardboardConfiguration.init({"maximumColumns": ${maximumColumns}});
	});
</script>
