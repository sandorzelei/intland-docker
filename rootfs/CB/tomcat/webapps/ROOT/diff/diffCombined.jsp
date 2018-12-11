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
--%>

<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>


<style type="text/css">
	body {
		position: absolute;
   		height: 90%;
	}

	.contentArea, .ditch-tab-skin-cb-box, #diff-tabs, .ditch-tab-pane-wrap {
		height: 98%;
	}
</style>

<spring:message code="diffTool.merge.label" var="mergeLabel" text="Merge"/>
<spring:message code="diffTool.diff.label" var="diffLabel" text="Diff"/>

<ui:actionMenuBar>
	<jsp:body>
		<ui:breadcrumbs showProjects="false" projectAware="${copy}"><span class='breadcrumbs-separator'>&raquo;</span>
			<span><spring:message code="diffTool.pageTitle" text="Differences" arguments="${copy.name},${original.name}" htmlEscape="true" /></span>
			<ui:pageTitle prefixWithIdentifiableName="false" printBody="false" >
				<spring:message code="diffTool.pageTitle" text="Differences" arguments="${copy.name},${original.name}" htmlEscape="true" />
			</ui:pageTitle>
		</ui:breadcrumbs>
	</jsp:body>
</ui:actionMenuBar>

<tab:tabContainer id="diff-tabs" skin="cb-box" jsTabListener="tabChangeListener" selectedTabPaneId="merge-tab">
	<tab:tabPane id="merge-tab" tabTitle="${mergeLabel}">
		<jsp:include page="diff.jsp?noActionMenuBar=true"></jsp:include>
	</tab:tabPane>

	<tab:tabPane id="diff-tab" tabTitle="${diffLabel }">

		<div id="suspected-diff-container-1">

		</div>
	</tab:tabPane>


	<%-- fod bidirectional associations there are two type off diffs shown: the downstream diff and the changes in the
	 current item. this second tab shows the differences in the downstream item --%>
	<c:if test="${isBidirectionalAssociation}">
		<spring:message code="diffTool.downstream.diff.label" var="downstreamDiffLabel" text="Diff"/>

		<tab:tabPane id="downstream-diff-tab" tabTitle="${downstreamDiffLabel }">

			<div id="suspected-diff-container-2">

			</div>
		</tab:tabPane>
	</c:if>
</tab:tabContainer>

<script type="text/javascript">

	function tabChangeListener(event) {
		var $container = $("#suspected-diff-container-" + event._selectedIndex);

		if ((event._selectedIndex == 1 || event._selectedIndex == 2)  && !$container.is('.initialized')) {
			var url = "/ajax/issuediff/diffSuspected.spr";
            var downstreamChangesTab = event._selectedIndex == 2;
			var parameters = {
					'association_id': '${associationId}',
					'is_reference': '${isReference}',
					'issue_id': downstreamChangesTab ? ${copyId} : '${originalId}',
					'association_task_id': downstreamChangesTab ? '${originalId}' : '${copyId}',
					'noActionMenuBar': true,
					'showOmittedFields': true,
					'revision': '${revision}'
			};

			var busyPage = ajaxBusyIndicator.showBusyPage();
            $.get(contextPath + url, parameters).done(function (data) {
				$container.html(data);
				$container.addClass('initialized');
			}).always(function () {
			    if (busyPage) {
			        busyPage.remove();
                }
            });
		}
	}
</script>