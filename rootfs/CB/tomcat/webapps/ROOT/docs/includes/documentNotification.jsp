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
<%@ taglib uri="bugstaglib" prefix="bugs" %>
<%@ taglib uri="uitaglib" prefix="ui"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<form id="documentNotificationsForm">

	<div class="actionBar"></div>

	<c:if test="${not empty showDescriptionBox}">
		<div class="descriptionBox">
			<spring:message code="documents.notifications.info" text="You are changing notification settings for"/>:
			<c:forEach items="${artifacts}" var="art" varStatus="varstat">
				<c:if test="${!varstat.first}">, </c:if>
				<strong><c:out value='${art.name}'/></strong>
				<c:if test="${art.directory}">
					<small><spring:message code="document.type.directory.hint" text="(directory)"/></small>
				</c:if>
			</c:forEach>
		</div>
		<c:if test="${hasDirectory != null and hasDirectory and notOnlyDirectory}">
			<div class="descriptionBox">
				<small><spring:message code="document.type.directory.notification.hint" text="Notification on Read is not available for Directories."/></small>
			</div>
		</c:if>
	</c:if>

	<table class="fieldsTable" style="margin: 1em; width: 98%;">
        <c:if test="${document.typeId != 2 and (hasDirectory == null or (!hasDirectory or notOnlyDirectory))}">
            <tr>
                <td class="labelCell optional" style="vertical-align: middle;">
                    <spring:message code="document.notification.onRead.label" text="Notify on Read"/>:
                </td>
                <td>
                    <bugs:userSelector fieldName="notifyOnRead" ids="${notifyOnRead}" onlyCurrentProject="true"
                        singleSelect="${!canSubscribeOthers}" memberType="${canSubscribeOthers ? 10 : 2}" disabled="${!canModifyPermission or !(canSubscribeSelf or canSubscribeOthers)}"
                    />
                </td>
            </tr>
        </c:if>
		<tr>
			<td class="labelCell optional" style="vertical-align: middle;">
				<spring:message code="document.notification.onEdit.label" text="Notify on Edit"/>:
			</td>
			<td>
				<bugs:userSelector fieldName="notifyOnWrite" ids="${notifyOnWrite}" onlyCurrentProject="true"
					singleSelect="${!canSubscribeOthers}" memberType="${canSubscribeOthers ? 10 : 2}" disabled="${!canModifyPermission or !(canSubscribeSelf or canSubscribeOthers)}"
			  	/>
			</td>
		</tr>
	</table>

</form>

<c:if test="${(canSubscribeSelf or canSubscribeOthers) and canModifyPermission}">
<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/includes/ajaxSubmitButton.js'/>"></script>
<script type="text/javascript">

	$('#documentNotificationsForm > div.actionBar').ajaxSubmitButton({
	    submitText 	: '<spring:message code="button.save" text="Save" javaScriptEscape="true"/>',
	    submitUrl	: '${artifactNotificationssUrl}',
	    submitData	: function() {
	    					return {
	    				   		artifacts    : [<c:forEach items="${artifacts}" var="artifact" varStatus="loop">${artifact.id}<c:if test="${!loop.last}">, </c:if></c:forEach>],
	    				   		notifyOnRead : $('#documentNotificationsForm input[type="hidden"][name="notifyOnRead"]').val(),
	    				   		notifyOnWrite: $('#documentNotificationsForm input[type="hidden"][name="notifyOnWrite"]').val()
	    				    };
	    			  }
    <c:if test="${!empty param.onSuccess}">
		, onSuccess : function(result) { ${param.onSuccess}; }
	</c:if>
	});

</script>
</c:if>

