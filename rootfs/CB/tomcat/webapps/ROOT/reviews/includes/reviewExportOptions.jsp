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
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<meta name="decorator" content="popup"/>
<meta name="module" content="review"/>
<meta name="moduleCSSClass" content="trackersModule newskin" />

<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/roundTripExport.css' />" type="text/css" media="all" />

<ui:actionMenuBar>
	<span class="breadcrumbs-separator"></span><ui:pageTitle prefixWithIdentifiableName="false"><spring:message code="review.${review.mergeRequest ? 'merge.' : '' }export.title" /></ui:pageTitle>
</ui:actionMenuBar>

<spring:message var="exportButton" code="tracker.issues.exportToWord.export.button"/>
<spring:message var="cancelButton" code="button.cancel"/>


<style type="text/css">

#officeExportOptionsTabContainer {
	height: 100%;
    position: absolute;
    width: 97%;
}

body {
	overflow: hidden;
}
#command .ditch-tab-pane-wrap {
	height: 70%;
}
</style>

<script type="text/javascript">
	function showBusy() {
		ajaxBusyIndicator.showBusyPage("tracker.issues.exportToWord.wait", false, { width: "32em"});
	}

	function tabChanged(e) {
		$("[name=exportKind]").val(e._selectedIndex == 0 ? 'roundtripWordExport' : 'excelExport');
	}
</script>

<form:form modelAttribute="command" >
	<form:hidden path="reviewId"/>
	<form:hidden path="filter"/>
	<input type="hidden" name="exportKind" value="roundtripWordExport"/>


	<c:url var="wordIcon" value="/images/newskin/action/icon_word.png"/>
	<c:url var="excelIcon" value="/images/icon_excel_export2_green.png"/>

	<tab:tabContainer id="officeExportOptionsTabContainer" skin="cb-box" selectedTabPaneId="wordExportTabPane" jsTabListener="tabChanged">
		<spring:message var="label" code="tracker.issues.exportToOffice.wordTab.label" />
		<tab:tabPane id="wordExportTabPane" tabTitle='<img src="${wordIcon }" class="tabIcon"/>${label}'>
			<%-- word export --%>
			<ui:actionBar>
				&nbsp;&nbsp;<input type="submit" class="button" value="${exportButton}" onclick="showBusy(); return true;"/>
				<input type="button" class="button cancelButton" value="${cancelButton}" onclick="inlinePopup.close(); return false;" />
			</ui:actionBar>

			<div class="contentWithMargins">
				<spring:message code="review.export.word.explanation"/>

				<h3><spring:message code="tracker.issues.exportToWord.roundtrip.export.options.title" text="Export with:" /></h3>
				<div style="margin-left:10px">
					<label style="display:inline;" for="exportComments"><form:checkbox id="exportComments" path="exportComments"/>
						<spring:message code="report.export.option.comments" text="Export Comments" />
					</label>
				</div>
			</div>


			<div class="exportTemplate contentWithMargins hideOnTabChange">
				<jsp:include page="/bugs/importing/includes/selectExportTemplateFragment.jsp" />
			</div>
		</tab:tabPane>

		<spring:message var="label" code="tracker.issues.exportToOffice.excelTab.label" />
		<tab:tabPane id="excelExportTabPane" tabTitle='<img src="${excelIcon }" class="tabIcon"/>${label}'>
			<%-- excel export --%>
			<ui:actionBar>
				&nbsp;&nbsp;<input type="submit" class="button" value="${exportButton}" onclick="showBusy(); return true;"/>
				<input type="button" class="button cancelButton" value="${cancelButton}" onclick="inlinePopup.close(); return false;" />
			</ui:actionBar>

			<div class="contentWithMargins">
				<spring:message code="review.export.excel.explanation"/>
			</div>
		</tab:tabPane>
	</tab:tabContainer>


</form:form>