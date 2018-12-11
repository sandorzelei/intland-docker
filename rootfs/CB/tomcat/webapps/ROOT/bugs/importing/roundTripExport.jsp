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

<%@page import="com.intland.codebeamer.controller.importexport.RoundtripExportCommand.ParagraphReNumbering"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab" %>

<meta name="decorator" content="popup"/>
<meta name="module" content="tracker"/>
<meta name="moduleCSSClass" content="trackersModule newskin" />

<link rel="stylesheet" href="stylesheet/roundTripExport.css" type="text/css" media="all" />

<ui:actionMenuBar>
		<ui:breadcrumbs showProjects="false" >
			<span class="breadcrumbs-separator">&raquo;</span><ui:pageTitle prefixWithIdentifiableName="false"><spring:message code="issue.import.roundtrip.export.title" /></ui:pageTitle>
		</ui:breadcrumbs>
</ui:actionMenuBar>

<spring:message var="exportButton" code="tracker.issues.exportToWord.export.button"/>
<spring:message var="cancelButton" code="button.cancel"/>

<form:form modelAttribute="command" >
<form:hidden path="tracker_id"/>
<form:hidden path="revision"/>
<c:if test="${not empty command.viewId }">
	<form:hidden path="viewId"/>
</c:if>
<form:hidden path="sprintHistory"/>

<script type="text/javascript">
	function showBusy() {
		ajaxBusyIndicator.showBusyPage("tracker.issues.exportToWord.wait", false, { width: "32em"});
	}
</script>

<c:set var="advancedWordExport">
	<%--
	<spring:message var="advancedLabel" code="tracker.issues.exportToOffice.msproject.opts.advanced" />
	<ui:collapsingBorder label="${advancedLabel}" cssStyle="margin: 10px;">
--%>
	<div id="advancedWordExportWrapper">
		<label style="margin:10px;">
			<spring:message code="tracker.issues.exportToWord.paragraph.numbering" text="Paragraph numbering:" />
			<form:select path="paragraphReNumbering">
				<c:forEach var="renumberingOpt" items="<%=ParagraphReNumbering.values()%>">
					<form:option value="${renumberingOpt}"><spring:message code="tracker.issues.exportToWord.paragraph.numbering.option.${renumberingOpt}" text="${renumberingOpt}" /></form:option>
				</c:forEach>
			</form:select>
		</label>
	</div>
<%--
	</ui:collapsingBorder>
--%>
</c:set>

<tab:tabContainer id="officeExportOptionsTabContainer" skin="cb-box" selectedTabPaneId="wordExportTabPane" jsTabListener="onTabChange">
	<spring:message var="label" code="tracker.issues.exportToOffice.wordTab.label" />
	<tab:tabPane id="wordExportTabPane" tabTitle='<img src="images/newskin/action/icon_word.png" class="tabIcon"/>${label}'>
		<ui:actionBar>
			&nbsp;&nbsp;
			<c:choose>
				<c:when test="${command.allowToExportWord}">
					<input type="submit" class="button" value="${exportButton}" onclick="showBusy(); return true;"/>
				</c:when>
				<c:otherwise>
					<input type="submit" class="button" disabled="disabled" value="${exportButton}"/>
				</c:otherwise>
			</c:choose>
			<input type="button" class="button cancelButton" value="${cancelButton}" onclick="inlinePopup.close(); return false;" />
		</ui:actionBar>

		<jsp:include page="./includes/exportExplanationMessage.jsp" />

		<div class="contentWithMargins">

			<div class="exportBlock">
				<label for="simpleWordExport" class="exportKind">
					<form:radiobutton id="simpleWordExport" path="exportKind" value="simpleWordExport"/>
					<spring:message code="tracker.issues.exportToWord.simple.title" text="Simple Word Export" />
				</label>
				<div class="exportExplanation">
					<spring:message code="tracker.issues.exportToWord.simple.explanation" />
				</div>
				<div class="options" style="display:none;">
					<h3><spring:message code="tracker.issues.exportToWord.roundtrip.export.options.title" text="Export with:" /></h3>
					<div style="margin-left:10px">
						<label style="display:inline;" for="exportProperties2"><form:checkbox id="exportProperties2" path="exportProperties"/>
							<spring:message code="tracker.issues.exportToWord.roundtrip.export.options.properties" text="Properties" />
						</label>
						<label style="display:inline;" for="exportItemHistory2"><form:checkbox id="exportItemHistory2" path="exportItemHistory"/>
							<spring:message code="tracker.issues.exportToWord.roundtrip.export.options.exportItemHistory" text="Export history" />
						</label>
						<c:if test="${command.tracker.isTestCase()}">
							<label style="display:inline;" for="exportTestSteps"><form:checkbox id="exportTestSteps" path="exportTestCasesWithTestSteps"/>
								<spring:message code="tracker.issues.exportToWord.export.test.steps" text="Export Test Steps" />
							</label>
						</c:if>

						<spring:message var="externalLinksTooltip" code="tracker.issues.exportToWord.roundtrip.export.options.externalLinks.tooltip" />
						<label for="externalLinks2" title="${externalLinksTooltip}">
							<form:checkbox id="externalLinks2" path="externalLinks" />
							<spring:message code="tracker.issues.exportToWord.roundtrip.export.options.externalLinks" />
						</label>

						<label style="display:inline;" for="exportReviews"><form:checkbox id="exportReviews" path="exportReviews"/>
							<spring:message code="tracker.issues.exportToWord.export.review.label" text="Export last Review result" />
						</label>

						${advancedWordExport}
					</div>
				</div>
			</div>

			<c:if test="${!command.hideRoundtripExport}">
				<div class="exportBlock">
					<label for="roundtripWordExport" class="exportKind">
						<form:radiobutton id="roundtripWordExport" path="exportKind" value="roundtripWordExport"/>
						<spring:message code="tracker.issues.exportToWord.roundtrip.title"/>
					</label>
					<div class="exportExplanation">
						<spring:message code="tracker.issues.exportToWord.roundtrip.explanation" />
					</div>

					<div class="options">
						<h3><spring:message code="tracker.issues.exportToWord.roundtrip.export.options.title" /></h3>
						<div style="margin-left:10px">
							<label for="contentEditable"><form:checkbox id="contentEditable" path="contentEditable"/>
								<spring:message code="tracker.issues.exportToWord.roundtrip.export.options.editable.content" />
							</label>
							<label style="display:inline;" for="exportProperties"><form:checkbox id="exportProperties" path="exportProperties"/>
								<spring:message code="tracker.issues.exportToWord.roundtrip.export.options.properties"/>
							</label>
							<label style="display:inline;" for="exportItemHistory"><form:checkbox id="exportItemHistory" path="exportItemHistory"/>
								<spring:message code="tracker.issues.exportToWord.roundtrip.export.options.exportItemHistory" />
							</label>

							<spring:message code="tracker.issues.exportToWord.roundtrip.export.options.editable.properties.tooltip" var="tooltip" />
							<label style="display:inline;" id="propertiesEditableLabel" for="propertiesEditable" title="${tooltip}">
								<form:checkbox id="propertiesEditable" path="propertiesEditable"/>
								<spring:message code="tracker.issues.exportToWord.roundtrip.export.options.editable.properties" />
							</label>
							<label for="exportComments"><form:checkbox id="exportComments" path="exportComments"/>
								<spring:message code="tracker.issues.exportToWord.roundtrip.export.options.comments"/>
							</label>
							<label for="externalLinks" title="${externalLinksTooltip}">
								<form:checkbox id="externalLinks" path="externalLinks" />
								<spring:message code="tracker.issues.exportToWord.roundtrip.export.options.externalLinks" />
							</label>


							<label style="display:inline;" for="exportReviews2"><form:checkbox id="exportReviews2" path="exportReviews"/>
								<spring:message code="tracker.issues.exportToWord.export.review.label" text="Export last Review result" />
							</label>
							<label style="display:inline-block; margin-left: 10px;" for="exportReviewComments2">
							<form:checkbox disabled="true" id="exportReviewComments2" path="exportReviewComments"/>
								<spring:message code="tracker.issues.exportToWord.export.review.comments.label" text="Export last Review comments" />
							</label>
							${advancedWordExport}
						</div>
					</div>
				</div>
			</c:if>
		</div>
	</tab:tabPane>

	<spring:message var="label" code="tracker.issues.exportToOffice.excelTab.label" />
	<tab:tabPane id="excelExportTabPane" tabTitle='<img src="images/icon_excel_export2_green.png" class="tabIcon"/>${label}'>
		<ui:actionBar>
			&nbsp;&nbsp;<input type="submit" class="button" value="${exportButton}" onclick="showBusy(); return true;"/>
			<input type="button" class="button cancelButton" value="${cancelButton}" onclick="inlinePopup.close(); return false;" />
		</ui:actionBar>

		<jsp:include page="./includes/exportExplanationMessage.jsp" />

		<div class="contentWithMargins">

			<div class="exportBlock">
				<label for="excelExport" class="exportKind">
					<form:radiobutton id="excelExport" path="exportKind" value="excelExport"/>
					<spring:message code="tracker.issues.exportToOffice.excel.export"/>
				</label>
				<div class="exportExplanation">
					<spring:message code="tracker.issues.exportToOffice.excel.export.explanation.1"/>
					<spring:message var="helpTitle" code="tracker.issues.exportToOffice.excel.export.explanation.2"/>
					<ui:helpLink helpURL="https://codebeamer.com/cb/wiki/597447" target="_blank" title="${helpTitle}"/>
				</div>

				<div class="options" style="display:none;">
			        <spring:message var="title" code="tracker.issues.exportToOffice.exportRatings.title" />
			        <label for="exportRatings" title="${title}">
			            <form:checkbox path="exportRatings" id="exportRatings"/>
			            <spring:message code="tracker.issues.exportToOffice.exportRatings" />
			        </label>
				 </div>


				<div class="options" style="display:none;">
					<label>
						<form:checkbox id="addDescriptionToExcelExportCheckbox" path="addDescriptionToExcelExport" disabled="false" />
						<spring:message code="tracker.issues.exportToOffice.excel.roundtrip.export.description.too" text="Export description" />
					</label>
				</div>

                <c:set var="exportDatesAsUserFormattedStringsFragment">
                    <c:set var="user" value="${pageContext.request.userPrincipal}"/>
                    <c:if test="${user != null}">
                        <div class="options" style="display:none;">
                            <label>
                                <form:checkbox path="exportDatesAsUserFormattedStrings" disabled="false" />
                                <c:set var="userDateFormat"><c:out value="${user.dateFormatPattern}" /></c:set>
                                <c:set var="timeZone"><c:out value="${user.timeZonePattern}"/></c:set>
                                <spring:message code="tracker.issues.exportToOffice.excel.export.date.as.user.format"
                                                arguments="${userDateFormat}||${timeZone}" argumentSeparator="||"
                                />
                            </label>
                        </div>
                    </c:if>
                </c:set>
                ${exportDatesAsUserFormattedStringsFragment}
            </div>

			<c:if test="${!command.hideRoundtripExport}">
				<div class="exportBlock">
					<label for="roundtripExcelExport" class="exportKind">
						<form:radiobutton id="roundtripExcelExport" path="exportKind" value="roundtripExcelExport"/>
						<spring:message code="tracker.issues.exportToOffice.excel.roundtrip.export"
								text="Excel Roundtrip Export" />
					</label>
					<div class="exportExplanation">
						<spring:message code="tracker.issues.exportToOffice.excel.roundtrip.export.explanation.1" />
						<spring:message var="helpTitle" code="tracker.issues.exportToOffice.excel.roundtrip.export.explanation.2" />
						<ui:helpLink helpURL="https://codebeamer.com/cb/wiki/587723" target="_blank" title="${helpTitle}"/>
						<spring:message code="tracker.issues.exportToOffice.excel.roundtrip.export.explanation.3" />
					</div>
					<div class="options" style="display:none;">
						<label>
							<form:checkbox id="addDescriptionToExcelExportCheckbox" path="addDescriptionToExcelExport" disabled="false" />
							<spring:message code="tracker.issues.exportToOffice.excel.roundtrip.export.description.too" text="Export description" />
						</label>
					</div>

                    ${exportDatesAsUserFormattedStringsFragment}
				</div>
			</c:if>
		</div>
	</tab:tabPane>

	<c:if test="${!command.hideMsProjectExport}">
		<spring:message var="label" code="tracker.issues.exportToOffice.msProjectTab.label" />
		<tab:tabPane id="msProjectExportTabPane" tabTitle='<img src="images/icon_msproject.png" class="tabIcon"/>${label}'>
			<ui:actionBar>
				&nbsp;&nbsp;<input type="submit" class="button" value="${exportButton}" onclick="showBusy(); return true;"/>
				<input type="button" class="button cancelButton" value="${cancelButton}" onclick="inlinePopup.close(); return false;" />
			</ui:actionBar>

			<jsp:include page="./includes/exportExplanationMessage.jsp" />

			<div class="contentWithMargins">
				<div class="exportBlock">
					<label for="msprojectExport" class="exportKind">
						<form:radiobutton id="msprojectExport" path="exportKind" value="msprojectExport"/>
						<spring:message code="tracker.issues.exportToOffice.msproject.export" />
					</label>
					<div class="exportExplanation">
						<spring:message code="tracker.issues.exportToOffice.msproject.export.explanation.1" />
						<a href="https://codebeamer.com/cb/wiki/606907" target="_blank">
							<spring:message code="tracker.issues.exportToOffice.msproject.export.explanation.2" />
						</a>
					</div>
					<div class="options">
						<spring:nestedPath path="msProjectExportOptions">
							<p>
								<spring:message code="tracker.issues.exportToOffice.msproject.opts.schedule.mode.label" />
								<form:select path="taskScheduleMode">
									<c:forEach var="taskSchedule" items="${command.msProjectExportOptions.scheduleModes}">
										<form:option value="${taskSchedule}" >
											<spring:message code="tracker.issues.exportToOffice.msproject.opts.schedule.modes.${taskSchedule}" />
										</form:option>
									</c:forEach>
								</form:select>
							</p>

							<spring:message code="tracker.issues.exportToOffice.msproject.opts.convert.story.points" text="Convert Story Points to hours:"/>
							<spring:message var="storyPointsTitle" code="tracker.issues.exportToOffice.msproject.opts.convert.story.points.hint" />
							<form:input path="storyPointsToHours" size="10" cssStyle="marign-bottom:5px;" />
							<form:errors  cssStyle="display:block;" path="storyPointsToHours" cssClass="invalidfield"/>

							<div class="hint" style="margin-top:5px;">${storyPointsTitle}</div>

							<spring:message var="advancedLabel" code="tracker.issues.exportToOffice.msproject.opts.advanced" />
							<ui:collapsingBorder label="${advancedLabel}">
								<table cellpadding="5" cellspacing="0">
									<tr>
										<td>
											<spring:message code="tracker.issues.exportToOffice.msproject.opts.hoursPerDay" />:
										</td>
										<td>
											<form:input path="hoursPerDay" />
											<form:errors path="hoursPerDay" cssClass="invalidfield"/>
										</td>
									</tr>
									<tr>
										<td>
											<spring:message code="tracker.issues.exportToOffice.msproject.opts.hoursPerWeek" />:
										</td>
										<td>
											<form:input path="hoursPerWeek" />
											<form:errors path="hoursPerWeek" cssClass="invalidfield"/>
										</td>
									</tr>
									<tr>
										<td>
											<spring:message code="tracker.issues.exportToOffice.msproject.opts.daysPerMonth" />:
										</td>
										<td>
											<form:input path="daysPerMonth" />
											<form:errors path="daysPerMonth" cssClass="invalidfield"/>
										</td>
									</tr>
								</table>
							</ui:collapsingBorder>
						</spring:nestedPath>
					</div>
				</div>
			</div>
		</tab:tabPane>
	</c:if>

</tab:tabContainer>

<div class="exportTemplate contentWithMargins hideOnTabChange">
	<jsp:include page="./includes/selectExportTemplateFragment.jsp" />
</div>

</form:form>
<script>
	var exportIsTestRunExport = ${command.tracker.isTestRun()};
</script>
<script type="text/javascript" src="<ui:urlversioned value='/bugs/importing/roundTripExport.js' />"></script>


