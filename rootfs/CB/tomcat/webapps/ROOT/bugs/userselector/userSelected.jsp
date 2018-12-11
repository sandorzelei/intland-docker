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

<%--
  JSP page shown when an user is selected.
--%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<%-- change the page to debug mode --%>
<c:set var="DEBUG" value="false" />

<c:set var="htmlId" ><c:out  value="${param.opener_htmlId}" /></c:set>
<c:set var="fieldName"><c:out value="${param.opener_fieldName}" /></c:set>

<%-- hidden div contains the currently selected UserDto/RoleDtos rendered, which is copied back to opener window when "set" pressed --%>
<div style="<c:if test="${! DEBUG}"> display:none;</c:if> border:solid 3px red; margin-top: 3em;">
	<h3>This is shown only, because the page is in debug mode!</h3>

	<bugs:chooseReferencesUI ids="${newSelectedReferenceIds}" labelMap="${selectAssignedUsersCommand.labelTranslationMap}"
		emptyValue="${selectAssignedUsersCommand.emptyValue}"
		htmlId="${htmlId}" fieldName="${fieldName}" specialValueResolver="${selectAssignedUsersCommand.specialValueResolver}"
		ajaxEnabled="true" ajaxURLParameters="any-value-but-empty-the-initAjax-js-closure-contains-the-real-value" userSelectorMode="true"
		/>
<%--
	<pre><spring:escapeBody htmlEscape="true">
		newSelectedReferenceIds: ${newSelectedReferenceIds}
		label: ${label}
		selectAssignedUsersCommand.labelTranslationMap: <c:out value="${selectAssignedUsersCommand.labelTranslationMap}"/>
		htmlId: ${htmlId}
		param.SUBMIT: ${param.SUBMIT}
		selectAssignedUsersCommand.submitted: ${selectAssignedUsersCommand.submitted}
		selectAssignedUsersCommand: ${selectAssignedUsersCommand}
		selectAssignedUsersCommand.specialValueResolver: ${selectAssignedUsersCommand.specialValueResolver}
		</spring:escapeBody>
	</pre>
--%>
</div>

<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/dynchoices/referenceSelected.js' />" ></script>

<c:if test="${selectAssignedUsersCommand.submitted}">

	<c:set var="referencesRendered"><bugs:renderReferences tracker_id="${tracker_id}" field_id="${selectAssignedUsersCommand.labelId}" label="${label}" ids="${newSelectedReferenceIds}"
														   emptyText="${emptyHTML}" emptyValue="${selectAssignedUsersCommand.emptyValue}" labelMap="${selectAssignedUsersCommand.labelTranslationMap}" specialValueResolver="${selectAssignedUsersCommand.specialValueResolver}" editing="true" /></c:set>

	<script type="text/javascript">
		// form submitted, write back the values
		var form = document.getElementById("selectAssignedUsersForm");
		writeBackChoosenReferences('${htmlId}', ${referencesRendered});
	</script>
</c:if>