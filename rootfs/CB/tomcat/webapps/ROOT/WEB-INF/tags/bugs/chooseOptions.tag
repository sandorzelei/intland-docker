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
 * $Revision: 21489:1c3770393951 $ $Date: 2009-05-29 13:46 +0000 $
--%>
<%@ tag language="java" pageEncoding="UTF-8" body-content="scriptless" %>

<%@ taglib uri="bugstaglib" prefix="bugs" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>

<%@ attribute name="id"        required="true" type="java.lang.Integer" rtexprvalue="true" description="The current choice field (cell) ID"  %>
<%@ attribute name="property"  required="true" type="java.lang.String"  rtexprvalue="true" description="The current choice field property name"  %>
<%@ attribute name="tracker"   required="true" type="java.lang.Integer" rtexprvalue="true" description="The current tracker Id"  %>
<%@ attribute name="status"    required="true" type="java.lang.Integer" rtexprvalue="true" description="The current tracker item status ID"  %>
<%@ attribute name="disabled"  required="true" type="java.lang.Boolean" rtexprvalue="true" description="Is the field disabled (not editable)"  %>
<%@ attribute name="field"     required="true" type="com.intland.codebeamer.persistence.dto.TrackerLayoutLabelDto" rtexprvalue="true" description="The current choice field"  %>
<%@ attribute name="options"   required="true" type="java.util.List" rtexprvalue="true" description="The current choice field options"  %>
<%@ attribute name="decorator" required="true" type="com.intland.codebeamer.ui.view.table.TrackerSimpleLayoutDecorator" rtexprvalue="true" description="The tracker item decorator"  %>

<bugs:fieldDependency id="${id}" tracker="${tracker}" status="${status}" field="${field}" disabled="${disabled}" decorator="${decorator}" context="<%=jspContext%>"/>

<form:select id="dynamicChoice_references_${id}" path="${property}" disabled="${disabled}" multiple="false" onchange="${onChange}" >
	<form:options items="${options}" itemLabel="label" itemValue="value" />
</form:select>
