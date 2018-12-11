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
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="wysiwyg" prefix="wysiwyg" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="taglib" prefix="tag" %>

<style type="text/css">
	div.example {
		border: solid 1px silver;
		width: 50%;
	}
	#simpleWikiParametersExample {
		display: none;
	}
</style>

<script type="text/javascript">
	function showSimpleParametersExample() {
		var msg = $("#simpleWikiParametersExample").html();
		showModalDialog("information", msg, [{ text: "OK", click: function(){$(this).dialog("destroy");}}], "50em");
	}
</script>
<div id="simpleWikiParametersHint" class="hint">
<spring:message code="testing.parameters.storage.SimpleWikiParameterStorage.hint1" text="You can define parameter values for this Test Case or Test Set here, either:"/>
<a style="margin-left:5em" href="#" onclick="showSimpleParametersExample(); return false;"><spring:message code="testing.parameters.storage.SimpleWikiParameterStorage.explanation.link" text="See some examples..."/></a><br/>
<ul>
	<li><spring:message code="testing.parameters.storage.SimpleWikiParameterStorage.hint1.option1" text="Use simple name and value pairs"/></li>
	<li><spring:message code="testing.parameters.storage.SimpleWikiParameterStorage.hint1.option2" text="Use a Wiki table for multi-row parameter sets"/></li>
</ul>
</div>

<div id="simpleWikiParametersExample">
<h3><spring:message code="testing.parameters.storage.SimpleWikiParameterStorage.explanation.option1.title" text="You can use simple name and value pairs as parameters. An example:"/></h3>
<pre>
{{{
   title=Flying Circus
   author=Monty Python
   years=1969-1974
}}}
</pre>
<h3><spring:message code="testing.parameters.storage.SimpleWikiParameterStorage.explanation.option2.title" text="Or use wiki tables for multi-row parameter sets:"/></h3>
<pre>
||title||author||years
|Flying Circus|Monty Python|1969-1974
|Life of Brian|Monty Python|1979
</pre>
</div>

<div style="clear:both;"></div>

<%-- TODO: should use entity parameter ? entity="${trackerItem}" --%>
<wysiwyg:editor editorId="parametersInWiki" useAutoResize="true" heightMin="100" uploadConversationId="">
    <form:textarea id="parametersInWiki" path="parametersInWiki" cols="80" rows="10" />
</wysiwyg:editor>