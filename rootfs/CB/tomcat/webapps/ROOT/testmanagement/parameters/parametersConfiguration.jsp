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
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="taglib" prefix="tag" %>

<style type="text/css">
	.parameterStorages {
		width: 100%;
		/*border: solid 1px #c0c0c0 !important;*/
	}
	.parameterStorages td.optional {
		vertical-align: top;
		padding-top: 2px !important;
	}
	div#TestParameters .ditch-tab-pane {
		padding: 5px 5px 0 5px;
	}
	.parameterStorages .hint {
		margin: 5px 0;
	}
	.parameterStorages .hint * {
		font-size: 11px;
	}

	div#TestParameters .ditch-focused {
		z-index: 0;
	}
	div#TestParameters .ditch-tab {
		top: 1px;
	}
	div#TestParameters .ditch-tab-pane-wrap {
		border-top: 0 !important;
		top: 0;
	}
	div#TestParameters .ditch-tab-wrap {
		border-bottom: 1px solid #d1d1d1;
	}

</style>

<spring:nestedPath path="parameterStorageConfiguration">
<c:set var="config" value="${addUpdateTaskForm.parameterStorageConfiguration}" />
<c:set var="parameterStorages" value="${config.configurations}" />
<%--
<pre>
	${parameterStorages}
</pre>
--%>
<c:if test="${! empty parameterStorages}">
<spring:message var="paramsConfigLabel" code="testing.parameters.config.label" text="Test Parameters" />

<c:set var="paramsEmpty" value="${addUpdateTaskForm.parameterStorageConfiguration.isEmpty()}" />
<tr id="parametersFieldCollapsing">
	<td colspan="2">
		<ui:collapsingBorder label="${paramsConfigLabel}"
			hideIfEmpty="false" open="${! paramsEmpty}" toggle=".parameterStorages"
			cssClass="separatorLikeCollapsingBorder" cssStyle="margin-bottom:0;" />
	</td>
</tr>

<script type="text/javascript">
     function onParameterStorageChange(event) {
         // when changing tabs update the hidden field to send back which parameter storage is selected
         var selectedTabPane = event.getTabPane();
         var id = $(selectedTabPane).attr("id");
         var selectedStorage = id.substring("parameterConfig-".length);
         $("#selectedParameterStorageKey").val(selectedStorage);
     }
</script>

<tr class="parameterStorages" style="${paramsEmpty ? 'display:none': ''}">
	<td class="fieldLabel optional" style="overflow:hidden;"></td>
	<td class="fieldValue">
	<form:hidden id="selectedParameterStorageKey" path="selectedParameterStorageKey"/>

	<tab:tabContainer id="TestParameters" skin="cb-box" selectedTabPaneId="parameterConfig-${config.selectedParameterStorageKey}" jsTabListener="onParameterStorageChange">
		<c:forEach var="parameterConfigEntry" items="${parameterStorages}" >
			<c:set var="storage" value="${parameterConfigEntry.key}" />
			<c:set var="parameterConfig" scope="request" value="${parameterConfigEntry.value}" />
			<c:set var="jsp" value="${parameterConfig.configurationJSPPage}" />

			<c:if test="${! empty parameterConfig && ! empty jsp}">
				<spring:message var="tabTitle" code="testing.parameters.storage.${storage}.title" />
				<tab:tabPane id="parameterConfig-${storage}" tabTitle="${tabTitle}" >
					<%-- show the editor for this kind of storage--%>
					<c:set var="nestedPath" value="configurations[${storage}]" />
					<spring:nestedPath path="${nestedPath}">
						<jsp:include page="${jsp}"></jsp:include>
					</spring:nestedPath>
				</tab:tabPane>
			</c:if>
		</c:forEach>
	</tab:tabContainer>
	</td>
</tr>
</c:if>
</spring:nestedPath>
