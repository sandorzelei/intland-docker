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

<%--

Parameters:
  - autoSaveReleaseTreeState

--%>

<spring:message var="buttonLabel" code="tracker.view.saveReleaseTreeState.label" text="Save tree state" />
<spring:message var="buttonTooltip" code="tracker.view.saveReleaseTreeState.tooltip" />
<spring:message var="cbLabel" code="tracker.view.autoSaveReleaseTreeState.label" text="Auto Save" />
<spring:message var="cbTooltip" code="tracker.view.autoSaveReleaseTreeState.tooltip" />

<span class="versionViewControlsContainer">
	<button id="saveReleaseTreeStateNow"
			title="${buttonTooltip}"
			data-original-label="${buttonLabel}"
			data-loader-image-url="<c:url value="/images/ajax-loading_16.gif"/>">${buttonLabel}</button>
	<label class="disableTextSelection" title="${cbTooltip}">
		<input id="autoSaveReleaseTreeState" type="checkbox" ${param.autoSaveReleaseTreeState ? 'checked="checked"' : ''}>
		<span>${cbLabel}</span>
	</label>
</span>
