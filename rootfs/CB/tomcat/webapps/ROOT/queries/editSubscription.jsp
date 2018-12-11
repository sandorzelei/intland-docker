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

<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<link rel="stylesheet" href="<ui:urlversioned value='/queries/queries.less' />" type="text/css" media="all" />
<script type="text/javascript" src="<ui:urlversioned value='/queries/subscription.js'/>"></script>

<ui:actionMenuBar>
	<c:choose>
		<c:when test="${isNew}">
			<spring:message code="queries.new.subscription.label" text="New Query Subscription"/>
		</c:when>
		<c:otherwise>
			<spring:message code="queries.edit.subscription.label" text="Edit Query Subscription"/>
		</c:otherwise>
	</c:choose>
</ui:actionMenuBar>

<div class="actionBar">
	<spring:message var="saveButton" code="button.save"/>
	<input type="button" class="button" id="saveButton" value="${saveButton}"/>
	
	<spring:message var="cancelButton" code="button.cancel"/>
	<input type="button" class="button cancelButton" value="${cancelButton}" onclick="inlinePopup.close(); return false;"/>
</div>

<div class="querySubscriptionForm">
	<table class="formTableWithSpacing">
		<tr class="nameTr">
			<td class="labelCell mandatory"><spring:message code="queries.subscription.name.label"/></td>
			<td>
				<input type="text" id="subscriptionName" value="<c:if test="${not empty existingName}"><c:out value="${existingName}"/></c:if>">
			</td>
		</tr>
		<tr class="recipientsTr">
			<td class="labelCell"><spring:message code="queries.subscription.recipients.label"/></td>
			<td>
				<select id="recipients" multiple="multiple">
					<option value="0" selected="selected"><spring:message code="queries.personal.subscription"/></option>
					<c:forEach items="${possibleRecipients}" var="entry">
						<c:set var="project" value="${entry.key}"/>
						<c:set var="roles" value="${entry.value}"/>
						<optgroup label="${project.name}">
							<c:forEach items="${roles}" var="role">
								<option value="${project.id}_${role.id}">
									<spring:message code="role.${role.name}.label" text="${role.name}"/>
								</option> 
							</c:forEach>
						</optgroup>
					</c:forEach>
				</select>
			</td>
			<td class="roleWarning" rowspan="2">
				<div class="warning"><spring:message code="queries.subscription.job.warning" arguments="${maxUserNumber}"/></div>
			</td>
		</tr>
		<tr class="emptySubscriptionTr">
			<td></td>
			<td colspan="2">
				<input type="checkbox" id="thresholdCheckbox"<c:if test="${not empty existingResultThreshold}"> checked="checked"</c:if>>
				<label for="thresholdCheckbox">
					<spring:message code="queries.subscription.send.if.number.of.items"/>
					<input min="0" onkeyup="if(this.value.length != 0 && this.value < 0) this.value=0;" id="thresholdNumber" type="number" placeholder="3"<c:if test="${not empty existingResultThreshold}"> value="${existingResultThreshold}"</c:if>>
				</label>
			</td>
		</tr>
		<tr>
			<td class="labelCell"><spring:message code="queries.subscription.frequency.label"/></td>
			<td id="frequencyTd" colspan="2">
				<div class="frequency">
					<ul>
						<li>
							<input id="frequency_daily" name="frequency" value="daily" type="radio"<c:if test="${empty existingFrequencyData || (not empty existingFrequencyData && existingFrequencyData.frequencyType == 'DAILY')}"> checked="checked"</c:if>>
							<label for="frequency_daily"><spring:message code="queries.frequency.daily"/></label>
						</li>
						<li>
							<input id="frequency_weekly" name="frequency" value="weekly" type="radio"<c:if test="${not empty existingFrequencyData && existingFrequencyData.frequencyType == 'WEEKLY'}"> checked="checked"</c:if>>
							<label for="frequency_weekly"><spring:message code="queries.frequency.weekly"/></label>
						</li>
						<li>
							<input id="frequency_monthly" name="frequency" value="monthly" type="radio"<c:if test="${not empty existingFrequencyData && existingFrequencyData.frequencyType == 'MONTHLY'}"> checked="checked"</c:if>>
							<label for="frequency_monthly"><spring:message code="queries.frequency.monthly"/></label>
						</li>
					</ul>
				</div>
				<div class="frequencyOptions" id="frequency_weeklyDiv"<c:if test="${not empty existingFrequencyData && existingFrequencyData.frequencyType == 'WEEKLY'}"> style="display: block"</c:if>>
					<label><spring:message code="queries.subscription.recurs.on.label"/></label>
					<ul class="dayOfWeeks">
						<c:forEach items="${daysOfWeek}" var="day">
							<li>
								<input type="checkbox" id="dayOfWeek${day.key}" value="${day.key}">
								<label for="dayOfWeek${day.key}">${day.value}</label>
							</li>
						</c:forEach>
					</ul>
				</div>
				<div class="frequencyOptions" id="frequency_monthlyDiv"<c:if test="${not empty existingFrequencyData && existingFrequencyData.frequencyType == 'MONTHLY'}"> style="display: block"</c:if>>
					<div class="monthOption">
						<input type="radio" name="monthOption" id="monthOption_specificDay"<c:if test="${empty existingFrequencyData || existingFrequencyData.frequencyType != 'MONTHLY' || (not empty existingFrequencyData && not empty existingFrequencyData.dayOfMonth)}"> checked="checked"</c:if>>
						<label for="monthOption_specificDay">
							<span><spring:message code="queries.subscription.recurs.on.label"/></span>
							<select id="monthOption_specificDay_day">
								<option value="1"<c:if test="${not empty existingFrequencyData && existingFrequencyData.dayOfMonth == '1'}"> selected="selected"</c:if>><spring:message code="queries.subscription.first.day.of.label"/></option>
								<c:forEach var="day" begin="2" end="30">
									<option value="${day}"<c:if test="${not empty existingFrequencyData && existingFrequencyData.dayOfMonth != 'L' && existingFrequencyData.dayOfMonth == day.toString()}"> selected="selected"</c:if>><spring:message code="queries.subscription.day.label"/> <c:out value="${day}"/></option>
								</c:forEach>
								<option value="L"<c:if test="${not empty existingFrequencyData && existingFrequencyData.dayOfMonth == 'L'}"> selected="selected"</c:if>><spring:message code="queries.subscription.last.day.of.label"/></option>
							</select>
							<span><spring:message code="queries.subscription.of.every.month.label"/></span>
						</label>
					</div>
					<div class="monthOption">
						<input type="radio" name="monthOption" id="monthOption_specificWeekDay"<c:if test="${not empty existingFrequencyData && not empty existingFrequencyData.monthlyWeekdayNumber}"> checked="checked"</c:if>>
						<label for="monthOption_specificWeekDay">
							<span><spring:message code="queries.subscription.recurs.on.the.label"/></span>
							<select id="monthOption_specificWeekDay_number">
								<option value="1"<c:if test="${not empty existingFrequencyData && existingFrequencyData.monthlyWeekdayNumber == '1'}"> selected="selected"</c:if>><spring:message code="queries.subscription.first.label"/></option>
								<option value="2"<c:if test="${not empty existingFrequencyData && existingFrequencyData.monthlyWeekdayNumber == '2'}"> selected="selected"</c:if>><spring:message code="queries.subscription.second.label"/></option>
								<option value="3"<c:if test="${not empty existingFrequencyData && existingFrequencyData.monthlyWeekdayNumber == '3'}"> selected="selected"</c:if>><spring:message code="queries.subscription.third.label"/></option>
								<option value="4"<c:if test="${not empty existingFrequencyData && existingFrequencyData.monthlyWeekdayNumber == '4'}"> selected="selected"</c:if>><spring:message code="queries.subscription.fourth.label"/></option>
								<option value="L"<c:if test="${not empty existingFrequencyData && existingFrequencyData.monthlyWeekdayNumber == 'L'}"> selected="selected"</c:if>><spring:message code="queries.subscription.last.label"/></option>
							</select>
							<select id="monthOption_specificWeekDay_day">
								<c:forEach items="${daysOfWeek}" var="day">
									<option value="${day.key}"<c:if test="${not empty existingFrequencyData && existingFrequencyData.monthlyWeekdayDay == day.key}"> selected="selected"</c:if>>${day.value}</option>
								</c:forEach>
							</select>
							<span><spring:message code="queries.subscription.of.every.month.label"/></span>
						</label>
					</div>	
				</div>
			</td>
		</tr>
		<tr>
			<td></td>
			<td id="frequencyDayTd" colspan="2">
				<select id="frequencyDay">
					<option value="ONCE_PER_DAY"<c:if test="${not empty existingFrequencyData && existingFrequencyData.frequencyDay == 'ONCE_PER_DAY'}"> selected="selected"</c:if>><spring:message code="queries.frequency.once.per.day"/></option>
					<option value="EVERY_4_HOURS"<c:if test="${not empty existingFrequencyData && existingFrequencyData.frequencyDay == 'EVERY_4_HOURS'}"> selected="selected"</c:if>><spring:message code="queries.frequency.every.4.hours"/></option>
				</select>
				<label><spring:message code="queries.subscription.at.label"/></label>
				<select id="frequencyAt">
					<c:forEach var="hour" begin="0" end="23">
						<option value="${hour}"<c:if test="${not empty existingFrequencyData && existingFrequencyData.frequencyAt == hour}"> selected="selected"</c:if>><c:out value="${hour}"/>:00</option>
					</c:forEach>
				</select>
			</td>
		</tr>
		<tr>
			<td></td>
			<td colspan="2">
				<div class="information"><spring:message code="queries.subscription.timezone.information" arguments="${userTimeZone}"/></div>
			</td>
		</tr>
	</table>
</div>

<script type="text/javascript">

(function($) {
	$(function() {
		var cron = "${empty existingCron ? '' : existingCron}";
		var roles = "${empty existingRoles ? '' : existingRoles}";
		var isPersonalSubscription = ${empty existingPersonalSubscription ? false : existingPersonalSubscription};
		var weekdays = "${not empty existingFrequencyData ? existingFrequencyData.weekdays : ''}";
		var refererUrl = "${empty referer ? '' : referer}";
		codebeamer.QuerySubscription.init(${queryId}, ${not empty subscriptionId ? subscriptionId : 'null'},
				cron, roles, isPersonalSubscription, weekdays, refererUrl);
	});
})(jQuery);

</script>