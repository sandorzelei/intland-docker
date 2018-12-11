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
<meta name="decorator" content="popup" />
<meta name="module" content="tracker" />
<meta name="moduleCSSClass" content="newskin" />

<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<spring:message var="saveLabel" code="button.save" text="Save" />
<spring:message var="cancelLabel" code="button.cancel" text="Cancel" />

<c:if test="${param.noActionMenuBar != 'true' }">
	<ui:actionMenuBar>
		<jsp:body>
			<ui:breadcrumbs showProjects="false" projectAware="${tracker}">
				<span class='breadcrumbs-separator'>&raquo;</span>
			</ui:breadcrumbs>
		</jsp:body>
	</ui:actionMenuBar>
</c:if>

<ui:actionBar>
	<input type="submit" class="button" name="submit" value="${saveLabel}" />
	<input type="submit" class="cancelButton" name="cancel" value="${cancelLabel}" />
</ui:actionBar>


<c:if test="${not enabled or empty tracker}">
	<div class="warning"><spring:message code="tracker.configuration.history.plugin.revert.no.permission" text="You have no permission to edit this tracker."/></div>
	<script type="text/javascript">
		jQuery(function($) {
			$(".actionBar input[name=submit]").attr("disabled", "disabled");
		});
	</script>
</c:if>

<c:if test="${diff.differenceCount == 0}">
	<div class="warning"><spring:message code="diffTool.no.differences" text="No differences found."/></div>
	<script type="text/javascript">
		jQuery(function($) {
			$(".actionBar input[name=submit]").attr("disabled", "disabled");
		});
	</script>
</c:if>

<c:if test="${not empty tracker}">
	<form id="diffDataForm" action="${pageContext.request.contextPath}/trackerdiff/trackerdiff.spr" method="post">
		<input type="hidden" name="trackerId" value="${tracker.id}" />
		<input type="hidden" name="trackerVersion" value="${diff.trackerVersionNumber}" />
		<input type="hidden" name="trackerFieldIds" value="" />
	</form>
	<jsp:include page="trackerDiffTable.jsp"/>
	<script src="<ui:urlversioned value='/js/trackerdiff.js' />"></script>
</c:if>



