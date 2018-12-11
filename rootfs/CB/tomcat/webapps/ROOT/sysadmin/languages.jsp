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
<meta name="module" content="sysadmin"/>
<meta name="moduleCSSClass" content="newskin sysadminModule"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>

<ui:actionMenuBar>
		<ui:pageTitle>
			<spring:message code="sysadmin.languages.label" text="Available Languages"/>
		</ui:pageTitle>
</ui:actionMenuBar>

<form:form>
	<ui:actionBar>
		<spring:message var="saveButton" code="button.save" text="Save"/>
		<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>
		&nbsp;&nbsp;<input type="submit" class="button" value="${saveButton}" />
		&nbsp;&nbsp;<input type="submit" class="cancelButton button" value="${cancelButton}" name="_cancel" />
	</ui:actionBar>

	<spring:hasBindErrors name="command">
		<ui:showSpringErrors errors="${errors}" />
	</spring:hasBindErrors>

	<div class="hint" style="margin-bottom:5px;" >
		<spring:message code="sysadmin.languages.page.hint" />
	</div>

	<spring:message var="toggleButton" code="search.what.toggle" text="Select/Clear All"/>
	<c:set var="toggleButtonHtml">
		<input type="checkbox" title="${toggleButton}" name="select_all" VALUE="on"	onclick="setAllStatesFrom(this, 'languages')">
	</c:set>

	<spring:message var="user_language_label" code="user.language.label"/>

	<display:table excludedParams="*" name="${installed}" id="language" cellpadding="0">
		<display:column title="${toggleButtonHtml}"
			class="checkbox-column-minwidth" headerClass="checkbox-column-minwidth"
		>
			<form:checkbox path="languages" value="${language.value}" id="checkbox_${language.key}" />
		</display:column>
		<display:column title="${user_language_label}"
			headerClass="textData" class="textData"
		>
			<label for="checkbox_${language.key}">
				<c:out value="${language.key}"/>
			</label>
		</display:column>
	</display:table>

</form:form>
