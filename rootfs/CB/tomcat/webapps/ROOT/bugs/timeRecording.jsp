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
<meta name="module" content="members"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>

<script language="JavaScript" type="text/javascript">
<!-- Hide script from old browsers

function cancelForm(e) {
	closePopupInline();
	return false;
}
// -->
</script>

<form:form>
	<form:hidden path="tracker_id"/>
	<form:hidden path="parent_id"/>
	<form:hidden path="transition_id"/>
	<form:hidden path="referrerUrl"/>

	<ui:actionMenuBar>
		<spring:message code="issue.time.recording.title" text="Work done by {0}" arguments="${user.name}" htmlEscape="true" />
		<br/>
		<c:out value="${subject}"/>
	</ui:actionMenuBar>

	<jsp:useBean id="command" beanName="command" scope="request" type="com.intland.codebeamer.controller.bugs.TimeRecordingForm" />

	<div class="actionBar">
		<spring:message var="saveButton" code="button.save"/>
		<input type="submit" class="button" name="SAVE" value="${saveButton}"/>

		<spring:message var="cancelButton" code="button.cancel"/>
		<input type="submit" class="button cancelButton" name="_cancel" value="${cancelButton}" onclick="return cancelForm(this);"/>
	</div>

	<spring:hasBindErrors name="command">
		<ui:showSpringErrors errors="${errors}" />
	</spring:hasBindErrors>

<div class="contentWithMargins" >
	<table border="0" class="formTableWithSpacing" cellpadding="1">
		<c:forEach items="${command.layoutList}" var="field">
			<jsp:useBean id="field" beanName="field" type="com.intland.codebeamer.persistence.dto.TrackerLayoutLabelDto" />
			<c:set var="propertyName" value="${field.property}"/>

			<tr valign="middle">
				<td nowrap width="10%" class="labelCell ${field.required ? 'mandatory' : 'optional'}">
					<spring:message code="tracker.field.${field.label}.label" text="${field.label}"/>:
				</td>

				<td nowrap width="40%">
					<c:choose>
						<c:when test="${field.id eq 3}">
							<form:input path="summary" maxlength="255" cssStyle="width:30em;"/>
							<br/>
							<form:errors path="summary" cssClass="invalidfield"/>
						</c:when>

						<c:when test="${field.id eq 8}">
							<ui:calendarPopup textFieldId="startDate" otherFieldId="endDate" showTime="false">
								<form:input path="startDate" id="startDate" size="20" maxlength="30"/>&nbsp;
							</ui:calendarPopup>
							<br/>
							<form:errors path="startDate" cssClass="invalidfield"/>
						</c:when>

						<c:when test="${field.id eq 9}">
							<ui:calendarPopup textFieldId="endDate" otherFieldId="startDate" showTime="false">
								<form:input path="closeDate" id="endDate" size="20" maxlength="30"/>&nbsp;
							</ui:calendarPopup>
							<br/>
							<form:errors path="closeDate" cssClass="invalidfield"/>
						</c:when>

						<c:when test="${field.id eq 10 or field.id eq 11}">
							<form:input path="${propertyName}" size="10" maxlength="30"/>
							<br/>
							<form:errors path="${propertyName}" cssClass="invalidfield"/>
						</c:when>

						<c:when test="${field.choiceField}">
							<form:select path="category">
								<form:options items="${categories}" itemValue="value" itemLabel="label"/>
							</form:select>
						</c:when>

					</c:choose>
				</td>
			</tr>

		</c:forEach>
	</table>

	<table width="100%" border="0" class="formTableWithSpacing" cellpadding="1">
		<tr valign="middle">
			<td nowrap align="center" width="33%">
				<spring:message code="issue.time.recording.estimate.label" text="Original estimate" />
			</td>
			<td nowrap align="center" width="33%">
				<spring:message code="issue.time.recording.total.label" text="Actual work" />
			</td>
			<td nowrap align="center" width="33%">
				<spring:message code="issue.time.recording.personally.label" text="Personally" />
			</td>
		</tr>
		<tr valign="middle">
			<td nowrap align="center" width="33%">
				<span style="font-size: 16px; font-weight: bold;">
					<c:out value="${estimation}" default="--" escapeXml="true"/>
				</span>
			</td>
			<td nowrap align="center" width="33%">
				<span style="font-size: 16px; font-weight: bold; color: ${overtime ? 'red' : 'green'};">
					<c:out value="${recording}" default="--" escapeXml="true"/>
				</span>
			</td>
			<td nowrap align="center" width="33%">
				<span style="font-size: 16px; font-weight: bold;">
					<c:out value="${personally}" default="--" escapeXml="true"/>
				</span>
			</td>
		</tr>
	</table>

	<ui:title style="top-sub-headline-decoration" bottomMargin="5" separatorGapHeight="2" titleStyle="" topMargin="10" >
		<spring:message code="issue.time.recording.recently.label" text="Latest recorded activities" />
	</ui:title>

	<c:choose>
		<c:when test="${empty workLog}">
			<spring:message code="issue.time.recording.recently.none" text="{0} did not report activities on this issue yet" arguments="${user.name}" htmlEscape="true" />
		</c:when>

		<c:otherwise>
			<display:table sort="external" export="false" name="${workLog}" id="record" cellpadding="0"	pagesize="5" class="relationsExpander"
												decorator="com.intland.codebeamer.ui.view.table.TrackerSimpleLayoutDecorator"
												>
				<display:setProperty name="paging.banner.placement" value="none" />
<%--
				<display:column titleKey="tracker.field.From.label" 		property="startDate"  sortable="false" headerClass="dateData"  class="dateData" style="width:5%" />
				<display:column titleKey="tracker.field.Until.label"   		property="endDate"    sortable="false" headerClass="dateData"  class="dateData" style="width:5%"/>
--%>
				<display:column titleKey="tracker.field.Date.label" sortable="false" headerClass="dateData"  class="dateData" style="width:5%">
					<tag:formatDate value="${record.startDate}" type="date"/>
				</display:column>
				<display:column titleKey="tracker.field.Activity.label"   	property="name"       sortable="false" headerClass="textData" />
				<display:column titleKey="tracker.field.Kind.label"   	  	property="priority"   sortable="false" headerClass="textData"   class="textData"   style="width:5%"/>
				<display:column titleKey="tracker.field.Spent Effort.label" property="spentMillis" sortable="false" headerClass="numberData" class="numberData" style="width:5%"/>
			</display:table>

			<c:if test="${moreEntries gt 0}">
				<div class="subtext">
					<spring:message code="issue.time.recording.recently.more" text="{0} more entries not shown" arguments="${moreEntries}" />
				</div>
			</c:if>
		</c:otherwise>
	</c:choose>

	<script type="text/javascript">
		$(function() {
			// all links in the time-entry should open in the parent window, so the page is not loaded twice
			$("#record a").attr("target", "_parent");
			// prevent multiple save
			$('form#command').submit(function() {
				$('input[name="SAVE"]').prop("disabled", true);
			});
		});
	</script>
</div>
</form:form>
