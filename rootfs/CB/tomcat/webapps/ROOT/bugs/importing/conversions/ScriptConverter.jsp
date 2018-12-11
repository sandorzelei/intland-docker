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

<style type="text/css">
.scriptConverter {
	font-family: monospace;
}
</style>

<spring:message code="issue.import.advanced.conversion.ScriptConverter.explanation" text="Use a script to do the conversion. The script's return value will be used as result of the conversion. This script can use following variables:"/>
<ul>
	<li>input - <spring:message code="issue.import.advanced.conversion.ScriptConverter.var." text="The input data: for example cell content"/></li>
	<li>applicationContext - <spring:message code="issue.import.advanced.conversion.ScriptConverter.var." text="Spring's ApplicationContext to look up and use Managers and Daos"/></li>
	<li>request - <spring:message code="issue.import.advanced.conversion.ScriptConverter.var." text="The http-request"/></li>
	<li>user - <spring:message code="issue.import.advanced.conversion.ScriptConverter.var." text="The current user (UserDto)"/></li>
	<li>field - <spring:message code="issue.import.advanced.conversion.ScriptConverter.var." text="The field this conversion performed for (com.intland.codebeamer.flow.importer.ImportField instance)"/></li>
	<li>column - <spring:message code="issue.import.advanced.conversion.ScriptConverter.var." text="The index of the column the conversion is performed for"/></li>
	<li>tracker - <spring:message code="issue.import.advanced.conversion.ScriptConverter.var." text="The tracker being imported to (TrackerDto instance)"/></li>
	<li>importForm - <spring:message code="issue.import.advanced.conversion.ScriptConverter.var." text="The import form bean (com.intland.codebeamer.flow.form.ImportForm class or ImportIssueForm subclass)"/> The import form bean (com.intland.codebeamer.flow.form.ImportForm class or ImportIssueForm subclass)</li>
	<li>bindings - <spring:message code="issue.import.advanced.conversion.ScriptConverter.var." text="The bindings map contains the variables available in the script"/></li>
</ul>
</p>
<p>
<spring:message code="issue.import.advanced.conversion.ScriptConverter.language" text="Script language"/>: <form:select path="scriptLanguage" items="${converter.scriptLanguages}" itemLabel="name" itemValue="value"/>
<br/><form:errors path="scriptLanguage" cssClass="invalidfield"/>
</p>

<p>
<spring:message code="issue.import.advanced.conversion.ScriptConverter.script" text="Script"/>:<form:textarea path="script" rows="10" cols="100" cssClass="scriptConverter" cssStyle="width: 90%;"/>
<br/><form:errors path="script" cssClass="invalidfield"/>
</p>
