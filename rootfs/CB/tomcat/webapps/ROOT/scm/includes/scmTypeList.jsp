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

<%@ taglib uri="uitaglib" prefix="ui" %>

<style type="text/css">

.scm-not-available {
	margin-left: 1em;
}
label {
	display: block;
	margin-bottom: 5px;
}
.newskin input[type="radio"] {
    vertical-align: text-bottom;
}

</style>

<div class="contentWithMargins" style="margin-top:20px;">
<%--
	small jsp fragment renders the radio buttons with repository types
--%>
<table border="0" class="formTableWithSpacing" cellpadding="2">

<tr valign="top">
	<TD class="optional" style="vertical-align:top;"><spring:message code="project.administration.scm.repository.provider.label" text="Scm System"/>:</TD>

	<td nowrap="nowrap">
	<c:if test="${param.noOption == 'true'}">
		<label for="noOption">
			<form:radiobutton path="type" value="" id="noOption" />
			<spring:message code="scc.name.not.selected" text="No source code"/>
		</label>
	</c:if>
	<c:forEach var="scmSelect" items="${scmForm.availableScmSystems}">
		<c:set var="scmType" value="${scmSelect.key}" />
		<label class="<c:if test="${scmSelect.value != 'true'}">notSelectable</c:if>" for="${scmType}">
			<form:radiobutton path="type" value="${scmType}" disabled="${scmSelect.value != 'true'}" id="${scmType}" />
			<spring:message code="scc.name.${scmType}" />
			<c:if test="${scmSelect.value != 'true' && (! empty scmSelect.value)}">
				<span class='scm-not-available'> - ${scmSelect.value}</span>
			</c:if>
		</label>
	</c:forEach>
	</td>
</tr>

</table>
</div>

<spring:message var="dialogMessage" code="project.creation.dialog.content" />
<ui:inProgressDialog message="${dialogMessage}" imageUrl="${pageContext.request.contextPath}/images/newskin/project_create_in_progress.gif" height="250" attachTo="#nextButton.finished" triggerOnClick="true" />
