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

<spring:message var="saveButton" code="button.save" text="Save" />
<spring:message var="cancelButton" code="button.cancel" text="Cancel" />
<spring:message var="selectButton" code="button.select" text="Select" />

<ui:actionMenuBar>
	<ui:pageTitle>
		<spring:message code="sysadmin.setConfiguration.label" text="Application Configuration" />
	</ui:pageTitle>
</ui:actionMenuBar>

<c:set var="configuration" value="${configurationModel.configuration}" />
<c:set var="configurations" value="${configurationModel.configurations}" />
<c:set var="dateTimeFormatPattern" value="${configurationModel.dateTimeFormatPattern}" />

<form:form autocomplete="off" class="js-configuration-form" commandName="configurationCommand">

	<ui:actionBar>
		<c:choose>
			<c:when test="${configurationModel.previusConfigurationSelected}">
				<input type="submit" class="button" value="${saveButton}" name="_restore" />
			</c:when>
			<c:otherwise>
				<input type="submit" class="button" value="${saveButton}" name="_save" />
			</c:otherwise>
		</c:choose>
		<input type="submit" class="cancelButton button" value="${cancelButton}" name="_cancel" />
	</ui:actionBar>

	<table border="0" cellpadding="2" class="contentWithMargins formTableWithSpacing" style="width: 95%">
		<col width="100">
		<col width="100%">
		<tbody>
			<c:if test="${not empty configurations and fn:length(configurations) gt 1}">
				<tr>
					<td class="optional">
						<spring:message code="sysadmin.configuration.configurations" />
					</td>
					<td>
						<span>
							<select name="version">
								<c:forEach items="${configurations}" var="previousConfiguration">
									<fmt:formatDate value="${previousConfiguration.creationDate}" pattern="${dateTimeFormatPattern}" var="previousConfigurationCreationDate" />
									<option value="${previousConfiguration.version}" ${configurationCommand.version eq previousConfiguration.version ? 'selected="selected"' : ''}>
										<c:choose>
											<c:when test="${empty previousConfiguration.creator}">
												<spring:message code="sysadmin.configuration.configuration" arguments="${previousConfiguration.version},${previousConfigurationCreationDate}" />
											</c:when>
											<c:otherwise>
												<c:set var="userAlias">
													<tag:userAlias userId="${previousConfiguration.creator.id}" />
												</c:set>
												<spring:message code="sysadmin.configuration.configurationWithCreator" arguments="${previousConfiguration.version},${previousConfigurationCreationDate},${userAlias}" />
											</c:otherwise>
										</c:choose>
									</option>
								</c:forEach>
							</select>
						</span>
						<input type="submit" class="button" value="${selectButton}" name="_select" />
					</td>
				</tr>
				<tr>
					<td colspan="2">&nbsp;</td>
				</tr>
			</c:if>
			<tr>
				<td class="optional">
					<spring:message code="sysadmin.configuration.created" />
				</td>
				<td>
					<fmt:formatDate value="${configuration.creationDate}" pattern="${dateTimeFormatPattern}" var="creationDate"/>
					<spring:message code="sysadmin.configuration.created.desc" arguments="${creationDate},${configuration.version}" />
					<c:if test="${not empty configuration.creator}">
						<tag:userLink user_id="${configuration.creator.id}" />
					</c:if>
				</td>
			</tr>
			<tr>
				<td class="optional" valign="top">
					<spring:message code="sysadmin.configuration.configuration.label" />
				</td>
				<td>
					<div class="code-editor offscreen">
						<form:textarea path="content" data-lint="true" data-auto-resize="true" data-mode="application/ld+json" data-fold-gutter="true" data-line-numbers="true" data-indent-with-tabs="true" data-smart-indent="true" data-match-brackets="true" data-autofocus="true" data-line-wrapping="true" data-match-closing="true"
							data-auto-refresh="true" />
					</div>
				</td>
			</tr>
		</tbody>
	</table>

</form:form>
