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
 * $Revision: 22139:9a0818d9812e $ $Date: 2009-07-31 12:05 +0000 $
--%>
<%@ tag language="java" pageEncoding="UTF-8" %>

<%@ tag import="org.apache.commons.lang.StringUtils"%>
<%@ tag import="com.intland.codebeamer.manager.UserManager"%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<%@ attribute name="user" type="com.intland.codebeamer.persistence.dto.UserDto" required="true" description="User account to display." %>
<%@ attribute name="hideCompany"  required="false" description="Whether to hide the company information. Defaults to false." %>
<%@ attribute name="hideEmail"    required="false" description="Whether to hide the email address. Defaults to false." %>
<%@ attribute name="outlookStyle" required="false" description="Whether to show an extended vcard similar to Outlook. Defaults to false." %>
<%@ attribute name="showPhone"    required="false" description="Whether to show the mobile/phone numbers. Defaults to false." %>
<%@ attribute name="showAddress"  required="false" description="Whether to show the address. Defaults to false." %>

<div class="${outlookStyle ? (showAddress ? (showPhone ? 'vcardFull' : 'vcardMedium') : (showPhone ? 'vcardMedium' : 'vcard')) : 'vcard'}">
	<table cellpadding="0" cellspacing="0">
		<tr>
			<td style="padding-right:5px;">
				<ui:userPhoto userId="${user.id}" userName="${user.name}"/>
			</td>
			<td>
				<c:choose>
					<c:when test="${outlookStyle}">
						<span style="font-weight:bold; font-size:12pt;"><c:out value="${user.realName}"/></span>
						<span style="font-size: 13px">(</span><tag:userLink user_id="${user.id}"/><span style="font-size: 13px">)</span><br/>
						<c:if test="${!hideCompany}">
							<c:out value="${user.company}" default="" /><br/>
						</c:if>
						<c:if test="${showPhone}">
							<c:if test="${not empty user.phone}">
								<c:out value="${user.phone}"/> &nbsp; <span class="subtext"><spring:message code="user.phone.label" /></span>
							 </c:if>
							 <br/>
							<c:if test="${not empty user.mobile}">
								<c:out value="${user.mobile}"/> &nbsp; <span class="subtext"><spring:message code="user.mobile.label" /></span>
							</c:if>
							<br/>
						</c:if>
						<c:if test="${!hideEmail}">
							<c:out value="${user.email}" default="" /> <br/>
						</c:if>
						<c:if test="${showAddress}">
							<c:out value="${user.address}" default="" /> <br/>
							<c:out value="${user.zip}"     default="" />
							<c:out value="${user.city}"    default="" /> <br/>
							<%=StringUtils.defaultString(UserManager.getInstance().getCountryName(user.getCountry(), request.getLocale()))%>
						</c:if>
					</c:when>
					<c:otherwise>
						<tag:userLink user_id="${user.id}"/>
						<br>
						<c:if test="${!hideCompany && (not empty user.company)}"><span class="subtext"><c:out value="${user.company}" default="" /></span><br></c:if>
						<c:if test="${!hideEmail && (not empty user.email)}"><span class="subtext"><c:out value="${user.email}" default="" /></span></c:if>
					</c:otherwise>
				</c:choose>
			</td>
		</tr>
	</table>
</div>
