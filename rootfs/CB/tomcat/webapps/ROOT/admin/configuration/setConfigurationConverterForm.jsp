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
<meta name="decorator" content="main" />
<meta name="module" content="sysadmin" />
<meta name="moduleCSSClass" content="sysadminModule newskin" />

<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="uitaglib" prefix="ui"%>
<%@ taglib uri="taglib" prefix="tag"%>

<script src="<ui:urlversioned value="/wro/codemirror.js"/>"></script>
<link rel="stylesheet" href="<ui:urlversioned value="/wro/codemirror.css"/>">

<spring:message var="convertButton" code="button.convert" text="Convert" />
<spring:message var="cancelButton" code="button.cancel" text="Cancel" />

<ui:actionMenuBar>
	<ui:pageTitle>
		<spring:message code="sysadmin.configuration.converter.title.label" />
	</ui:pageTitle>
</ui:actionMenuBar>

<form:form autocomplete="off" commandName="configurationConvertCommand">

	<ui:actionBar>
		<input type="submit" class="button" value="${convertButton}" name="_save" />
		<input type="submit" class="cancelButton button" value="${cancelButton}" name="_cancel" />
	</ui:actionBar>

	<table border="0" cellpadding="2" class="contentWithMargins formTableWithSpacing" style="width: 95%">
		<tbody>
			<tr>
				<td class="optional" width="50%" style="text-align: left;"><spring:message code="sysadmin.configuration.converter.xml.label" /></td>
				<td class="optional" width="50%" style="text-align: left;"><spring:message code="sysadmin.configuration.converter.json.label" /></td>	
			</tr>
			<tr>
				<td width="50%" height="500px">
					<div class="code-editor" style="height: 100%">
						<form:textarea path="xmlContent" rows="20" data-lint="true" data-auto-resize="false" data-mode="application/xml" data-fold-gutter="true" data-line-numbers="true" data-indent-with-tabs="true" data-smart-indent="true" data-match-brackets="true" data-autofocus="true" data-line-wrapping="true" data-match-closing="true"
							data-auto-refresh="false" />
					</div>
				</td>
				<td width="50%" height="500px">
					<div class="code-editor" style="height: 100%">
						<form:textarea path="jsonContent" rows="20" data-lint="true" data-auto-resize="false" data-mode="application/ld+json" data-fold-gutter="true" data-line-numbers="true" data-indent-with-tabs="true" data-smart-indent="true" data-match-brackets="true" data-autofocus="true" data-line-wrapping="true" data-match-closing="true"
							data-auto-refresh="false" />
					</div>
				</td>
			</tr>
		</tbody>
	</table>

</form:form>