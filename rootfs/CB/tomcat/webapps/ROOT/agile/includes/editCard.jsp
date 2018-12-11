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
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<meta name="decorator" content="popup"/>

<style type="text/css">
	.mandatory.highlightedValue, .highlightedValue {
		background-color: #fffb95 !important;
		padding: 4px 6px 6px 5px !important;
		top: 0px !important;
	}
	.mandatory.nullValue, .nullValue {
		background-color: #ffe8e9 !important;
		padding: 4px 6px 6px 5px !important;
		top: 0px !important;
	}
</style>

<c:choose>
	<c:when test="${addUpdateTaskForm.trackerItem.id == null}">
		<c:url var="actionUrl" value="/cardboard/createIssue.spr" />
	</c:when>
	<c:otherwise>
		<c:url var="actionUrl" value="/cardboard/editCard.spr" />
		<input type="hidden" value="${addUpdateTaskForm.trackerItem.id}" id="cardId"/>
	</c:otherwise>
</c:choose>

<form:form action="${actionUrl}" enctype="multipart/form-data" commandName="addUpdateTaskForm" method="POST" cssClass="ratingOnInlinedPopup">
	<input type="hidden" name="swimlanes" value="<c:out value='${param.swimlanes}'/>"/>
	<jsp:include page="/bugs/addUpdateTask.jsp?noForm=true&nestedPath=null&noAssociation=true&noTrackerField=true&isPopup=true&minimal=true" />
</form:form>

<script type="text/javascript">
$(parent.document).find(".container-close").unbind("click").attr("onclick", "closePopupInline(); return false;");
</script>

<c:if test="${empty param.noCancel || !param.noCancel}">
	<script type="text/javascript">
		$(document).ready(function () {
			var isCardBoard = ((typeof parent.codebeamer != "undefined") && ("cardboard" in parent.codebeamer));
			if (isCardBoard) {
				$("input.cancelButton").attr("onclick", "parent.codebeamer.cardboard.cancelHandler(${addUpdateTaskForm.trackerItem.id}); closePopupInline(); return false;");
				$(parent.document).find(".container-close").unbind("click").attr("onclick", "parent.codebeamer.cardboard.cancelHandler(${addUpdateTaskForm.trackerItem.id}); closePopupInline(); return false;");
			}
		});
	</script>
</c:if>

<script type="text/javascript">
	$(document).ready(function () {
		$("input.cancelButton").attr("onclick", "parent.unlockTrackerItem(${addUpdateTaskForm.trackerItem.id}); closePopupInline(); return false;");
		$(parent.document).find(".container-close").unbind("click").attr("onclick", "parent.unlockTrackerItem(${addUpdateTaskForm.trackerItem.id}); closePopupInline(); return false;");
	});
</script>

