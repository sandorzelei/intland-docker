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
--%>
<meta name="decorator" content="popup"/>
<meta name="module" content="cmdb"/>
<meta name="moduleCSSClass" content="newskin CMDBModule"/>

<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>

<link rel="stylesheet" href="<ui:urlversioned value='/bugs/tracker/includes/burndownConfiguration.css' />" type="text/css" media="all" />

<ui:actionMenuBar>
	<spring:message code="cmdb.version.stats.burndown.configuration.page.title" text="Burn Down Chart configuration" />
</ui:actionMenuBar>

<form:form action="${submitUrl}" method="POST" target="_self">
	<div class="actionBar">
		<spring:message var="saveTitle" code="button.save" text="Save"/>
		<input type="submit" value="${saveTitle}" class="button">
		<spring:message var="cancelTitle" code="button.cancel" text="Cancel"/>
		<input type="submit" class="cancelButton" onclick="closePopupInline(); return false;" value="${cancelTitle}"/>
	</div>

	<div class="contentWithMargins">

		<div class="formField">

			<div id="dataSourceFormField">
				<label class="fieldLabel" for="dataSourceDrodpown"><spring:message code="cmdb.version.stats.burndown.configuration.page.data.source.label=" text="Data Source"/>:</label>

				<select id="dataSourceDrodpown" name="dataSource" >
					<option value="numberOfItems" <c:if test="${numberOfItemsDataSourceEnabled}"> selected="selected" </c:if>><spring:message code="cmdb.version.stats.burndown.configuration.page.data.source.items" text="Number Of Items"/></option>
					<option value="storyPoints" <c:if test="${storyPointsDataSourceEnabled}"> selected="selected" </c:if>><spring:message code="cmdb.version.stats.burndown.configuration.page.data.source.storyPoints" text="Story Points"/></option>
					<option value="both" <c:if test="${bothDataSourcesEnabled}"> selected="selected" </c:if>><spring:message code="cmdb.version.stats.burndown.configuration.page.data.source.both" text="Both"/></option>
				</select>
			</div>

			<script type="text/javascript">
				jQuery(function($) {
					$("#dataSourceDrodpown").multiselect({
						header: false,
						multiple: false,
						selectedList: 1,
						height: "85px"
					});
				});
			</script>

		</div>

		<div class="formField">
			<div id="showBurnDownFormField">
				<input id="showBurnDownCheckBox" name="showBurnDown" class="checkboxInput" type="checkbox" <c:if test="${isShowBurnDownEnabled}"> checked="checked" </c:if> ></input>
				<label for="showBurnDownCheckBox" class="fieldLabel"><spring:message code="cmdb.version.stats.burndown.configuration.page.showBurnDown.label" text="Show Burn Down"/></label>
			</div>
		</div>

		<div class="formField">
			<div id="showVelocityFormField">
				<input id="showVelocityCheckBox" name="showVelocity" class="checkboxInput" type="checkbox" <c:if test="${isShowVelocityEnabled}"> checked="checked" </c:if> ></input>
				<label for="showVelocityCheckBox" class="fieldLabel"><spring:message code="cmdb.version.stats.burndown.configuration.page.showVelocity.label" text="Show Velocity"/></label>
			</div>
		</div>

		<div class="formField">
			<div id="showNewFormField">
				<input id="showNewCheckBox" name="showNew" class="checkboxInput" type="checkbox" <c:if test="${isShowNewEnabled}"> checked="checked" </c:if> ></input>
				<label for="showNewCheckBox" class="fieldLabel"><spring:message code="cmdb.version.stats.burndown.configuration.page.showNew.label" text="Show New"/></label>
			</div>
		</div>

		<div class="formField">
			<div id="showIdealLineFormField">
				<input id="showIdealLineCheckBox" name="showIdealLine" class="checkboxInput" type="checkbox" <c:if test="${isShowIdealLineEnabled}"> checked="checked" </c:if> ></input>
				<label for="showIdealLineCheckBox" class="fieldLabel"><spring:message code="cmdb.version.stats.burndown.configuration.page.showIdealLine.label" text="Show Ideal Line"/></label>
			</div>
		</div>

		<div class="formField">
			<div id="applyProjectCalendarFormField">
				<input id="applyProjectCalendarCheckBox" name="applyProjectCalendar" class="checkboxInput" type="checkbox" <c:if test="${isApplyProjectCalendarEnabled}"> checked="checked" </c:if> ></input>
				<label for="applyProjectCalendarCheckBox" class="fieldLabel"><spring:message code="cmdb.version.stats.burndown.configuration.page.applyProjectCalendar.label" text="Apply Project Calendar"/></label>
			</div>
		</div>

	</div>

</form:form>

