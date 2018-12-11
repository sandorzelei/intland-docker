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
<%@ tag language="java" pageEncoding="UTF-8" %>
<%@ tag import="java.util.LinkedList"%>
<%@ tag import="com.intland.codebeamer.taglib.performance.RequestResourceManager" %>
<%@ tag import="org.apache.commons.lang3.StringUtils"%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%--
	Tag used to replace javascript (or other script) blocks, which DOES NOT need to be executed immediately,
			but can be later executed just before the end of the html-body
	Use this to improve performance of page loads.

	To use, just wrap those scripts/Javascripts/fragments can be delayed/relocated

	1. Inline javascript fragments:
		<script language="JavaScript" type="text/javascript">
			... blah...
		</script>

		With this:
		<ui:delayedScript>
			<script language="JavaScript" type="text/javascript">
				... blah...
			</script>
		</ui:delayedScript>

	2. Javascript includes:
		<script language="JavaScript" type="text/javascript" src="...url..."></script>

		With:
		<ui:delayedScript>
			<script language="JavaScript" type="text/javascript" src="...url..."></script>
		</ui:delayedScript


	And to write out all "delayed" scripts - typically just before the </body> html tag use:
	<ui:delayedScript flush="true" />

--%>
<%@ attribute name="flush" required="false" description="Set true to write out all 'delayed' javascripts so far." %>
<%@ attribute name="avoidDuplicatesOnly" required="false" type="java.lang.Boolean" description="Don't delay the script (write immediately to the output), but only avoid duplicates of the script printed on the output."  %>
<%@ attribute name="trim" required="false" type="java.lang.Boolean" description="If the script (=the body) should be trimmed for duplicate detection" %>

<%-- get/init the "reqResources" variable in the request scope, which will contain the script text --%>
<%
	RequestResourceManager reqResources = RequestResourceManager.getInstance(request);
%>

<c:set var="enabled" value="true" />
<c:if test="${enabled}">

<c:choose>
	<c:when test="${! empty flush && flush}">
		<!-- flushing out delayed scripts -->
		<c:forEach var="fragment" items="<%=reqResources.getDelayedScripts()%>" varStatus="status">
			<!-- delayed script #${status.count} -->
			${fragment}
		</c:forEach>

		<% // clear flushed content
		reqResources.clearDelayedScripts();
		%>
	</c:when>
	<c:otherwise>
		<%-- evaluate body to get the fragment --%>
		<c:set var="fragment" scope="page"><jsp:doBody></jsp:doBody></c:set>
		<c:if test="${!empty fragment}">
			<%
				String fragment = (String) this.getJspContext().findAttribute("fragment");
				if (Boolean.TRUE.equals(trim)) {
					fragment = StringUtils.trim(fragment);
				}
				if (reqResources.isAllowDelaying() == false || Boolean.TRUE.equals(avoidDuplicatesOnly)) {
					boolean alreadyPrinted = reqResources.isScriptPrinted(fragment);
					if (!alreadyPrinted) {
						reqResources.addPrintedScript(fragment);
						out.print(fragment);
					}
				} else {
					reqResources.addDelayedScript(fragment);
				}
			%>
		</c:if>
	</c:otherwise>
</c:choose>

</c:if>

<c:if test="${! enabled}">
	<!-- delayedScript disabled! -->
	<jsp:doBody></jsp:doBody>
</c:if>
