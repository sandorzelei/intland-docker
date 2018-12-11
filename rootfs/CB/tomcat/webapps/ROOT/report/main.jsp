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
<meta name="module" content="queries"/>
<meta name="moduleCSSClass" content="newskin reportModule"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="callTag" prefix="ct" %>

<ui:actionMenuBar>
		<ui:breadcrumbs showProjects="false" strongBody="true">
			<ui:pageTitle prefixWithIdentifiableName="false"><spring:message code="report.overview.title" text="Reports"/></ui:pageTitle>
		</ui:breadcrumbs>
</ui:actionMenuBar>

<spring:message var="toggleButton" code="search.what.toggle" text="Select/Clear All"/>
<c:set var="checkAll">
	<INPUT TYPE="CHECKBOX" TITLE="${toggleButton}" NAME="SELECT_ALL" VALUE="on"	ONCLICK="setAllStatesFrom(this, 'selectedArtifactIds')">
</c:set>

<html:form action="/proj/doc/documentProperties" method="GET">

<html:hidden property="action" />

<c:set var="requestURI" value="/proj/report.do" />

<%-- include the JS and hidden field for deleting one/multiple reports --%>
<jsp:include page="/docs/includes/deleteArtifacts.jsp" >
	<jsp:param name="confirmMessageKey" value="report.delete.confirm" />
	<jsp:param name="confirmOneMessageKey" value="report.deleteOneDoc.confirm" />
</jsp:include>

<ui:actionBar>
	<ui:actionGenerator builder="reportsActionMenuBuilder" subject="${listDocumentForm}" actionListName="actions" >
		<ui:actionLink keys="new" actions="${actions}" />

		<script type="text/javascript">

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
					case "permissions":
						success = submitOnComboSelection(form, 'permissions');
						break;
				}

				if (!success) {
					// can not submit because no checkbox was checked,
					// reset the selectbox to the 1st selection so "More Actions..." will be selected
					selectbox.selectedIndex = 0;
				}
			}

		</script>
		<ui:actionComboBox keys="cut, copy, paste, delete, permissions" actions="${actions}" id="actionCombo" onchange="onSelectionChange(this);" />
	</ui:actionGenerator>
</ui:actionBar>

<ui:showErrors />

<ui:displaytagPaging defaultPageSize="${pagesize}" items="${listDocumentForm.content}" excludedParams="page"/>

<style type="text/css">
<!--
 #fileAttributes input {
 	vertical-align: top;
 }
-->
</style>

<display:table requestURI="" id="fileAttributes" name="${listDocumentForm.content}"
	cellpadding="0" excludedParams="ACTIVE_TAB"
	export="false" decorator="com.intland.codebeamer.ui.view.table.DocumentListDecorator" sort="external" defaultsort="2">

	<display:setProperty name="paging.banner.item_name"><spring:message code="report.label"/></display:setProperty>
	<display:setProperty name="paging.banner.items_name"><spring:message code="reports.label"/></display:setProperty>
	<display:setProperty name="paging.banner.some_items_found" value="${allItems}" />
	<display:setProperty name="paging.banner.all_items_found"><spring:message code="paging.all.banner"/></display:setProperty>
	<display:setProperty name="paging.banner.onepage" value="" />
	<display:setProperty name="paging.banner.placement" value="${empty listDocumentForm.content.list ? 'none' : 'bottom'}"/>

	<display:column title="${checkAll}" decorator="com.intland.codebeamer.ui.view.table.TrimmedColumnDecorator" media="html"
			headerClass="checkbox-column-minwidth" class="checkbox-column-minwidth">
		<ct:call return="itemId"     object="${listDocumentForm}" method="getItemId"  param1="${fileAttributes}" />
		<ct:call return="isSelected" object="${listDocumentForm}" method="isSelected" param1="${fileAttributes}" />
		<input type="checkbox" name="selectedArtifactIds" value="${itemId}"
			<c:if test="${isSelected}">checked="checked"</c:if>>
		</input>
	</display:column>

	<display:column class="rawData actionIcon" title="" property="actionInfo" media="html" />
	<display:column class="rawData actionIcon" title="" media="html">
		<ui:ajaxTagging entityTypeId="${GROUP_OBJECT}" entityId="${fileAttributes.id}" favourite="true" />
	</display:column>

	<display:column title="" class="rawData status-icon-minwidth" media="html">
		<ct:call return="itemId" object="${listDocumentForm}" method="getItemId"  param1="${fileAttributes}" />
		<jsp:include page="/includes/notificationBox.jsp" >
			<jsp:param name="showNotificationBox" value="false" />
			<jsp:param name="entityTypeId" value="${GROUP_ARTIFACT}" />
			<jsp:param name="entityId" value="${itemId}" />
		</jsp:include>
	</display:column>

	<spring:message var="nameTitle" code="document.name.label" text="Name"/>
	<display:column title="${nameTitle}" property="name" sortable="true" sortProperty="sortName" headerClass="textData" class="textData nameLink" />

	<display:column title="" decorator="com.intland.codebeamer.ui.view.table.TrimmedColumnDecorator" media="html" class="action-column-minwidth columnSeparator">
		<ui:actionGenerator builder="artifactListContextActionMenuBuilder" subject="${fileAttributes}" actionListName="actions" >
			<ui:actionMenu actions="${actions}" />
		</ui:actionGenerator>
	</display:column>

	<spring:message var="descriptionTitle" code="document.description.label" text="Description"/>
	<display:column title="${descriptionTitle}" property="description" sortable="true" sortProperty="sortDescription" headerClass="textData expand" class="textDataWrap smallerText columnSeparator" />

	<spring:message var="versionTitle" code="document.version.label" text="Version"/>
	<display:column title="${versionTitle}" property="version" headerClass="numberData" class="numberData smallerText columnSeparator" />

	<spring:message var="modifiedAtTitle" code="document.lastModifiedAt.label" text="Modified at"/>
	<display:column title="${modifiedAtTitle}" property="lastModifiedAt" sortable="true" sortProperty="sortLastModifiedAt" headerClass="dateData" class="dateData columnSeparator" />

	<spring:message var="modifiedByTitle" code="document.lastModifiedBy.label" text="Modified by"/>
	<display:column title="${modifiedByTitle}" property="lastModifiedBy" sortable="true" sortProperty="sortLastModifiedBy" headerClass="textData" class="textData" />

</display:table>

</html:form>
