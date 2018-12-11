<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/user-profile-information.less' />" type="text/css" media="all" />
<style type="text/css">
	.userPhotoPlaceholder.tableIcon {
		vertical-align: middle;
	    height: 28px;
	    width: 28px;
	    border-radius: 50%;
	}
</style>

<c:if test="${!mapEntry.value.permissionChangesEnabled}">
	<div class="warning"><spring:message code="sysadmin.audit.permissions.disabled" text="All event types of permission is disabled, please enable it on Configs tab or in general.xml!"/></div>
</c:if>

<c:url var="requestUri" value="/proj/tracker/configuration.spr">
	<c:param name="tracker_id" value="${mapEntry.key.id }"></c:param>
	<c:param name="orgDitchnetTabPaneId" value="permission-changes-${mapEntry.key.id }"></c:param>
</c:url>

<display:table
	list="${mapEntry.value.permissionEntries }"
	sort="external"
	cellpadding="0"
	export="false"
	decorator="com.intland.codebeamer.ui.view.table.PermissionDecorator"
	requestURI="${requestUri }"
	excludedParams="orgDitchnetTabPaneId"
	>

	<display:setProperty name="pagination.pagenumber.param"    	value="page" />
	<display:setProperty name="pagination.sort.param"          	value="sort" />
	<display:setProperty name="pagination.sortdirection.param" 	value="sortDirection" />
	<display:setProperty name="paging.banner.placement" 		value="bottom"/>
	<display:setProperty name="paging.banner.onepage" 			value="" />
	<display:setProperty name="paging.banner.one_item_found" 	value="" />
	<display:setProperty name="paging.banner.all_items_found" 	value="" />
	<display:setProperty name="paging.banner.some_items_found" 	value="" />
	<display:setProperty name="paging.banner.group_size" 		value="5" />

	<spring:message var="permissionsUserLabel" code="sysadmin.audit.permissions.user" text="User" />
	<display:column title="${permissionsUserLabel}" property="user" sortable="true">
	</display:column>

	<spring:message var="permissionsArtifactLabel" code="sysadmin.audit.permissions.artifact" text="Artifact" />
	<display:column title="${permissionsArtifactLabel}" property="objectId" sortable="true">
	</display:column>

	<spring:message var="permissionsEventTypeLabel" code="sysadmin.audit.permissions.eventtype" text="Event Type" />
	<display:column title="${permissionsEventTypeLabel}" property="event" sortable="true">
	</display:column>

	<spring:message var="permissionsProjectLabel" code="sysadmin.audit.permissions.project" text="Project" />
	<display:column title="${permissionsProjectLabel}" property="project" sortable="true">
	</display:column>

	<spring:message var="permissionsTrackerLabel" code="sysadmin.audit.permissions.tracker" text="Tracker" />
	<display:column title="${permissionsTrackerLabel}" property="tracker" sortable="true">
	</display:column>

	<spring:message var="permissionsMessageLabel" code="sysadmin.audit.permissions.message" text="Message" />
	<display:column title="${permissionsMessageLabel}" property="details" sortable="false"  style="max-width:200px;word-wrap: break-word;">
	</display:column>

	<spring:message var="permissionsCreatedAtLabel" code="sysadmin.audit.permissions.createdAt" text="Created at" />
	<display:column title="${permissionsCreatedAtLabel}" property="createdAt" sortable="true">
	</display:column>
</display:table>

<script type="text/javascript">
	(function ($) {
		$(".compare-artifacts-link").click(function(event) {
			var $element, targetItemId, itemId, $selectedVersions, versions, newVersion, version, tmp;

			$element = $(this);

			var entryId = $element.data("entryid");

			inlinePopup.show(
				contextPath + "/audit/entries/diff.spr?entryId=" + entryId + '&checkSysadminPermission=false',
				{
					geometry: "large"
				}
			);

			event.preventDefault();
			event.stopPropagation();
		});
	})(jQuery);
</script>

