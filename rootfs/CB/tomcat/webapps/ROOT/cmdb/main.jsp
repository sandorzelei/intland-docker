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
<meta name="module" content="cmdb"/>
<meta name="moduleCSSClass" content="newskin trackersModule CMDBModule"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="acltaglib" prefix="acl" %>
<%@ taglib uri="charttaglib" prefix="chart" %>

<%@ taglib uri="tracker" prefix="tracker" %>
<%@ taglib uri="uitaglib" prefix="ui" %>


<ui:actionMenuBar>
		<ui:breadcrumbs showProjects="false"><span class='breadcrumbs-separator'>&raquo;</span>
		<ui:pageTitle prefixWithIdentifiableName="false"><spring:message code="CMDB" text="CMDB"/></ui:pageTitle>
		</ui:breadcrumbs>
</ui:actionMenuBar>

<c:set var="proj_id" value="${PROJECT_DTO.id}" scope="request" />

<c:url var="CMDBUrl" value="/proj/cmdb.do">
	<c:param name="proj_id" value="${proj_id}"/>
</c:url>

<%-- include the JS and hidden field for deleting one/multiple reports --%>
<jsp:include page="/docs/includes/deleteArtifacts.jsp" >
	<jsp:param name="confirmMessageKey" value="cmdb.category.delete.confirm" />
	<jsp:param name="confirmOneMessageKey" value="cmdb.category.deleteOne.confirm" />
</jsp:include>

<script language="JavaScript" type="text/javascript">
	function showCMDB(checkbox) {
		if (checkbox != null) {
			location.href='${CMDBUrl}&showAll=' + checkbox.checked;
			return false;
		}
	}

	// submit the form if at least one checkbox of 'selectedArtifactIds' is selected
	// @param for The form to submit
	// @param params The parameters to add to the submit
	function submitOnComboSelection(form, params) {
		var cansubmit = submitIfSelected(form, 'selectedArtifactIds');
		if (cansubmit) {
			// Important: this is NOT the action-url of the form, but the hidden action field!
			form.action.value = params;
			form.submit();
		}
		return cansubmit;
	}

	// callback when the selection changes
	function onSelectionChange(selectbox) {
		var action = selectbox.options[selectbox.selectedIndex].value;
		var form = selectbox.form;
		var success = false;

		switch (action) {
			case "cut":
				success = submitOnComboSelection(form, 'cut');
				break;
			case "copy":
				success = submitOnComboSelection(form, 'copy');
				break;
			case "paste":
				success = disableButtonsAndSubmit(form, 'paste');
				break;
			case "delete":
				success = confirmDelete(form);
				break;
		}

		if (!success) {
			// can not submit because no checkbox was checked,
			// reset the selectbox to the 1st selection so "More Actions..." will be selected
			selectbox.selectedIndex = 0;
		}
	}
</script>

<html:form action="/proj/doc/documentProperties" method="GET">

	<html:hidden property="action" />

	<ui:actionBar>
		<ui:actionGenerator builder="categoryListPageActionMenuBuilder" actionListName="actions" >
			<ui:rightAlign>
				<jsp:attribute name="rightAligned">
					<spring:message var="showAllTitle" code="cmdb.category.showAll.tooltip" htmlEscape="true"/>
					<c:if test="${param.showAll eq 'true'}">
						<c:set var="showAllSelected" value="checked='checked'"/>
					</c:if>
					<input id="showAll" type="checkbox" ${showAllSelected}" title="${showAllTitle}" onchange="return showCMDB(this);">
					<label for="showAll" title="${showAllTitle}">
						<spring:message code="cmdb.category.showAll.label" text="Show all"/>
					</label>
				</jsp:attribute>
				<jsp:body>
				    <ui:actionLink keys="classDiagram, createNewCategory" actions="${actions}" />
					<ui:actionComboBox keys="cut, copy, paste, delete" actions="${actions}" onchange="onSelectionChange(this);"  id="actionCombo" />
				</jsp:body>
			</ui:rightAlign>
		</ui:actionGenerator>
	</ui:actionBar>

	<jsp:include page="./summary.jsp" flush="true" />
</html:form>

