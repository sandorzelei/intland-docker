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
<meta name="bodyCSSClass" content="newskin"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>

<%@ taglib uri="uitaglib" prefix="ui" %>

<link rel="stylesheet" href="<ui:urlversioned value="/stylesheet/multiselect-filter.less" />" type="text/css" media="all" />

<c:set var="projectName"><c:out value="${version.project.name}"/></c:set>
<c:set var="versionName"><c:out value="${version.name}"/></c:set>

<ui:pageTitle printBody="false" prefixWithIdentifiableName="false">
	<spring:message code="cmdb.version.releaseNotes.title" text="{0} {1} - Release Notes" arguments="${projectName},${versionName}"/>
</ui:pageTitle>

<ui:actionMenuBar>
	<ui:breadcrumbs showProjects="false"><span class="breadcrumbs-separator">&raquo;</span><spring:message code="cmdb.version.releaseNotes.label" text="Release Notes" /></ui:breadcrumbs>
</ui:actionMenuBar>

<ui:globalMessages/>

<style type="text/css">
.newskin input[type="checkbox"], .newskin input[type="radio"] {
  vertical-align: text-bottom;
}

div.filter label {
	margin-left: 10px;
	margin-right: 10px;
}
</style>

<div class="contentWithMargins">
	<form:form commandName="generateReleaseNotesForm">
		<div>
			<h2>
				<spring:message code="cmdb.version.releaseNotes.title" text="{0} {1} - Release Notes" arguments="${projectName},${versionName}"/>
			</h2>
			<c:forEach var="entry" items="${trackerItemsGrouped}">
				<p>
				<h4><c:out value="${entry.key.name}"/></h4>
				<ul>
					<c:forEach var="trackerItem" items="${entry.value}">
						<li><c:out value="${trackerItem.keyAndId}"/> &ndash; <a href="<c:url value="${trackerItem.urlLink}"/>"><c:out value="${trackerItem.name}"/></a></li>
					</c:forEach>
				</ul>
				</p>
			</c:forEach>
			<c:if test="${knownIssues}">
				<h2>
					<spring:message code="cmdb.version.knownIssues" text="Known Issues" />
				</h2>
				<c:forEach var="entry" items="${knownTrackerItemsGrouped}">
					<p>
					<h4><c:out value="${entry.key.name}"/></h4>
					<ul>
						<c:forEach var="trackerItem" items="${entry.value}">
							<li><c:out value="${trackerItem.keyAndId}"/> &ndash; <a href="<c:url value="${trackerItem.urlLink}"/>"><c:out value="${trackerItem.name}"/></a></li>
						</c:forEach>
					</ul>
					</p>
				</c:forEach>
			</c:if>
		</div>

		<div class="filter" style="margin-top:2em; border-top:1px solid #E5E5E5;">
			<h2><spring:message code="cmdb.version.releaseNotes.export.label" text="Export Release Notes" /></h2>
			<b><spring:message code="cmdb.version.releaseNotes.export.format" text="Format" />:</b>
			<form:select path="type">
				<form:options items="${types}"/>
			</form:select>

			<label for="releaseSelector"><spring:message code="cmdb.version.sprints" text="Sprints" />:</label>
			<select name="sprintSelector" id="sprintSelector" multiple="multiple">
				<c:forEach var="sprint" items="${sprints}">
					<optgroup label="<c:out value='${sprint.name}'/>">
						<c:forEach items="${sprint.children}" var="subSprint">
							<option value="${subSprint.id}" title="<c:out value='${subSprint.name}'/>" ${fn:contains(sprintSelector, subSprint.id) ? 'selected' : ''}>
								<c:out value='${subSprint.name}'/>
							</option>
						</c:forEach>
						<option value="${sprint.id}" title="<c:out value='${sprint.name}'/>" ${fn:contains(sprintSelector, sprint.id) ? 'selected' : ''}>
							<c:out value='${sprint.name}'/>
							<c:if test="${fn:length(sprint.children) > 0}">
								- <spring:message code="cmdb.version.backlog" text="backlog" />
							</c:if>
						</option>
					</optgroup>
				</c:forEach>
				<optgroup label="${versionName}">
					<option value="${version.id}" title="${versionName}" ${fn:contains(sprintSelector, version.id) ? 'selected' : ''}>
						${versionName}
						<c:if test="${fn:length(version.children) > 0}">
							- <spring:message code="cmdb.version.backlog" text="backlog" />
						</c:if>
					</option>
				</optgroup>
			</select>

			<label for="knownIssues"><input id="knownIssues" type="checkbox" name="knownIssues" ${knownIssues ? 'checked' : ''} /> <spring:message code="cmdb.version.knownIssues" text="Known Issues" /></label>

			<input type="submit" class="button" value="<spring:message code="cmdb.version.generate" text="Generate" />"/>
		</div>

		<script type="text/javascript">
			var defaultMultiselectOptions = {
				"selectedText": function(numChecked, numTotal, checked) {
					return $.map(checked, function(a) {
						var title = $(a).attr("title");
						return title;
					}).join(", ");
				},
				"create": function (e) {
					var $widget = $("[name=multiselect_" + $(this).attr("id") + "]").closest(".ui-multiselect-menu");
					$widget.hide();
				}
			};

			$(document).ready(function () {
				// multiselect lists
				$("#sprintSelector").multiselect(defaultMultiselectOptions);

				$("#knownIssues, #type").change(function(e) {
					var checked = $("#knownIssues").is(':checked');
					var type = $("#type").val();

					if (checked && type == "Word") {
						$("#knownIssues").attr("checked", false);
					}
				});
			});
		</script>

		<spring:message var="exportTitle" code="cmdb.version.releaseNotes.export.tooltip" text="Tip: you can easily select all, copy and paste the release notes text to an external application." />
		<div style="margin-top:10px;">
			<textarea title="${exportTitle}" class="expandTextArea" rows="32" cols="140" readonly="readonly"><c:out value="${releaseNotes}"/></textarea>
		</div>
	</form:form>
</div>

<c:if test="${! empty downloadUrl}">
<script type="text/javascript">
$(function() {
	document.location.href="${downloadUrl}";
});
</script>
</c:if>