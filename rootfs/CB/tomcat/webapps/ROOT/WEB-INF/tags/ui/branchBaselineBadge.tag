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

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="html" uri="http://struts.apache.org/tags-html" %>

<%@ attribute name="branch" required="false" type="com.intland.codebeamer.persistence.dto.BranchDto" description="The project ID in which the trackers/branches should display." %>
<%@ attribute name="baseline" required="false" type="com.intland.codebeamer.persistence.util.Baseline" description="If multiple select can possible in selector." %>
<%@ attribute name="originalItemId" required="false" type="java.lang.Integer" description="The original Tracker Item ID if tag is used in Tracker Item context." %>
<%@ attribute name="masterItemId" required="false" type="java.lang.Integer" description="The master Tracker Item ID if tag is used in Tracker Item context." %>
<%@ attribute name="rightFragment" required="false" description="If the branches should also include (by default true)." %>

<table class="actionMenuRightTable">
	<tr>
		<c:if test="${not empty baseline}">
			<td>
				<span class="branchBaselineBadge baselineBadge">
					<span class="branchBaselineNamePart">${baseline.name}</span>
					<span class="branchBaselineMenuPart switcher actionBarIcon" data-tooltip="<spring:message code="baseline.switch.to.other.label"/>"></span>
					<span class="branchBaselineMenuPart exit actionBarIcon" data-tooltip="<spring:message code="document.baseline.switchToHead.label"/>"></span>
				</span>
			</td>
		</c:if>
		<c:if test="${branch != null}">
			<td>
				<span class="branchBaselineBadge branchBadge">
					<span class="branchBaselineNamePart">${branch.name}</span>
					<span class="branchBaselineMenuPart switcher actionBarIcon" data-tooltip="<spring:message code="tracker.branching.switch.to.other.label"/>"></span>
					<span class="branchBaselineMenuPart exit actionBarIcon" data-tooltip="<spring:message code="tracker.branching.switch.to.master.label"/>"></span>
				</span>
			</td>
		</c:if>
		<td><div>${rightFragment}</div></td>
	</tr>
</table>

<script type="text/javascript">
	$(function() {

		var trackerId = null;
		<c:if test="${not empty branch}">
			trackerId = ${branch.getTrackerIdOfBranch()};
		</c:if>

		var projectId = null;
		<c:if test="${not empty baseline}">
			projectId = ${baseline.projectId};
		</c:if>

		var originalItemId = null;
		<c:if test="${not empty originalItemId}">
			originalItemId = ${originalItemId};
		</c:if>

		var masterItemId = null;
		<c:if test="${not empty masterItemId}">
			masterItemId = ${masterItemId};
		</c:if>

		var url = contextPath + "/branching/trackerBaselinesAndBranches.spr" + (trackerId != null ? ("?trackerId=" + trackerId + "&branchId=" + "${branch.id}" + (originalItemId != null ? "&originalItemId=" + originalItemId : "")) : (projectId != null ? "?project_id=" + projectId : ""));

		$(".baselineBadge .switcher").click(function() {
			showPopupInline(url, { geometry: "large"});
		});

		$(".branchBadge .switcher").click(function() {
			showPopupInline(url + "&orgDitchnetTabPaneId=branches", { geometry: "large"});
		});

		$(".baselineBadge .exit").click(function() {
			codebeamer.Baselines.switchToHead('revision');
		});

		$(".branchBadge .exit").click(function() {
		    var url;
            if (originalItemId == null) {
				codebeamer.Baselines.switchToHead('branchId');
				return false;
			}
			if (masterItemId == 0) {
                url = contextPath + "/tracker/" + trackerId;
			} else {
                url =  contextPath + "/issue/" + masterItemId;
            }
            url = UrlUtils.addOrReplaceParameter(url, "skipBranchSwitchWarning", "true");
            window.location.href = url;
            return false;
		});
	});
</script>