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
 * $Revision$ $Date$
--%>
<meta name="decorator" content="popup"/>

<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<c:url var="actionUrl" value="/baselines/ajax/applyBaselineCompareConfig.spr">
	<c:param name="proj_id" value="${projectId}" />
</c:url>

<c:url var="compareUrl" value="/proj/doc/compareBaselines.spr">
	<c:param name="proj_id"   value="${projectId}" />
	<c:param name="baseline1" value="${baseline1}" />
	<c:param name="baseline2" value="${baseline2}" />
</c:url>

<script language="JavaScript" type="text/javascript">
function compareBaselines() {
	var tstmp = new Date();
	var compareUrl = "${compareUrl}";
	compareUrl += "&compareDocuments=" + $("#compareDocuments1").is(':checked');
	compareUrl += "&compareWikiPages=" + $("#compareWikiPages1").is(':checked');
	compareUrl += "&compareTrackers=" + $("#compareTrackers1").is(':checked');
	compareUrl += "&defaultOrder=" + $("#defaultOrder").val();
	compareUrl += "&avoidCaching=" + tstmp.getTime();
	parent.loadUrl(compareUrl);
	closePopupInline();
}
</script>


<form:form action="${actionUrl}" method="POST">
	<input type="hidden" value="<c:out value='${projectId}'/>" name="projectId"/>

	<form:hidden path="baseline1"/>
	<form:hidden path="baseline2"/>

	<ui:actionBar>
		<spring:message var="buttonTitle" code="button.compare" text="Compare"/>
		<spring:message var="cancelTitle" code="button.cancel" text="Cancel"/>
		<input type="button" class="button" title="${buttonTitle}" value="${buttonTitle}" name="submit" onclick="compareBaselines();return false;" />&nbsp;
		<input type="button" class="button cancelButton" title="${cancelTitle}" value="${cancelTitle}" name="_cancel" onclick="closePopupInline();return false;" />
	</ui:actionBar>
	<table border="0" cellpadding="1" class="formTableWithSpacing">
		<tr>
			<td class="optional"><spring:message code="baseline.compare.comparedocuments" text="Compare documents"/>:</td>
			<td><form:checkbox path="compareDocuments"/></td>
		</tr>
		<tr>
			<td class="optional"><spring:message code="baseline.compare.comparewikipages" text="Compare wiki pages"/>:</td>
			<td><form:checkbox path="compareWikiPages"/></td>
		</tr>
		<tr>
			<td class="optional"><spring:message code="baseline.compare.comparetrackers" text="Compare trackers"/>:</td>
			<td><form:checkbox path="compareTrackers"/></td>
		</tr>
		<tr>
			<td class="optional"><spring:message code="baseline.compare.defaultsort" text="Sort result by"/>:</td>
			<td><form:select path="defaultOrder" items="${orderSelectItems}"/></td>
		</tr>
	</table>
</form:form>