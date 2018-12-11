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
<meta name="module" content="labels"/>
<meta name="moduleCSSClass" content="newskin labelsModule"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<%@ taglib uri="uitaglib" prefix="ui" %>

<c:set var="title">
	<spring:message code="tag.edit.title" text="Edit Tag"/>
</c:set>

<jsp:include page="./includes/actionBar.jsp">
	<jsp:param name="title" value="${title}"/>
</jsp:include>

<html:form action="/proj/label/updateLabel" focus="displayName">
	<html:hidden property="id" value="${label.id}" />

	<ui:actionGenerator builder="labelsPageActionMenuBuilder" actionListName="labelsAction">
	<ui:actionBar>
		<ui:rightAlign>
			<jsp:body>
				<html:submit styleClass="button" property="SAVE">
					<spring:message code="button.ok" text="OK"/>
				</html:submit>
				<html:cancel styleClass="cancelButton" style="margin-right: 15px;">
					<spring:message code="button.cancel" />
				</html:cancel>
				<ui:actionLink keys="showLabels" actions="${labelsAction}"/>
			</jsp:body>
		</ui:rightAlign>
	</ui:actionBar>
	</ui:actionGenerator>

	<ui:showSpringErrors errors="${errors.bindingResult}" />

	<div class="contentWithMargins">

		<%-- check for "confirmation" --%>
		<c:if test="${!empty labelForm.map['displayNameToConfirm']}">
			<div class="warning">
				<spring:message code="tag.exists.warning" arguments="${labelForm.map['displayNameToConfirm']}"/>
			</div>
		</c:if>

		<table>
			<tr>
				<td class="mandatory"><spring:message code="tag.name.label" text="Name"/>:</td>
				<td>
					<c:choose>
						<c:when test="${empty labelForm.map['displayNameToConfirm']}">
							<html:text size="32" property="displayName" value="${label.displayName}" />
						</c:when>
						<c:otherwise>
							<html:text size="32" property="displayName" value="${labelForm.map['displayNameToConfirm']}" />
						</c:otherwise>
					</c:choose>
				</td>
			</tr>
		</table>

	</div>
</html:form>
