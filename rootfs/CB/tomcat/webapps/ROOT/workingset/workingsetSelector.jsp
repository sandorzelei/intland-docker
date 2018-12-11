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
<%-- jsp fragments shows working set selector combobox
	 parameters:
	 param.commandName The command bean's name which contains the "activatedSelector" property for holding the selected workingset.
--%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<%@ taglib uri="acltaglib" prefix="acl" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ page import="com.intland.codebeamer.controller.workingset.WorkingSetSelectorSupport"%>

<%
	pageContext.setAttribute("SELECTOR_ALL_PROJECTS", WorkingSetSelectorSupport.SELECTOR_ALL_PROJECTS);
	pageContext.setAttribute("SELECTOR_I_MEMBER", WorkingSetSelectorSupport.SELECTOR_I_MEMBER);
	pageContext.setAttribute("SELECTOR_COMPOUND", WorkingSetSelectorSupport.SELECTOR_COMPOUND);
%>

<acl:isAnonymousUser var="isAnonymousUser" />

<c:set var="commandName" value="${param.commandName}" />

<!-- Working Set selector -->
<c:if test="${!isAnonymousUser}">
	<label><spring:message code="workingset.label" text="Working Set"/></span>
	<form:form cssClass="workingset" cssStyle="display:inline;" commandName="${commandName}" >
		<c:set var="wsList" value="${workingSets}" />

		<%-- Build the list of activated items --%>
		<c:set var="activatedItems" value="" />
		<c:set var="activatedCount" value="0" />
		<c:set var="activatedShown" value="" />
		<c:set var="wsSeparator" value="" />
		<c:forEach items="${wsList}" var="item">
			<c:if test="${item.selected}" >
				<c:set var="activatedItems"><c:out value="${activatedItems}${wsSeparator}${item.name}" /></c:set>
				<c:set var="wsSeparator" value=" + " />
				<c:set var="activatedCount" value="${activatedCount + 1}" />
				<c:set var="activatedShown"><c:out value="${activatedShown},${item.id}" /></c:set>
			</c:if>
		</c:forEach>
		
		<spring:message var="selectorTitle" code="workingset.selector.tooltip" text="Select a Working Set to filter projects"/>

		<form:select path="activatedSelector"  onchange="this.form.submit(); return false;"	title="${selectorTitle}" cssStyle="width:20em;"	>
			<form:option value="${SELECTOR_ALL_PROJECTS}"><spring:message code="workingset.selector.all" text="All Projects"/></form:option>
			<form:option value="${SELECTOR_I_MEMBER}"><spring:message code="workingset.selector.member" text="I'm a Member"/></form:option>
			<OPTGROUP CLASS="separator" DISABLED LABEL="---------------------"></OPTGROUP>
			<c:if test="${activatedCount > 1}">
				<form:option value="${SELECTOR_COMPOUND}"><c:out value="${activatedItems}" /></form:option>
			</c:if>
			<form:options items="${wsList}" itemLabel="name" itemValue="id" />
		</form:select>

		<%
			String commandName = (String) pageContext.findAttribute("commandName");
			Object command = pageContext.findAttribute(commandName);
			pageContext.setAttribute("command", command);
		%>
		<c:set var="activatedSelector" value="${command.activatedSelector}"/>
		<c:if test="${(! empty activatedSelector) && activatedSelector ne SELECTOR_ALL_PROJECTS && activatedSelector ne SELECTOR_I_MEMBER && activatedSelector ne SELECTOR_COMPOUND}">
			<c:url var="customizeWorkingSetURL" value="/editWorkingSet.spr">
				<c:param name="workingSetId" value="${activatedSelector}"/>
			</c:url>
			&nbsp;
			<spring:message var="customizeTitle" code="workingset.customize.tooltip" text="Customize selected Working Set..."/>
			<a href="${customizeWorkingSetURL}" title="${customizeTitle}"><spring:message code="workingset.customize.label" text="Customize..."/></a>
		</c:if>

		<!-- activatedSelector: ${activatedSelector} -->
	</form:form>
</c:if>
