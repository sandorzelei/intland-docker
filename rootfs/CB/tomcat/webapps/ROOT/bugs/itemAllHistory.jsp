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

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="taglib" prefix="tag" %>

<SCRIPT LANGUAGE="JavaScript" type="text/javascript">

function switchTab(tabId){
	var targetTab = document.getElementById(tabId);
	if (targetTab) {
		with (org.ditchnet) {
			jsp.TabUtils.findTabElements(targetTab);
			jsp.TabUtils.switchTab(targetTab);
		}
	}
}

</SCRIPT>

<display:table requestURI="${requestURI}" excludedParams="orgDitchnetTabPaneId" name="${itemAllHistory}"
	id="item" cellpadding="0" class="expandTable"
	defaultsort="2" defaultorder="descending" export="false" decorator="com.intland.codebeamer.ui.view.table.TrackerItemHistoryDecorator">

	<spring:message var="typeTitle" code="symbol.type.label" text="Type" />
	<display:column title="${typeTitle}" property="icon" sortProperty="sortIcon" sortable="true" defaultorder="descending" style="width: 1%" />

	<spring:message var="submittedTitle" code="issue.history.date.label" text="Submitted" />
	<display:column title="${submittedTitle}" headerClass="textData" class="textData columnSeparator assocSubmitterCol" sortable="true" sortProperty="sortSubmitted">
		<c:set var="item" scope="request" value="${item}" />
		<jsp:include page="/bugs/itemHistorySubmission.jsp"/>
	</display:column>

	<spring:message var="commentTitle" code="comment.label" text="Comment" />
	<display:column title="${commentTitle}" property="comment" headerClass="textData" class="textDataWrap" />
</display:table>
