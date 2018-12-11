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
<%@ taglib uri="uitaglib" prefix="ui" %>

<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>

<style type="text/css">
	.popupBody {
		padding: 0px !important;
	}
	.ditch-tab-skin-cb-box {
		padding: 5px 15px;
	}
	.actionBar {
		border: 0px !important;
	}
	#holidays {
		border-bottom: 0px;
	}
	.subtext {
		margin-top: 15px;
		margin-bottom: 5px !important;
	}
	.displaytag {
		border-bottom: 0px !important;
	}
	#editCalendarForm > .subtext {
		margin-left: 15px;
	}
	.formTableWithSpacing {
		margin-top: 0px !important;
	}
</style>

<c:set var="DEBUG" value="false"/>
<c:if test="${DEBUG}">
	<pre class="debug">
		editCalendarForm: ${editCalendarForm}
	</pre>
</c:if>

<c:choose>
	<c:when test="${empty editCalendarForm.proj_id}">
		<%-- system calendar --%>
		<meta name="decorator" content="main"/>
		<meta name="module" content="sysadmin"/>
		<meta name="moduleCSSClass" content="newskin sysadminModule"/>

		<ui:actionMenuBar>
			<ui:pageTitle><spring:message code="calendar.worktime.title" text="Work Time Calendar"/></ui:pageTitle>
		</ui:actionMenuBar>
	</c:when>
	<c:otherwise>
		<%-- project calendar --%>
		<meta name="decorator" content="popup"/>
		<meta name="module" content="admin"/>
		<meta name="moduleCSSClass" content="newskin adminModule"/>
	</c:otherwise>
</c:choose>

<script type="text/javascript">
	function updateHoursControls(workday, dayOfWeek) {
		document.getElementById("weekday" + dayOfWeek + ".hours").style.color = workday.checked ? "#000" : "#666";
	}
</script>

<form:form commandName="editCalendarForm" method="POST" >

	<form:hidden path="dir_id"/>
	<form:hidden path="addMoreCounter"/>

	<ui:actionBar>
		<spring:message var="saveButton" code="button.save" text="Save"/>
		<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>
		<spring:message var="addMoreButton" code="calendar.addMore.label" text="Add more"/>
		<spring:message var="addMoreTitle" code="calendar.addMore.tooltip" text="Click to add more entries"/>

		&nbsp;&nbsp;<input type="submit" class="button" value="${saveButton}" />
		&nbsp;&nbsp;<input type="submit" class="linkButton" name="addMore" value="${addMoreButton}" title="${addMoreTitle}"/>
		&nbsp;&nbsp;<input type="submit" class="cancelButton" name="_cancel" value="${cancelButton}" />
		<span class="rightAlignedDescription">
			<c:url var="systemCalendarURL" value="/sysadmin/editCalendar.spr"/>
			<spring:message code="project.administration.calendar.tooltip" text="The special project calendar is derived from the default system calendar, and should only contain project specific deviations." arguments="${systemCalendarURL}"/>
		</span>
	</ui:actionBar>

	<div class="subtext" style="margin-bottom:10px;">
		<spring:message code="calendar.hint" text='Note: Hours is a comma-separated list of business hour periods in 24-hour format, e.g. "9:00 - 18:00" or "8:30 - 12:00, 13:00 - 17:30".'/>
	</div>

	<tab:tabContainer id="calendar" skin="cb-box">
		<spring:message var="weekdaysLabel" code="calendar.weekdays.label" text="Default Business Hours"/>

		<tab:tabPane id="weekdays" tabTitle="${weekdaysLabel}">
		<div class="subtext" style="margin-bottom:10px;">
			<spring:message code="calendar.weekdays.hint" text="There can be multiple definitions for the same day-of-the-week, for different periods Starting at/Valid Until the specified dates [<i>{0}</i> or <i>yyyy-MM-dd</i>]." arguments="${fullDateFormat}"/>
		</div>
		<table class="displaytag formTableWithSpacing">
			<tr>
				<th align="left" width="5%"><spring:message code="calendar.weekday.validFrom.label" text="Starting at"/></th>
				<th align="left" width="5%"><spring:message code="calendar.weekday.validUntil.label" text="Valid until"/></th>
				<th align="left" width="5%"><spring:message code="calendar.weekday.label" text="Weekday"/></th>
				<th align="center" width="2%"><spring:message code="calendar.weekday.working.label" text="Working"/></th>
				<th align="left"><spring:message code="calendar.weekday.hours.label" text="Hours"/></th>
			</tr>
			<c:forEach var="weekday" items="${editCalendarForm.weekday}" varStatus="status">
				<spring:nestedPath path="weekday[${status.count - 1}]">
					<tr class="${(status.count % 2 == 0) ? 'even' : 'odd'}">
						<td align="left" width="5%" nowrap>
							<ui:calendarPopup textFieldId="weekday${status.count - 1}_validFrom" otherFieldId="weekday${status.count - 1}_validUntil" showTime="false">
								<form:input id="weekday${status.count - 1}_validFrom" path="validFrom" size="12" maxlength="30" cssClass="startDate" />
							</ui:calendarPopup>
						</td>
						<td align="left" width="5%" nowrap>
							<ui:calendarPopup textFieldId="weekday${status.count - 1}_validUntil" otherFieldId="weekday${status.count - 1}_validFrom" showTime="false">
								<form:input id="weekday${status.count - 1}_validUntil" path="validUntil" size="12" maxlength="30" cssClass="closeDate" />
							</ui:calendarPopup>
						</td>
						<td align="left" width="5%">
							<form:select path="day">
								<form:options items="${daysOfWeek}" itemValue="key" itemLabel="value" />
							</form:select>
						</td>
						<td align="center" width="2%">
							<form:checkbox path="workday" onchange="updateHoursControls(this, ${status.count - 1})" cssClass="formcheckbox" />
						</td>
						<td align="left" nowrap>
							<form:input path="hours" cssStyle="color: ${weekday.workday ? '#000' : '#666'}" size="30" maxlength="80" />
							<form:errors cssClass="invalidfield"/>
						</td>
					</tr>
				</spring:nestedPath>
			</c:forEach>
		</table>
		</tab:tabPane>

		<spring:message var="holidaysLabel" code="calendar.specialdays.label" text="Special Calendar Days"/>

		<tab:tabPane id="holidays" tabTitle="${holidaysLabel}">
		<div class="subtext" style="margin-bottom:10px;">
			<spring:message code="calendar.specialdays.hint" text="Special calendar days are deviations form the default day-of-the-week pattern, and can be either full dates [<i>{0}</i> or <i>yyyy-MM-dd</i>] or a day-of-month [<i>{1}</i>] (in the years From/To)." arguments="${fullDateFormat},${monthDayFormat}"/>
		</div>

		<spring:message code="calendar.specialday.date.tooltip" var="calendar_specialday_date_tooltip" arguments="${fullDateFormat},${monthDayFormat}"/>
		<spring:message code="calendar.specialday.validFrom.tooltip" var="calendar_specialday_validFrom_tooltip" />
		<spring:message code="calendar.specialday.validUntil.tooltip" var="calendar_specialday_validUntil_tooltip"/>
		<spring:message code="calendar.specialday.status.tooltip" var="calendar_specialday_status_tooltip" />
		<spring:message code="calendar.specialday.hours.tooltip" var="calendar_specialday_hours_tooltip" />
		<spring:message code="calendar.specialday.description.tooltip" var="calendar_specialday_description_tooltip"/>

		<table class="displaytag formTableWithSpacing">
			<tr>
				<th align="left" width="5%"><spring:message code="calendar.specialday.date.label" text="Date"/></th>
				<th align="left" width="3%"><spring:message code="calendar.specialday.validFrom.label" text="From"/></th>
				<th align="left" width="3%"><spring:message code="calendar.specialday.validUntil.label" text="Until"/></th>
				<th align="left" width="3%"><spring:message code="calendar.specialday.status.label" text="Status"/></th>
				<th align="left" width="12%"><spring:message code="calendar.specialday.hours.label" text="Hours"/></th>
				<th align="left"><spring:message code="calendar.specialday.description.label" text="Description"/></th>
			</tr>
			<c:forEach var="holiday" items="${editCalendarForm.holiday}" varStatus="status">
				<spring:nestedPath path="holiday[${status.count - 1}]">
					<tr class="${(status.count % 2 == 0) ? 'even' : 'odd'}">
						<td align="left" width="5%" nowrap>
							<c:choose>
								<c:when test="${not empty holiday.disabled && holiday.disabled}">
									<form:input id="holiday${status.count - 1}_date" path="date" size="12" maxlength="20" title="${calendar_specialday_date_tooltip}" disabled="true" />
								</c:when>
								<c:otherwise>
									<ui:calendarPopup textFieldId="holiday${status.count - 1}_date" showTime="false">
										<form:input id="holiday${status.count - 1}_date" path="date" size="12" maxlength="20" title="${calendar_specialday_date_tooltip}" />
									</ui:calendarPopup>
								</c:otherwise>
							</c:choose>
						</td>
						<td align="left" width="3%">
							<form:input path="validFrom" size="4" maxlength="4" title="${calendar_specialday_validFrom_tooltip}" disabled="${holiday.disabled}" />
						</td>
						<td align="left" width="3%">
							<form:input path="validUntil" size="4" maxlength="4" title="${calendar_specialday_validUntil_tooltip}" disabled="${holiday.disabled}" />
						</td>
						<td align="left" width="3%">
							<form:select path="state" title="${calendar_specialday_status_tooltip}" disabled="${holiday.disabled}">
								<form:options items="${states}" itemValue="key" itemLabel="value" />
							</form:select>
						</td>
						<td align="left" width="12%">
							<form:input path="hours" size="30" maxlength="80" title="${calendar_specialday_hours_tooltip}" disabled="${holiday.disabled}"/>
						</td>
						<td align="left" nowrap>
							<form:input path="description" size="40" maxlength="80" title="${calendar_specialday_description_tooltip}" disabled="${holiday.disabled}"/>
							<c:if test="${not empty holiday.disabled && holiday.disabled}">
								<img src="<c:url value='/images/newskin/action/help.png' />" title="<spring:message code='calendar.info.global.system.date' />" />
							</c:if>
							<form:errors cssClass="invalidfield"/>
						</td>
					</tr>
				</spring:nestedPath>
			</c:forEach>
		</table>
		</tab:tabPane>
	</tab:tabContainer>
</form:form>
