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
<%--
 tabbed listing of tracker baselines and branches
--%>

<%@ taglib uri="uitaglib" prefix="ui"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab" %>

<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<meta name="decorator" content="popup"/>
<meta name="moduleCSSClass" content="newskin baselinesModule branchesModule"/>
<meta name="module" content="tracker"/>

<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/baselines.less' />" type="text/css" media="all" />

<style type="text/css">
	.baselineListWrapper #branch td, .baselineListWrapper #baseline td,
	.baselineListWrapper #branch th, .baselineListWrapper #baseline th {
		padding: 12px 5px 11px 5px;
	}
</style>

<ui:actionMenuBar>
	<c:out value="${tracker.name }"/> <spring:message code="tracker.branching.branch.list.title" text="Baselines and Branches"></spring:message>
</ui:actionMenuBar>
<tab:tabContainer id="tabs" skin="cb-box">
	<c:if test="${!hideBaselines}">
		<tab:tabPane id="baselines" tabTitle="Baselines">
			<jsp:include page="/bugs/tracker/trackerBaselines.jsp?hideActionMenuBar=true"/>
		</tab:tabPane>
	</c:if>
	<c:if test="${tracker.type.branchable and (canViewBranches or !hasBranchLicense)}">
		<tab:tabPane id="branches" tabTitle="Branches">
			<jsp:include page="trackerBranches.jsp"/>
		</tab:tabPane>
	</c:if>
</tab:tabContainer>

<script type="text/javascript">
	$(function() {
		$(".baselineFilterBox").keydown(function() {
			var value = $.trim($(this).val()).toLowerCase();
			var $rows = $("#" + $(this).attr("data-type") + " tbody").find("tr");
			if (value.length >= 2) {
				$rows.each(function() {
					var $row = $(this);
					var name = $row.find(".textData").first().find("a").text();
					$row.toggle(name.toLowerCase().indexOf(value) != -1);
				});
			} else {
				$rows.show();
			}
		});
	});
</script>
