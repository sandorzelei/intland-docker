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
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>

<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="acltaglib" prefix="acl" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<spring:message code="issue.import.advanced.conversion.OneColumnFromCSVCellLoader.explanation" text="Loading one column from this cell which contains CSV values."/>
<p>
<spring:message code="issue.import.advanced.conversion.OneColumnFromCSVCellLoader.columnIndex" text="Use column # from CSV file (use 0 for first column):"/><form:input path="columnIndex"/>
<br/><form:errors path="columnIndex" cssClass="invalidfield"/>
</p>

<p>
<spring:message code="issue.import.advanced.conversion.OneColumnFromCSVCellLoader.startAtRow" text="Start at row # (for example use 1 for skipping the 1st row):"/><form:input path="startAtRow"/>
<br/><form:errors path="startAtRow" cssClass="invalidfield"/>
</p>

<p>
<spring:message code="issue.import.advanced.conversion.OneColumnFromCSVCellLoader.field.separator" text="Field Separator:"/><form:select path="fieldSeparator" items="${converter.fieldSeparators}" itemLabel="name" itemValue="value"/>
<br/><form:errors path="fieldSeparator" cssClass="invalidfield"/>
</p>

<%-- TODO: charset has no point here, we're inside a cell
<p>
Character Set: <form:select path="charsetName" items="${converter.characterSets}" />
<br/><form:errors path="charsetName" cssClass="invalidfield"/>
</p>
--%>
