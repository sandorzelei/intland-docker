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

<div class="splitter">
<spring:message code="issue.import.advanced.Splitter.explanation" text="Loading one column from this cell by splitting the content to several lines or by other delimiter."/>

<p>
<spring:message code="issue.import.advanced.Splitter.split.by" text="Split by"/>: <form:select path="mode" class="splitterMode">
	<c:forEach var="mode" items="${converter.splitModes}">
		<spring:message var="label" code="issue.import.advanced.Splitter.mode.${mode}" text="${mode}" />
		<form:option value="${mode}" label="${label}"/>
	</c:forEach>
</form:select>
<br/><form:errors path="mode" cssClass="invalidfield"/>
</p>

<p class="BySeparator">
<spring:message code="issue.import.advanced.Splitter.separator" text="Separator"/>: <form:input path="separator"/>
<br/><form:errors path="separator" cssClass="invalidfield"/>
</p>

<p class="ByPattern">
<spring:message code="issue.import.advanced.Splitter.separator.pattern" text="Separator pattern"/>: <form:input path="splitPattern"/> <spring:message code="issue.import.advanced.Splitter.separator.pattern.explanation" text="use any valid Java regexp pattern," />
<a href="http://docs.oracle.com/javase/7/docs/api/java/util/regex/Pattern.html" target="_blank"><spring:message code="issue.import.advanced.Splitter.separator.pattern.documentation" text="see documentation..."/></a>
<br/><form:errors path="splitPattern" cssClass="invalidfield"/>
</p>


<p>
<label>
<spring:message code="issue.import.advanced.Splitter.omit.empty" text="Omit empty strings"/>: <form:checkbox path="ommitEmptyStrings" />
</label>
<br/><form:errors path="ommitEmptyStrings" cssClass="invalidfield"/>
</p>

<p>
<label>
<spring:message code="issue.import.advanced.Splitter.trim" text="Trim each result"/>: <form:checkbox path="trimResults" />
</label>
<br/><form:errors path="trimResults" cssClass="invalidfield"/>
</p>

<style type="text/css">
.BySeparator {
	display: none;
}
.ByPattern {
	display: none;
}
</style>
<script type="text/javascript">
function onSplitModeChange() {
	var value = $(this).val();
	var $block = $(this).closest(".splitter");
	// show/hide the configuration of each block
	$block.find(".ByPattern").toggle(value == "ByPattern");
	$block.find(".BySeparator").toggle(value == "BySeparator");
}

$(function() {
	$("select.splitterMode").change(onSplitModeChange).each(onSplitModeChange);
});
</script>
</div>