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

<spring:message code="issue.import.advanced.conversion.OneColumnFromHtmlTableCellLoader.explanation" text="Loading one column from this cell which contains a HTML table values."/>
<p>
<spring:message code="issue.import.advanced.conversion.OneColumnFromHtmlTableCellLoader.columnIndex" text="Use column # from HTML table (use 0 for first column):"/><form:input path="columnIndex"/>
<br/><form:errors path="columnIndex" cssClass="invalidfield"/>
</p>

<p>
<spring:message code="issue.import.advanced.conversion.OneColumnFromHtmlTableCellLoader.startAtRow" text="Start at row # (for example use 1 for skipping the 1st row):"/><form:input path="startAtRow"/>
<br/><form:errors path="startAtRow" cssClass="invalidfield"/>
</p>
