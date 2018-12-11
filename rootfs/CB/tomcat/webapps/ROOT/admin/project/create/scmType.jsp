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
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<%@ taglib uri="uitaglib" prefix="ui" %>

<meta name="decorator" content="main"/>
<meta name="module" content="project_browser"/>
<meta name="moduleCSSClass" content="projectModule newskin"/>
<spring:message var="titleContext" code="project.creation.title" text="Create New Project"/>

<ui:actionMenuBar>
		<ui:pageTitle>
			${titleContext} <span class='breadcrumbs-separator'>&raquo;</span>
			<spring:message code="project.administration.scm.repository.provider.title" text="Select Provider"/>
		</ui:pageTitle>
</ui:actionMenuBar>

<style type="text/css">
<!--
	#createProjectForm label {
		font-weight: bold;
	}
	#nextButton {
		min-width: 90px;	/* avoid jumping when switching between next/finish text */
	}
-->
</style>

<form:form commandName="createProjectForm" action="${flowUrl}" id="createProjectForm">

<ui:actionBar>
	<input type="submit" name="_eventId_next" value="Next &gt;" style="display:none;"/>

	<spring:message var="nextButton" code="button.goOn" text="Next &gt;"/>
	&nbsp;&nbsp;<input id="nextButton" type="submit" class="button" name="_eventId_next" value="${nextButton}" />

	<spring:message var="finishButton" code="project.creation.finish.button" text="Finish"/>
	&nbsp;&nbsp;<input id="finishButton" type="submit" class="button" name="_eventId_finish" value="${finishButton}" />
	
	<spring:message var="backButton" code="button.back" text="&lt; Back"/>
	<input type="submit" class="linkButton button" name="_eventId_back" value="${backButton}" />

	<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>
	<input type="submit" class="cancelButton" name="_eventId_cancel" value="${cancelButton}" />
</ui:actionBar>

<form:errors cssClass="error"/>

<c:set var="scmForm" value="${createProjectForm}" scope="request"/>

<jsp:include page="/scm/includes/scmTypeList.jsp?noOption=true"/>

<script type="text/javascript">
	function changeNextButtonTextDependingOnScmType() {
		var $selectedTypeRadioButton = $("input[name='type']:checked");
		var $selectedType = $selectedTypeRadioButton.val();

		var $nextButton = $("#nextButton");
		var $finishButton = $("#finishButton");
		if ($selectedType == '') {
			$nextButton.hide();
			$finishButton.show();
		} else {
			$nextButton.show();
			$finishButton.hide();
		}
	}
	
	$(changeNextButtonTextDependingOnScmType);
	$("input[name='type']").change(changeNextButtonTextDependingOnScmType);
</script>

</form:form>

<spring:message var="dialogMessage" code="project.creation.dialog.content" />
<ui:inProgressDialog message="${dialogMessage}" imageUrl="${pageContext.request.contextPath}/images/newskin/project_create_in_progress.gif" height="250" attachTo="#finishButton" triggerOnClick="true" />

