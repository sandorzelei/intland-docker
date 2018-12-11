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
<meta name="decorator" content="popup"/>
<meta name="moduleCSSClass" content="trackersModule"/>

<%--
	JSP fragment used when the references are selected in SelectReferenceController/popup
	 the data needs to be written back to the original page, and the popup should be closed.
 --%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<c:set var="setToDefaultLabel" ><c:out value="${command.setToDefaultLabel}"/></c:set>
<c:set var="defaultValue" ><c:out value="${command.defaultValue}"/></c:set>

<c:set var="DEBUG" value="false" />

<c:if test="${DEBUG}">
<pre class="debug">
	command: ${command}
	setToDefaultLabel: ${setToDefaultLabel}
	defaultValue: ${defaultValue}

	labelMap="${command.labelTranslationMap}"
	specialValueResolver="${command.specialValueResolver}"
	emptyValue=${command.emptyValue}
	unsetValue=${command.unsetValue}
	forceMultiSelect=${command.forceMultiSelect}

	htmlId="${command.htmlId}"
	fieldName="${command.fieldName}"
</pre>
</c:if>

<div <c:if test="${!DEBUG}"> style="display: none;"</c:if> >
<c:if test="${not command.workItemMode && not command.reportMode}">
	<bugs:chooseReferences tracker_id="${command.tracker_id}" ids="${command.selectedItems}" label="${trackerLabel}"
		setToDefaultLabel="${setToDefaultLabel}" defaultValue="${defaultValue}"
		emptyValue="${command.emptyValue}" unsetValue="${command.unsetValue}" forceMultiSelect="${command.forceMultiSelect}"
		labelMap="${command.labelTranslationMap}" specialValueResolver="${command.specialValueResolver}"
		htmlId="${command.htmlId}" fieldName="${command.fieldName}"
	/>
</c:if>
</div>

<c:set var="referencesRendered"><bugs:renderReferences tracker_id="${command.tracker_id}" field_id="${command.labelId}" label="${trackerLabel}" ids="${command.selectedItems}"
													   emptyText="${emptyHTML}" emptyValue="${command.emptyValue}" labelMap="${command.labelTranslationMap}" specialValueResolver="${command.specialValueResolver}" editing="true" /></c:set>

<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/dynchoices/referenceSelected.js' />" ></script>

<%-- script writes back the data to opener, and closes popup --%>
<SCRIPT LANGUAGE="JavaScript" type="text/javascript">

	writeBackChoosenReferences('${command.htmlId}', ${referencesRendered});

</SCRIPT>

