<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<script src="<ui:urlversioned value='/js/suspectedLinkBadge.js'/>"></script>

<ui:UserSetting var="newWindowTarget" setting="NEW_BROWSER_WINDOW_TARGET" />

<c:choose>
	<c:when test="${not empty errorMessage}">
		<ui:message type="error" isSingleMessage="true" containerId="globalMessages">
			<ul><li><c:out value="${errorMessage}" /> <spring:message code="query.cbQl.error.help" htmlEscape="false"/></li></ul>
		</ui:message>
	</c:when>
	<c:otherwise>
		<c:if test="${!skipMarginDiv}">
			<div class="contentWithMargins">
		</c:if>
			<c:if test="${empty forceOpenInNewWindow}">
				<c:set var="forceOpenInNewWindow" value="${newWindowTarget eq '_blank'}"/>
			</c:if>
			<c:set var="pluginTableId" value="${not empty pluginTableId ? pluginTableId : 'trackerItems'}"></c:set>
			<bugs:displaytagTrackerItems htmlId="${pluginTableId}" layoutList="${layoutList}" items="${items}" export="false" hideIconColumn="${hideIconColumn}"
										 requestURI="${action}" browseTrackerMode="${browseTrackerMode}" decorator="${decorator}" forceOpenInNewWindow="${forceOpenInNewWindow}"
										 exportMode="${exportMode}" selection="${selectable}" selectionFieldName="clipboard_task_id" hideItemChildrenHandler="${hideItemChildrenHandler}"
										 inlineEdit="${inlineEdit ? 'true' : 'false'}" plannerMode="${plannerMode ? 'true' : 'false'}" 
										 inlineEditBuildTransitionMenu="${inlineEditBuildTransitionMenu ? 'true' : 'false'}"
										 showHeaderIfEmpty="${plannerMode ? 'true' : 'false'}" resizableColumns="${resizeableColumns ? resizeableColumns : 'false'}" reportId="${reportId}"
			/>
		<c:if test="${!skipMarginDiv}">
			</div>
		</c:if>
		<script type="text/javascript">
			$(function() {
				var pluginTableId = "${pluginTableId}";
				codebeamer.ReferenceSettingBadges.init($("#" + pluginTableId));
                codebeamer.suspectedLinkBadge.init($("#" + pluginTableId));
			});
		</script>
	</c:otherwise>
</c:choose>
