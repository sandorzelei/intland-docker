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
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>

<meta name="decorator" content="popup" />
<meta name="module" content="cmdb"/>
<meta name="moduleCSSClass" content="newskin CMDBModule"/>
<meta name="applyLayout" content="true" />

<style type="text/css">
	li.project.ui-multiselect-menu {
	    position: relative;
	}
</style>

<link rel="stylesheet" href="<ui:urlversioned value="/testmanagement/testLibrary.css" />" type="text/css" media="all" />
<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/selectorUtils.less' />" type="text/css" media="all" />

<ui:actionMenuBar>
	<spring:message code="testManagement.configureTestLibraries.${tracker_type}.popup.title" text="Configure Library"/>
</ui:actionMenuBar>

<form:form action="${submitUrl}" method="POST" class="trackerTreeForm">
	<ui:actionBar>
		<spring:message var="buttonSave" code="button.save" />
		<input type="submit" class="button" name="SUBMIT" value="${buttonSave}"/>
		<spring:message var="cancelTitle" code="button.cancel" text="Cancel" />
		<input type="submit" class="cancelButton" onclick="closePopupInline(); return false;" value="${cancelTitle}" />
	</ui:actionBar>

	<input type="hidden" name="selected_tracker_ids" value=""> <!-- will be filled on submit -->
	<input type="hidden" name="deselected_tracker_ids" value=""> <!-- will be filled on submit -->

	<div class="contentWithMargins">
		<ui:globalMessages />
		<c:if test="${disabledTrackers }">
			<div class="information">
				<spring:message code="testManagement.configureTestLibraries.trackers.disabled.warning" text="Some of the options are disabled because of their configurations"/>
			</div>
		</c:if>
		<div class="information">
			<spring:message code="testManagement.configureTestLibraries.trackers.from.current.project.warning"/>
		</div>
		<div class="trackerSelectorTree">
			<div class="aggregateSelectors">
				<spring:message code="testManagement.configureTestLibraries.libraries" text="Libraries" />:
				<input type="checkbox" class="selectAll"> <spring:message code="testManagement.configureTestLibraries.all" text="All" />
				<input type="checkbox" class="selectNone"> <spring:message code="testManagement.configureTestLibraries.none" text="None" />
			</div>
			<ol class="projects">
				<c:forEach var="project" items="${nodes}">
					<c:set var="fromCurrentProject" value="${currentProjectId == project.id}"></c:set>

					<li class="project ui-multiselect-menu">
						<a class="toggle closed"></a>
						<input type="checkbox" ${project.selected ? ' checked' : ''} ${fromCurrentProject ? 'disabled' : '' }>
						<img src="<c:url value="${project.iconUrl}" />" style="background-color: ${project.iconBgColor}" />
						<a href="#"><c:out value="${project.text}" /></a>
						<c:if test="${!empty project.children}">
							<ol class="trackers">
								<c:forEach var="tracker" items="${project.children}">
									<c:set var="compatibleTracker" value="${fn:contains(referencingTrackers, tracker.id) }"/>
									<c:set var="disabled" value="${command.strictReference && !compatibleTracker }"></c:set>
									<%-- if the tracker is in the current project show it as disabled and checked --%>

									<li class="tracker ${disabled or fromCurrentProject ? 'disabled' : '' }">
										<input data-tracker-id="${tracker.id}" type="checkbox" ${tracker.selected ? ' checked' : ''} ${disabled or fromCurrentProject ? 'disabled' : '' }>
										<img src="<c:url value="${tracker.iconUrl}" />" style="background-color: ${tracker.iconBgColor}" />
										<a href="#"><c:out value="${tracker.text}" />&nbsp;(${tracker.total})</a>

										<c:if test="${!compatibleTracker }">
											<span class="small">
												<c:url value="/proj/tracker/configuration.spr?tracker_id=${tracker.id }" var="trackerUrl"/>
												<a href="${trackerUrl }" target="_blank">
													<spring:message code="testManagement.configureTestLibraries.trackers.disabled.hint" text="Customize Tracker"/></a>
											</span>
										</c:if>
									</li>

									<c:if test="${not empty tracker.branchHierarchy }">
										<c:forEach items="${tracker.branchHierarchy }" var="branchNode">
											<c:set var="compatibleTracker" value="${fn:contains(referencingTrackers, branchNode.branch.id) }"/>
											<c:set var="disabled" value="${command.strictReference && !compatibleTracker }"></c:set>
											<li class="tracker branchTracker level-${branchNode.level } ${disabled ? 'disabled' : '' }">
												<input data-tracker-id="${branchNode.branch.id}" type="checkbox" ${configuredIds.contains(branchNode.branch.id) ? ' checked' : ''}  ${disabled ? 'disabled' : '' }>
												<ui:coloredEntityIcon subject="${branchNode.branch }" iconBgColorVar="bgColor" iconUrlVar="iconUrl"></ui:coloredEntityIcon>
												<img src="<c:url value="${iconUrl}" />" style="background-color: ${bgColor}" />
												<a href="#"><c:out value="${branchNode.branch.name}" /> - <c:out value="${tracker.text}" />&nbsp;(${ statsPerTracker[branchNode.branch]  != null ? statsPerTracker[branchNode.branch].allItems : 0})</a>

												<c:if test="${!compatibleTracker }">
													<span class="small">
														<c:url value="/proj/tracker/configuration.spr?tracker_id=${branchNode.branch.id }" var="trackerUrl"/>
														<a href="${trackerUrl }" target="_blank"><spring:message code="testManagement.configureTestLibraries.trackers.disabled.hint" text="Customize Tracker"/></a>
													</span>
												</c:if>
											</li>
										</c:forEach>
									</c:if>
								</c:forEach>
							</ol>
						</c:if>
					</li>
				</c:forEach>
			</ol>
		</div>
	</div>

</form:form>

<script>

	jQuery(function($) {
		var tree = $(".trackerSelectorTree");
		var selectAll = tree.find(".selectAll");
		var selectNone = tree.find(".selectNone");

		var allCheckboxes = tree.find("li.project input[type=checkbox]");
		var projectCheckboxes = tree.find("li.project > input[type=checkbox]");

		tree.find(".trackers").hide();
		tree.find("li.project > a").each(function() {
			var link = $(this);
			link.click(function() {
				link.parent().find(".trackers").toggle();
				link.parent().find(".toggle").toggleClass("closed");
				return false;
			});
		});

		(function setupAggregateControls() {
			var toggleAllFunction = function(state) {
				return function() {
					tree.find(".projects input[type=checkbox]").not("[disabled]").prop('checked', state);
					tree.find(".aggregateSelectors input[type=checkbox]").not(this).prop("checked", false);
				};
			};
			selectAll.click(toggleAllFunction(true));
			selectNone.click(toggleAllFunction(false));
		})();

		(function setupPropagation() {
			allCheckboxes.click(function() {
				var cb = $(this);
				if (cb.is(":checked")) {
					selectNone.prop("checked", false);
				} else {
					selectAll.prop("checked", false);
				}
			});

			projectCheckboxes.click(function() {
				var cb = $(this);
				cb.closest(".project").find("li.tracker input[type=checkbox]").prop("checked", cb.prop("checked"));
			});
		})();

		(function storeStateToInputFieldBeforeSubmit() {

			var getSelectedIds = function(criteria) {
				return $.map(tree.find(".tracker input[type=checkbox]").filter(criteria), function(e) {
					return $(e).data("tracker-id");
				}).join(",");
			};

			$(".trackerTreeForm [name=SUBMIT]").click(function() {
				var form = $(this).closest("form");
				disableDoubleSubmit(form);
				form.find("[name=selected_tracker_ids]").val(getSelectedIds(":checked"));
				form.find("[name=deselected_tracker_ids]").val(getSelectedIds(':not(":checked")'));
				$.post(form.attr("action"), form.serialize(), function() {

					if ("${param.tree_id}" != "") {
						var libraryTree = parent.window.$.jstree.reference("#${param.tree_id}");
						if (libraryTree) {
							libraryTree.refresh();
						}
					}
					inlinePopup.close();
				}).fail(function() {
					alert("An error occurred while saving library configuration!");
				});
				return false;
			});
		})();
	});

</script>
