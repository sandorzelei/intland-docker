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
<meta name="decorator" content="popup"/>

<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<style type="text/css">
.tdexpand {
	width: 50%;
}
</style>

<c:url var="compareUrl" value="/proj/doc/compareBaselines.spr">
	<c:param name="projectId" value="${projectId}" />
	<c:param name="baseline1" value="${baseline1}" />
	<c:param name="baseline2" value="${baseline2}" />
</c:url>

<div class="actionBar">
	<spring:message var="cancelTitle" code="button.cancel" text="Cancel"/>
	<input type="button" class="button cancelButton" title="${cancelTitle}" value="${cancelTitle}" name="_cancel" onclick="closePopupInline();return false;" />
</div>

<table border="0" class="formTableWithSpacing" cellpadding="1">
	<tr>
		<td class="optional"><spring:message code="issue.revision.diff.version" text="Version"/>:</td>
		<td class="tdexpand">${revision1}</td>
		<td class="tdexpand">${revision2}</td>
	</tr>
	<tr>
		<td class="optional"><spring:message code="issue.revision.diff.versiondate" text="Version Date"/>:</td>
		<td class="tdexpand">${tiRevision1.submittedAt}</td>
		<td class="tdexpand">${tiRevision2.submittedAt}</td>
	</tr>
	<tr>
		<td class="optional"><spring:message code="issue.revision.diff.submitter" text="Submitter"/>:</td>
		<td class="tdexpand">${tiRevision1.submitter}</td>
		<td class="tdexpand">${tiRevision2.submitter}</td>
	</tr>
	<tr>
		<td class="optional"><spring:message code="issue.revision.diff.name" text="Name"/>:</td>
		<td class="tdexpand">${tiRevision1.dto.name}</td>
		<td class="tdexpand">${tiRevision2.dto.name}</td>
	</tr>
	<tr>
		<td class="optional"><spring:message code="issue.revision.diff.description" text="Description"/>:</td>
		<td class="tdexpand">${tiRevision1.dto.description}</td>
		<td class="tdexpand">${tiRevision2.dto.description}</td>
	</tr>
	<tr>
		<td class="optional"><spring:message code="issue.revision.diff.priority" text="Priority"/>:</td>
		<td class="tdexpand">${tiRevision1.dto.priority}</td>
		<td class="tdexpand">${tiRevision2.dto.priority}</td>
	</tr>
	<tr>
		<td class="optional"><spring:message code="issue.revision.diff.status" text="Status"/>:</td>
		<td class="tdexpand">${tiRevision1.dto.status.name}</td>
		<td class="tdexpand">${tiRevision2.dto.status.name}</td>
	</tr>
	
</table>
