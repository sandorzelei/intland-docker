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
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="uitaglib" prefix="ui" %>

<%@ page import="com.intland.codebeamer.persistence.dto.TrackerLayoutLabelDto" %>

<script type="text/javascript" src="<ui:urlversioned value='/js/jquery/colresizable/colResizable-1.6.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/js/displaytagTrackerItemsResizeableColumns.js'/>"></script>

<c:url var="menuArrow" value="/images/space.gif"/>

<%
	pageContext.setAttribute("NAME_LABEL_ID", Integer.valueOf(TrackerLayoutLabelDto.NAME_LABEL_ID));
%>

<table id="requirements" class="displaytag fullExpandTable" style="table-layout: fixed;">
	<thead id="main-header">
		<tr class="trackerItem">
			<th class="control-bar"<c:if test="${resizeableColumns}"> style="width: 30px"</c:if>></th>
			<c:forEach items="${selectedFields }" var="field" varStatus="loopStatus">
				<c:set var="headerStyleClass" value="${field.headerStyleClass}" />
				<c:set var="extraClass" value=""/>
				<c:if test="${!resizeableColumns && field.id ne NAME_LABEL_ID}">
					<c:set var="extraClass" value="column-minwidth"/>
				</c:if>
				<c:set var="percentageStyle">
					<c:if test="${resizeableColumns}"> style="width: ${fieldWidths.get(loopStatus.index)}%"</c:if>
				</c:set>
				<th data-fieldlayoutid="${field.id }" data-customfieldtrackerid="${tracker.id }" data-field-id="${field.id }"
				class="dragaccept ${field.required ? 'required' : ''} ${headerStyleClass} ${field.id ==  80 ? 'description-field textDataWrap' : 'textDataWrap'} ${extraClass}" ${percentageStyle}>
						<c:set var="labelToUse" value="${not empty field.title ? field.title : field.label }"/>
						<spring:message code="tracker.field.${labelToUse}.label" text="${labelToUse}" var="fieldLabel"></spring:message>
						<c:if test="${field.id == NAME_LABEL_ID}">
							<spring:message code="tracker.view.layout.document.extended.summary.label" var="fieldLabel"/>
						</c:if>
						<label title="${fieldLabel }">
							${fieldLabel }
						</label>
						<span class="tracker-context-menu action-column-minwidth context-menu-active">
							<img class="menuArrowDown" src="${menuArrow }">
							<span class="menu-container"></span>
						</span>
						<c:if test="${field.id != NAME_LABEL_ID}">
							<span class="removeColumn" title="<spring:message code="queries.contextmenu.removecolumn" text="Remove Column"/>"></span>
						</c:if>
				</th>
			</c:forEach>
		</tr>
	</thead>
	<jsp:include page="extendedDocumentViewRows.jsp"/>
</table>

<script type="text/javascript">
	(function ($) {
		codebeamer.trackers.extended.init({trackerId: ${tracker.id}, resizeableColumns: ${resizeableColumns ? 'true' : 'false'}});
	})(jQuery);
</script>