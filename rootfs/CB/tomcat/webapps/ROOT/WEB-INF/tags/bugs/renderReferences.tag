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
 * $Revision: 18980:d2ec4041f9e5 $ $Date: 2008-10-18 12:57 +0000 $
--%>
<%--
	Tag to render references for dynamic choices/references, by their ids
--%>

<%@ tag language="java" pageEncoding="UTF-8" body-content="scriptless" %>

<%@ tag import="java.util.Map"%>
<%@ tag import="java.util.List"%>
<%@ tag import="java.util.LinkedList"%>
<%@ tag import="java.util.LinkedHashMap"%>
<%@ tag import="java.util.Locale"%>
<%@ tag import="java.util.Collections"%>
<%@ tag import="java.util.StringTokenizer"%>

<%@ tag import="com.intland.codebeamer.controller.ControllerUtils"%>
<%@ tag import="com.intland.codebeamer.manager.UserManager"%>
<%@ tag import="com.intland.codebeamer.manager.EntityReferenceManager"%>
<%@ tag import="com.intland.codebeamer.persistence.dto.base.IdentifiableDto"%>
<%@ tag import="com.intland.codebeamer.persistence.dto.base.ReferableDto"%>
<%@ tag import="com.intland.codebeamer.persistence.dto.UserDto"%>
<%@ tag import="com.intland.codebeamer.persistence.dto.TrackerChoiceOptionDto"%>
<%@ tag import="com.intland.codebeamer.persistence.dto.TrackerLayoutLabelDto"%>
<%@ tag import="com.intland.codebeamer.servlet.bugs.dynchoices.ReferenceHandlerSupport"%>
<%@ tag import="com.intland.codebeamer.servlet.bugs.dynchoices.ReferenceHandlerSupport.SpecialValueResolver"%>
<%@ tag import="com.intland.codebeamer.servlet.bugs.dynchoices.LabelMapSpecialValueResolver"%>
<%@ tag import="org.apache.commons.lang.StringUtils"%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<%@ attribute name="tracker_id" required="false" type="java.lang.Integer" rtexprvalue="true"
		 description="The current tracker's id"  %>
<%@ attribute name="field_id" required="false" type="java.lang.Integer" rtexprvalue="true"
		 description="The current field id"  %>
<%@ attribute name="label" required="false" type="com.intland.codebeamer.persistence.dto.TrackerLayoutLabelDto" rtexprvalue="true"
		 description="The label of which reference should be rendered"  %>
<%@ attribute name="ids" required="false" type="java.lang.String" rtexprvalue="true"
		 description="The comma separated list of ids in form of The comma separated ids of 'group-type-entityId'"  %>
<%@ attribute name="issue" required="false" type="com.intland.codebeamer.persistence.dto.TrackerItemDto" rtexprvalue="true"
		 description="The issue to render references from"  %>
<%@ attribute name="emptyValue" required="false" type="java.lang.String" rtexprvalue="true"
		 description="Optional (can be null) special value, which is automatically removed when something else is selected. The labelMap/specialvalueresolver is used for rendering it." %>
<%@ attribute name="emptyText" required="false" type="java.lang.String" rtexprvalue="true"
		 description="Text shown when references is empty. Defaults to '--'" %>

<%@ attribute name="labelMap" required="false" type="java.util.Map" rtexprvalue="true"
		 description="Map with String->String content, contains mapping about how the the special-id values of references will be displayed. For example __DO_NOT_CHANGE__ would translate to &lt;don't change&gt;"  %>
<%@ attribute name="specialValueResolver" required="false" type="java.lang.String" rtexprvalue="true"
		 description="class name of the class implements the ReferenHandlerSupport.SpecialValueResolver interface. That class must have a public default constructor." %>

<%@ attribute name="editing" type="java.lang.Boolean" rtexprvalue="true"
		description="If the references are rendered for editing (using the ajax control). Defaults for false." %>

<%! private static final EntityReferenceManager entityReferenceManager = EntityReferenceManager.getInstance(); %>
<%
	if (editing == null) {
		editing = Boolean.FALSE;
		jspContext.setAttribute("editing", editing);
	}

	UserDto user = (UserDto) request.getUserPrincipal();
	if (ids == null && (issue==null || label == null)) {
		throw new IllegalArgumentException("Either ids parameter, or both the issue and label parameter must be provided!");
	}

	ReferenceHandlerSupport.SpecialValueResolver specialValueResolverInstance = ReferenceHandlerSupport.createSpecialValueResolver(labelMap, specialValueResolver);

	List<? extends IdentifiableDto> references = Collections.emptyList();
	Map<String,String> specialValueMap = new LinkedHashMap<String,String>();

	if (issue != null && label != null) {
		// resolve value by getting value from issue.
		if (label.isLanguageField() || label.isCountryField()) {
			references = entityReferenceManager.parseReferences(user, request.getLocale(), tracker_id, label, (String)label.getValue(issue), specialValueResolverInstance, specialValueMap);
		} else {
			references = (List) label.getValue(issue);
		}
	} else {
		// resolve the references from id strings using. puts special values to specialValues collection
		// resolve value by getting value from issue.
		if (label == null && field_id != null) {
			label = new TrackerLayoutLabelDto(field_id.intValue());
		}
		references = entityReferenceManager.parseReferences(user, request.getLocale(), tracker_id, label, ids, specialValueResolverInstance, specialValueMap);
	}

	// remove the empty special value, because it must not be shown if something else is selected
	// also resolve the text shown for the empty-value
	// String emptyText = "--";
	if (emptyValue != null) {
		specialValueMap.remove(emptyValue);
		if (specialValueResolverInstance != null) {
			emptyText = specialValueResolverInstance.renderAsHTML(emptyValue);
		}
	}
	if (emptyText != null) {
		emptyText = entityReferenceManager.getText(request, emptyText, emptyText); // i18n
	}
	if (StringUtils.isEmpty(emptyText)) {
		emptyText = "--";
	}
	jspContext.setAttribute("emptyText",   emptyText);
	if (editing) {
		jspContext.setAttribute("renderItems", entityReferenceManager.renderReferencesAsJson(user, request, specialValueMap, references, !editing.booleanValue(), tracker_id, field_id));
	} else {
		jspContext.setAttribute("renderItems", entityReferenceManager.renderReferences(user, request, specialValueMap, references, !editing.booleanValue()));
	}
%>

<c:choose>
	<c:when test="${!editing}">
		<span style="white-space:normal;">
			<c:set var="first" value="true" />
			<c:forEach items="${renderItems}" var="renderItem"><c:if test="${!first}"><c:out value=", "></c:out></c:if>${ui:unescapeHtml(renderItem.label)}<c:set var="first" value="false" /></c:forEach>
		</span>
	</c:when>
	<c:otherwise>
		<c:out value="${renderItems}" escapeXml="false"/>
	</c:otherwise>
</c:choose>
