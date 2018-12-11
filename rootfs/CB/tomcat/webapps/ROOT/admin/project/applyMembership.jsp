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
<meta name="decorator" content="popup"/>
<meta name="module" content="members"/>
<meta name="moduleCSSClass" content="membersModule"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<ui:actionMenuBar>
	<span class="titlenormal">
		<spring:message code="project.${join ? 'join' : 'leave'}.title" text="Joining Project {0}" arguments="${project.name}"/>
	</span>
</ui:actionMenuBar>

<c:url var="actionUrl" value="/proj/applyMembership.spr"/>

<form action="${actionUrl}" method="post">

	<input type="hidden" name="targetProjectId" value="<c:out value='${project.id}'/>"/>
	<input type="hidden" name="referrer" 		value="<c:out value='${referrer}'/>"/>
	<input type="hidden" name="join"     		value="<c:out value='${join}'/>"/>

	<div class="actionBar">
		<spring:message var="submitButton" code="button.submit" text="Submit"/>
		<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>

		&nbsp;&nbsp;<input type="submit" class="button" value="${submitButton}" />
		&nbsp;&nbsp;<input type="submit" class="button cancelButton" name="_cancel" value="${cancelButton}" onclick="closePopupInline(); return false;"/>
	</div>

    <ui:globalMessages/>

	<div class="contentWithMargins">
		<table border="0" cellspacing="1" cellpadding="3">

			<tr>
				<td colspan="2">&nbsp;<spring:message code="project.${join ? 'join' : 'leave'}.hint" text="Describe shortly why you would like to join"/>.</td>
			</tr>

			<tr>
				<td colspan="2" height="4"></td>
			</tr>

			<tr>
				<TD valign="top" class="mandatory" ><spring:message code="project.join.comment" text="Comment"/>:</TD>

				<td class="expandTextArea">
					<textarea  name="comment" rows="12" style="width:90%;" ></textarea>
				</td>
			</tr>

		</table>
	</div>

</form>