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
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab" %>

<%--
JSP fragment shows the selector for TestRun's Test Configurations.

Params: ${param.multiple} : boolean if multiple Test Configurations is allowed
--%>
<script type="text/javascript">
	function reloadTestRunTestConfigurations() {
		// turn off ajax caching, IE11 caches the request so the new TestConfiguration won't appear !
		$.ajaxSetup ({
   			 cache: false
		});

		// reload the part of the original page with ajax
		var myurl = document.URL;
		$("#testRunConfigurationsListContainer").load(myurl + " #testRunConfigurationsList");
	}

	// The create-configuration is happening in an overlay, cancel the reload of this page when that finishes
	// and just reload the test-config part with ajax here
	$(document).on("beforeCloseInlinePopup", function(event, action) {
		action.cancelled = true;

		reloadTestRunTestConfigurations();

		inlinePopup.close();
	});

	function createTestConfigurationInOverlay() {
		inlinePopup.show('${createTestConfigUrl}' , {'geometry': 'large'});
		return false;
	}
</script>
<style type="text/css">
	#testRunTestConfigurations td {
		vertical-align: top;
		padding-top: 5px;
	}
</style>


<c:set var="multiple" value="${param.multiple == 'true'}" />
<c:set var="testSetLink"><a target="_blank" href="<c:url value="${testSet.urlLink}"/>"><c:out value='${testSet.name}'/></a></c:set>

<tr id="testRunTestConfigurations">
	<td class="fieldLabel ${testConfigurationRequired ? 'mandatory' : ''}">
		<span class="force-bold">
		<c:choose>
			<c:when test="${multiple}">
				<spring:message code="tracker.type.Testconf.plural" text="Test Configurations"/>:
			</c:when>
			<c:otherwise>
				<spring:message code="tracker.type.Testconf" text="Test Configuration" />:
			</c:otherwise>
		</c:choose>
		</span>
	</td>
	<td class="fieldValue dataCell">
		<div id="testRunConfigurationsListContainer">
		<div id="testRunConfigurationsList">
		<c:choose>
			<c:when test="${multiple}">
				<%-- select multiple configurations with checkboxes --%>
				<c:forEach var="testConfiguration" items="${testConfigurations}">
					<c:choose>
						<c:when test="${testConfiguration.id == defaultConfiguration}">
							<form:checkbox id="testconfiguration-${testConfiguration.id}" path="testConfigurationsSelected[${testConfiguration.id}]" value="true" checked="checked" />
						</c:when>
						<c:otherwise>
							<form:checkbox id="testconfiguration-${testConfiguration.id}" path="testConfigurationsSelected[${testConfiguration.id}]" value="true" />
						</c:otherwise>
					</c:choose>
					<label for="testconfiguration-${testConfiguration.id}">
						<a href="<c:url value='${testConfiguration.urlLink}'/>" target="_blank"><c:out value="${testConfiguration.name}"/></a>
					</label>
					<br>
				</c:forEach>
			</c:when>
			<c:otherwise>
				<%-- group the configurations by tracker --%>
				<form:select style="width: auto;" path="testConfigurationId">
					<c:if test="${! testConfigurationRequired}">
						<form:option value="" >--</form:option>
					</c:if>
					<c:forEach items="${configurationsByTracker}" var="entry">
						<optgroup label="${entry.key.name}">
							<c:forEach items="${entry.value}" var="configuration">
								<form:option value="${configuration.id}"><c:out value='${configuration.name}'/></form:option>
							</c:forEach>
						</optgroup>
					</c:forEach>
				</form:select>
			</c:otherwise>
		</c:choose>

		<div class="addTestConfigLink">
			<c:set var="addConfigLink">
				<spring:message var="addTestConfigTitle" code="tracker.testRun.noTestConfigurationAvailable.add.text"/>
				<a href="#" onclick="return createTestConfigurationInOverlay();" title="${addTestConfigTitle}">
			</c:set>
			<c:choose>
				<c:when test="${testConfigurationRequired && (empty testConfigurations)}">
					<div class="warning" style="margin-top:0;">
						${ui:removeXSSCodeAndHtmlEncode(addConfigLink)}<spring:message code="tracker.testRun.noTestConfigurationAvailable.warn"/></a>
					</div>
				</c:when>
				<c:otherwise>
					<div <c:if test='${! empty testConfigurations}'>style="margin-top:10px;"</c:if> > ${addConfigLink}+ <spring:message code="button.add" /></a></div>
				</c:otherwise>
			</c:choose>
		</div>

		</div>
		</div>
	</td>
	<td>
		<c:if test="${(! empty testSet.name) && (not hasPossibleTestConfigurations)}">
			<div class="subtext note">
				<spring:message code="testrun.editor.has.no.possible.configurations" arguments="${testSetLink}" />
			</div>
		</c:if>
	</td>
</tr>
