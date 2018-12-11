<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<table class="summary">
	<tr>
		<td><strong><spring:message code="sysadmin.dashboard.codebeamer.entities.item.count" text="Work Items" />:</strong></td>
		<td class="second-column">${codebeamerEntityStatistics.itemCount}</td>
	</tr>
	<tr>
		<td><strong><spring:message code="sysadmin.dashboard.codebeamer.entities.artifact.count" text="Artifacts" />:</strong></td>
		<td class="second-column">${codebeamerEntityStatistics.artifactCount}</td>
	</tr>
	<tr>
		<td><strong><spring:message code="sysadmin.dashboard.codebeamer.entities.comment.count" text="Attachments / Comments" />:</strong></td>
		<td class="second-column">${codebeamerEntityStatistics.commentAttachmentCount}</td>
	</tr>
	<tr>
		<td><strong><spring:message code="sysadmin.dashboard.codebeamer.entities.user.count" text="Users" />:</strong></td>
		<td class="second-column">${codebeamerEntityStatistics.userCount}</td>
	</tr>
	<tr>
		<td><strong><spring:message code="sysadmin.dashboard.codebeamer.entities.group.count" text="Groups" />:</strong></td>
		<td class="second-column">${codebeamerEntityStatistics.userGroupCount}</td>
	</tr>
	<tr>
		<td><strong><spring:message code="sysadmin.dashboard.codebeamer.entities.role.count" text="Roles" />:</strong></td>
		<td class="second-column">${codebeamerEntityStatistics.roleCount}</td>
	</tr>
	<tr>
		<td><strong><spring:message code="sysadmin.dashboard.codebeamer.entities.document.count" text="Documents" />:</strong></td>
		<td class="second-column">${codebeamerEntityStatistics.documentCount}</td>
	</tr>
	<tr>
		<td><strong><spring:message code="sysadmin.dashboard.codebeamer.entities.wiki.count" text="Wiki Pages" />:</strong></td>
		<td class="second-column">${codebeamerEntityStatistics.wikiPageCount}</td>
	</tr>
	<tr>
		<td><strong><spring:message code="sysadmin.dashboard.codebeamer.entities.dashboard.count" text="Dashboards" />:</strong></td>
		<td class="second-column">${codebeamerEntityStatistics.dashboardCount}</td>
	</tr>
	<tr>
		<td><strong><spring:message code="sysadmin.dashboard.codebeamer.entities.report.count" text="Reports" />:</strong></td>
		<td class="second-column">${codebeamerEntityStatistics.reportCount}</td>
	</tr>
</table>