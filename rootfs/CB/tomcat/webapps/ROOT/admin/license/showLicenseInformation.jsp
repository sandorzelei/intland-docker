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
 * $Revision$ $Date$
--%>

<%@page import="java.util.Locale"%>
<%@page import="org.springframework.web.servlet.DispatcherServlet"%>
<%@page import="org.springframework.web.servlet.LocaleResolver"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="callTag" prefix="ct" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<%--
	JSP fragment shows the license information.
	Parameters:
	license		- The LicenseCode to show
	showChecksum	- boolean if the checksum is shown. Defaults to false
	licenseUsage	- The usage matrix. See ConfigLicenseController
--%>

<%@page import="com.intland.codebeamer.persistence.dto.base.UserLicenseType"%>
<%@page import="com.intland.codebeamer.license.LicenseCode"%>

<%
	// issue/552509 -> Do not generate License in German dedicated license language should be English
	LocaleResolver localeResolver = (LocaleResolver) request.getAttribute(DispatcherServlet.LOCALE_RESOLVER_ATTRIBUTE);
	Locale originalLocal = localeResolver.resolveLocale(request);
	localeResolver.setLocale(request, response, Locale.US);
%>
<%!
// Formats a number. Note: can not use fmt:formatNumber tag does not add spaces as padding. Did I say I hate jsp already?
public String formatNum(Integer i) {
	return String.format("%-6d", i);
}
%>
<style>
<!--
	.licenseUsage {
		font-style: italic;
	}

	label.featureDisabled {
		text-decoration: line-through;
	}

	.formTableWithSpacing {
		width: auto !important;
		border-collapse: collapse !important;
	}

	.formTableWithSpacing td {
		border: 1px solid #ababab;
	}

-->
</style>

<c:set var="headColSpan" value="${empty license.productLicenses ? 2 : 2 * fn:length(license.productLicenses)}" />

<table class="displaytag formTableWithSpacing">
	<tr>
		<td nowrap class="labelColumn optional">
			<spring:message code="sysadmin.license.hostid" text="Host-ID"/>
		</td>
		<td colspan="${headColSpan}">
			<c:out value="${license.hostId}" />
		</td>
	</tr>

	<tr>
		<td nowrap class="labelColumn optional">
			<spring:message code="sysadmin.license.companyName" text="Company name"/>
		</td>
		<td colspan="${headColSpan}">
			<c:out value="${license.companyName}" />
		</td>
	</tr>

	<tr>
		<td nowrap class="labelColumn optional">
			<spring:message code="sysadmin.license.validUntil" text="Valid Until"/>
		</td>
		<td colspan="${headColSpan}">
			<fmt:formatDate value="${license.expiringDate}" pattern="MMM-dd-yyyy" />
		</td>
	</tr>

	<c:if test="${showChecksum}">
	<tr>
		<td nowrap class="labelColumn optional">
			<spring:message code="sysadmin.license.code" text="Code"/>
		</td>
		<td colspan="${headColSpan}">
			<c:out value="${code}" />
		</td>
	</tr>
	</c:if>

	<c:if test="${!empty license.features}">
		<tr>
			<spring:message var="featuresTooltip" code="sysadmin.license.features.tooltip" text="Additional features associated with this license" htmlEscape="true"/>
			<td nowrap class="labelColumn optional" title="${featuresTooltip}">
				<spring:message code="sysadmin.license.features" text="Features"/>
			</td>
			<td colspan="${headColSpan}" style="min-width: 6em; white-space: nowrap;">
				<c:set var="firstFeature" value="true"/>
				<c:forEach items="${license.features.entrySet()}" var="feature">
					<spring:message var="featureTooltip" code="sysadmin.license.feature.${feature.key}.tooltip" text="" htmlEscape="true"/>
					<c:set var="featureMode" value="feature${feature.value ? 'Enabled' : 'Disabled'}"/>
					<c:choose>
						<c:when test="${firstFeature}">
							<c:set var="firstFeature" value="false"/>
						</c:when>
						<c:otherwise>
							,&nbsp;
						</c:otherwise>
					</c:choose>

					<label class="${featureMode}" title="${featureTooltip}">
						<spring:message code="sysadmin.license.feature.${feature.key}" text="${feature.key}"/>
					</label>
				</c:forEach>
			</td>
		</tr>
	</c:if>

	<c:if test="${!empty license.limits}">
		<tr>
			<spring:message var="limitsTooltip" code="sysadmin.license.limits.tooltip" text="Additional limits associated with this license" htmlEscape="true"/>
			<td nowrap class="labelColumn optional" title="${limitsTooltip}">
				<spring:message code="sysadmin.license.limits" text="Limits"/>
			</td>
			<td colspan="${headColSpan}" style="min-width: 6em; white-space: nowrap;">
				<c:set var="firstLimit" value="true"/>
				<c:forEach items="${license.limits.entrySet()}" var="limit">
					<c:if test="${limit.value != null}">
						<spring:message var="limitTooltip" code="sysadmin.license.limit.${limit.key}.tooltip" text="" htmlEscape="true"/>
						<c:choose>
							<c:when test="${firstLimit}">
								<c:set var="firstLimit" value="false"/>
							</c:when>
							<c:otherwise>
								,&nbsp;
							</c:otherwise>
						</c:choose>

						<label title="${limitTooltip}">
							<spring:message code="sysadmin.license.limit.${limit.key}" text="${limit.key}"/>: <c:out value="${limit.value}"/>
						</label>
					</c:if>
				</c:forEach>
			</td>
		</tr>
	</c:if>

	<c:if test="${!empty license.productLicenses}">
		<tr>
			<td nowrap class="labelColumn optional">
				<spring:message code="sysadmin.license.product" text="Product"/>
			</td>

			<c:forEach items="${license.productLicenses}" var="product">
				<spring:message var="tooltip" code="sysadmin.license.product.${product.type}.tooltip" text="" htmlEscape="true"/>
				<td colspan="2" title="${tooltip}" style="min-width: 6em; white-space: nowrap; color: white; background-color: #00a85d; text-align: center;">
					<spring:message code="sysadmin.license.product.${product.type}" text="${product.type}"/>
				</td>
			</c:forEach>
		</tr>

		<tr valign="top">
			<td nowrap class="labelColumn optional">
				<spring:message code="sysadmin.license.options" text="Options"/>
			</td>

			<c:forEach items="${license.productLicenses}" var="product">
				<td colspan="2" style="min-width: 6em; max-width: 24em;  white-space: normal;">
					<c:out value="${product.string.options}" />
				</td>
			</c:forEach>
		</tr>
	</c:if>

	<tr>
		<td nowrap class="labelColumn optional">
			<spring:message code="user.licenseType.1" text="Users with named license"/>
		</td>

		<c:forEach items="${license.productLicenses}" var="product">
			<td class="numberData" <c:if test="${empty licenseUsage}">colspan="2"</c:if>>
				<ct:call object="<%=this%>" method="formatNum" print="true" param1="${product.limit.USER_WITH_NAMED_LICENSE}" />
			</td>
			<c:if test="${!empty licenseUsage}">
				<td class="licenseUsage">
					<c:set var="userLicenseType" value="<%=UserLicenseType.USER_WITH_NAMED_LICENSE%>"/>
					${licenseUsage[product][userLicenseType]}
				</td>
			</c:if>
		</c:forEach>

		<c:if test="${empty license.type}">
			<td class="numberData" colspan="2">
				<ct:call object="<%=this%>" method="formatNum" print="true" param1="${license.limit.USER_WITH_NAMED_LICENSE}"/>
			</td>
		</c:if>
	</tr>

	<tr>
		<td nowrap class="labelColumn optional">
			<spring:message code="user.licenseType.2" text="User with floating license"/>
		</td>

		<c:forEach items="${license.productLicenses}" var="product">
			<td class="numberData" <c:if test="${empty licenseUsage}">colspan="2"</c:if>>
				<ct:call object="<%=this%>" method="formatNum" print="true" param1="${product.limit.USER_WITH_FLOATING_LICENSE}" />
			</td>
			<c:if test="${!empty licenseUsage}">
				<td class="licenseUsage">
					<c:set var="userLicenseType" value="<%=UserLicenseType.USER_WITH_FLOATING_LICENSE%>"/>
					${licenseUsage[product][userLicenseType]}
				</td>
			</c:if>
		</c:forEach>

		<c:if test="${empty license.type}">
			<td class="numberData" colspan="2">
				<ct:call object="<%=this%>" method="formatNum" print="true" param1="${license.limit.USER_WITH_FLOATING_LICENSE}"/>
			</td>
		</c:if>
	</tr>

	<c:if test="${showCustomers}">
		<tr>
			<td nowrap class="labelColumn optional">
				<spring:message code="user.licenseType.3" text="Customer with named license"/>
			</td>

			<c:forEach items="${license.productLicenses}" var="product">
				<td class="numberData" <c:if test="${empty licenseUsage}">colspan="2"</c:if>>
					<ct:call object="<%=this%>" method="formatNum" print="true" param1="${product.limit.CUSTOMER_WITH_NAMED_LICENSE}" />
				</td>
				<c:if test="${!empty licenseUsage}">
					<td class="licenseUsage">
						<c:set var="userLicenseType" value="<%=UserLicenseType.CUSTOMER_WITH_NAMED_LICENSE%>"/>
						${licenseUsage[product][userLicenseType]}
					</td>
				</c:if>
			</c:forEach>
		</tr>

		<tr>
			<td nowrap class="labelColumn optional">
				<spring:message code="user.licenseType.4" text="Customer with floating license"/>
			</td>

			<c:forEach items="${license.productLicenses}" var="product">
				<td class="numberData" <c:if test="${empty licenseUsage}">colspan="2"</c:if>>
					<ct:call object="<%=this%>" method="formatNum" print="true" param1="${product.limit.CUSTOMER_WITH_FLOATING_LICENSE}" />
				</td>
				<c:if test="${!empty licenseUsage}">
					<td class="licenseUsage">
						<c:set var="userLicenseType" value="<%=UserLicenseType.CUSTOMER_WITH_FLOATING_LICENSE%>"/>
						${licenseUsage[product][userLicenseType]}
					</td>
				</c:if>
			</c:forEach>
		</tr>
	</c:if>
	<tr>
		<td nowrap class="labelColumn optional">
			<spring:message code="sysadmin.license.generatedForRelease" text="generatedForRelease"/>
		</td>
		<td colspan="${headColSpan}">
			<c:if test="${not empty license.generatedForRelease}">
				<c:out value="${license.generatedForRelease}" />
			</c:if>
			<c:if test="${empty license.generatedForRelease}">
				<c:out value="${newLicense.generatedForRelease}" />
			</c:if>
		</td>
	</tr>
	<tr>
		<td nowrap class="labelColumn optional">
			<spring:message code="sysadmin.license.generatorRelease" text="generatorRelease"/>
		</td>
		<td colspan="${headColSpan}">
			<c:if test="${not empty license.generatorRelease}">
				<c:out value="${license.generatorRelease}" />
			</c:if>
			<c:if test="${empty license.generatorRelease}">
				<c:out value="${newLicense.generatorRelease}" />
			</c:if>
		</td>
	</tr>
	<tr>
		<td nowrap class="labelColumn optional">
			<spring:message code="sysadmin.license.generatorUser" text="generatorUser"/>
		</td>
		<td colspan="${headColSpan}">
			<c:if test="${not empty license.generatorUser}">
				<c:out value="${license.generatorUser}" />
			</c:if>
			<c:if test="${empty license.generatorUser}">
				<c:out value="${newLicense.generatorUser}" />
			</c:if>
		</td>
	</tr>
	<tr>
		<td nowrap class="labelColumn optional">
			<spring:message code="sysadmin.license.generationTime" text="generationTime"/>
		</td>
		<td colspan="${headColSpan}">
			<c:if test="${not empty license.generationTime}">
				<c:out value="${license.generationTime}" />
			</c:if>
			<c:if test="${empty license.generationTime}">
				<c:out value="${newLicense.generationTime}" />
			</c:if>
		</td>
	</tr>
</table>

<%
	localeResolver.setLocale(request, response, originalLocal);
%>
