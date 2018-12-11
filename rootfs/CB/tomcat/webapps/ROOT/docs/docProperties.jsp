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

<%@page import="com.intland.codebeamer.Config"%>
<%@page import="com.intland.codebeamer.datatransfer.MimeTargetWindow" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="acltaglib" prefix="acl" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<%@ page import="com.intland.codebeamer.taglib.TableCellCounter"%>

<%-- Access Variables --%>
<acl:isUserInRole var="userIsprojectAdmin"	   value="project_admin" />
<acl:isUserInRole var="userCanBrowseHistory"   value="document_view_history" />
<acl:isUserInRole var="userCanSubscribe"	   value="document_subscribe" />
<acl:isUserInRole var="userCanSubscribeOthers" value="document_subscribe_others" />
<acl:isUserInRole var="userCanViewSubscribers" value="document_subscribers_view" />

<style type="text/css">
	.newskin td.optional {
		padding-left: 0px;
	}

	.propertyTable {
		margin: 0px !important;
	}

	.ditch-tab-skin-cb-box {
		margin-top: 5px;
	}

	.propertyTable .tableItem {
		padding-left: 5px !important;
		padding-right: 25px !important;
	}

	.propertyTable td {
		padding-top: 5px !important;
		padding-bottom: 5px !important;
	}
	.actionBar .menuArrowDown {
		top: -1px;
	}
</style>

<%-- FIXME --%>
<c:set var="userCanViewAssociations" value="true" />

<c:set var="userCanViewComments" value="true" />

<c:choose>
	<c:when test="${document.directory or document.typeId == 16}">
		<c:url var="click_url" value="${document.urlLink}">
			<c:if test="${!empty param.revision}">
				<c:param name="revision" value="${param.revision}" />
			</c:if>
		</c:url>

		<spring:message var="title" code="${document.typeId == 16 ? 'tracker.view.Document view.label' : 'document.type.directory.browse'}" text="Open Directory"/>
		<ui:coloredEntityIcon iconUrlVar="mimeIcon" iconBgColorVar="bgColor" subject="${document}"/>
		<c:set var="target" value="_top" />
	</c:when>

	<c:otherwise>
		<ui:coloredEntityIcon iconUrlVar="mimeIcon" iconBgColorVar="bgColor" subject="${document}"/>

		<spring:message var="title" code="document.type.file.open" text="Open Document"/>

		<c:choose>
			<c:when test="${fn:endsWith(document.name, '.cbmxml')}">
				<c:url var="diagramUrl" value="/mxGraph/documentEditor.spr?doc_id=${document.id}">
					<c:choose>
						<c:when test="${!empty param.revision}">
							<c:param name="revision" value="${param.revision}" />
						</c:when>
						<c:when test="${!empty param.version}">
							<c:param name="revision" value="${param.version}" />
						</c:when>
					</c:choose>
				</c:url>
				<c:set var="click_url" value="javascript:showDocumentDiagramEditor('${diagramUrl}')" />
				<c:set var="target" value="_top" />
			</c:when>
			
			<c:when test="${document.mimeType == 'text/wiki'}">
				<c:url var="click_url" value="${document.urlLink}">
					<c:choose>
						<c:when test="${!empty param.revision}">
							<c:param name="revision" value="${param.revision}" />
						</c:when>
						<c:when test="${!empty param.version}">
							<c:param name="revision" value="${param.version}" />
						</c:when>
					</c:choose>
				</c:url>
				<c:set var="target" value="_top" />
			</c:when>

			<c:otherwise>
				<tag:encodePath var="filename" value="${document.name}" />

				<c:url var="click_url" value="/displayDocument/${filename}">
					<c:param name="doc_id" value="${document.id}" />
					<c:choose>
						<c:when test="${!empty param.revision}">
							<c:param name="revision" value="${param.revision}" />
						</c:when>
						<c:when test="${!empty param.version}">
							<c:param name="revision" value="${param.version}" />
						</c:when>
					</c:choose>
				</c:url>
			</c:otherwise>
		</c:choose>

		<c:set var="officeMimeType" value="<%= MimeTargetWindow.getOfficeMimeType() %>"/>
		<c:if test="${not fn:contains(officeMimeType, document.mimeType)}">
			<c:set var="onclick" value="launch_url('${click_url}');return false;" />
		</c:if>
	</c:otherwise>
</c:choose>

<%
	final int MAXCOLUMNS = 2;
	TableCellCounter tableCellCounter = new TableCellCounter(out, pageContext, MAXCOLUMNS, 2);
%>

<TABLE class="propertyTable" BORDER="0" class="formTableWithSpacing" CELLPADDING="3" >

<%	tableCellCounter.insertNewRow(); %>
<TD CLASS="optional" style="vertical-align: top;"><spring:message code="document.name.label" text="Name"/>:</TD>

<c:choose>
	<c:when test="${document.deleted or empty document.id}">
		<TD CLASS="closedItem tableItem " style="vertical-align: top;">
			<c:out value="${document.name}" default="--" />
		</TD>
	</c:when>

	<c:otherwise>
		<TD CLASS="tableItem" style="vertical-align: top;">
			<A HREF="<c:out value="${click_url}" />" TITLE="<c:out value="${title}" />"
			<c:if test="${target != '_top'}">
				TARGET="<c:out value="${target}" />" ONCLICK="<c:out value="${onclick}" />"
			</c:if>
			>
				<html:img page="${mimeIcon}" border="0" width="16" height="16" align="top" style="background-color:${bgColor}"/>
			</A>
			<A HREF="<c:out value="${click_url}" />" TITLE="<c:out value="${title}" />"
			<c:if test="${target != '_top'}">
				TARGET="<c:out value="${target}" />" ONCLICK="<c:out value="${onclick}" />"
			</c:if>
			>
				<c:out value="${document.name}" />
			</A>
		</TD>
	</c:otherwise>
</c:choose>

<%	tableCellCounter.insertNewRow(); %>
<TD CLASS="optional" style="vertical-align: top;"><spring:message code="document.description.label" text="Description"/>:</TD>
<TD CLASS="tableItem" style="white-space: normal;"><tag:transformText value="${document.description}" format="${document.descriptionFormat}" default="--" /></TD>

<%	tableCellCounter.insertNewRow(); %>
<TD CLASS="optional"><spring:message code="document.directory.label" text="Directory"/>:</TD>

<c:choose>
	<c:when test="${!empty document.parent.id}">
		<tag:document var="directory" doc_id="${document.parent.id}" revision="${param.revision}" artifactRevisionVar="directoryRevision"/>
		<c:set var="dirname" value="${directory.path}" />
		<c:url var="gotoLink" value="${directoryRevision.urlLink}"/>
	</c:when>

	<c:otherwise>
		<c:if test="${document.project.id gt 0}">
			<spring:message var="dirname" code="Documents" text="Documents"/>
			<c:url var="gotoLink" value="/proj/doc.do">
				<c:param name="proj_id" value="${document.project.id}" />
			</c:url>
		</c:if>
	</c:otherwise>
</c:choose>

<TD CLASS="tableItem">
	<c:if test="${!empty gotoLink}">
		<html:link href="${gotoLink}">
			<c:choose>
				<c:when test="${empty document.parent.id}">
					<c:set var="parentIcon" value="/images/newskin/item/directory-m.png"/>
					<c:set var="parentBgColor" value="<%= com.intland.codebeamer.ui.view.ColoredEntityIconProvider.freshColor %>"/>
				</c:when>
				<c:otherwise>
					<ui:coloredEntityIcon iconUrlVar="parentIcon" iconBgColorVar="parentBgColor" subject="${directory}"/>
				</c:otherwise>
			</c:choose>
			<html:img title="${title}" page="${parentIcon}" border="0" width="16" height="16" align="top" style="background-color:${parentBgColor}"/>
		</html:link>
		<c:forTokens var="entryName" varStatus="status" items="${dirname}" delims="/">
			<c:choose>
				<c:when test="${not status.last}">
					<c:out value="${entryName}"/> /
				</c:when>
				<c:otherwise>
					<a title="${title}" href="${gotoLink}"><c:out value="${entryName}"/></a>
				</c:otherwise>
			</c:choose>
		</c:forTokens>
	</c:if>
</TD>

<%	tableCellCounter.insertNewRow(); %>
<TD CLASS="optional"><spring:message code="document.lastModifiedAt.label" text="Modified"/>:</TD>
<TD CLASS="tableItem">
	<tag:userLink user_id="${document.lastModifiedBy.id}" />
	<c:if test="${!empty document.lastModifiedBy.id}">
		<tag:formatDate	value="${document.lastModifiedAt}" />
	</c:if>
</TD>

<%	tableCellCounter.insertNewRow(); %>
<TD CLASS="optional"><spring:message code="document.id.label" text="Document ID"/>:</TD>
<TD CLASS="tableItem"><c:out value="${document.id}" default="${doc_id}" /></TD>

<%	tableCellCounter.insertNewRow(); %>
<TD CLASS="optional"><spring:message code="document.owner.label" text="Owner"/>:</TD>
<TD CLASS="tableItem"><tag:userLink user_id="${document.owner.id}" /></TD>

<%	tableCellCounter.insertNewRow(); %>
<TD CLASS="optional"><spring:message code="document.status.label" text="Status"/>:</TD>
<TD CLASS="tableItem">
	<c:choose>
		<c:when test="${empty document.status}">
			--
		</c:when>
		<c:otherwise>
			<spring:message code="document.status.${document.status.name}" text="${document.status.name}"/>
		</c:otherwise>
	</c:choose>
</TD>

<%	tableCellCounter.insertNewRow(); %>
<TD CLASS="optional"><spring:message code="document.createdAt.label" text="Created"/>:</TD>
<TD CLASS="tableItem"><tag:formatDate value="${document.createdAt}" /></TD>

<%	tableCellCounter.insertNewRow(); %>
	<TD CLASS="optional"><spring:message code="document.version.label" text="Version"/>:</TD>
	<TD CLASS="tableItem"><c:out value="${document.version}" /></TD>


<c:if test="${!document.directory}">
	<%	tableCellCounter.insertNewRow(); %>
		<TD CLASS="optional"><spring:message code="document.mimeType.label" text="MIME Type"/>:</TD>
		<TD CLASS="tableItem"><c:out value="${document.mimeType}" default="--" /></TD>


	<%	tableCellCounter.insertNewRow(); %>
		<TD CLASS="optional"><spring:message code="document.fileSize.label" text="Size"/>:</TD>

		<tag:formatFileSize var="humanSize" value="${document.fileSize}" />

		<TD CLASS="tableItem"><c:out value="${humanSize}" /> (<fmt:formatNumber value="${document.fileSize}" /> Bytes)</TD>
</c:if>


<%	tableCellCounter.insertNewRow(); %>
	<c:choose>
		<c:when test="${empty docLock}">
			<TD CLASS="optional"><spring:message code="document.lock.label" text="Lock"/>:</TD>
			<TD CLASS="tableItem"><spring:message code="document.unlocked.label" text="Unlocked"/></TD>
		</c:when>

		<c:when test="${docLock.temporary}">
			<TD CLASS="optional"><spring:message code="document.lock.label" text="Lock"/>:</TD>
			<TD CLASS="tableItem">
				<spring:message code="document.editedBy.label" text="Currently edited by"/>
				<tag:userLink user_id="${docLock.userId}" />
			</TD>
		</c:when>

		<c:otherwise>
			<TD CLASS="optional"><spring:message code="document.lockedBy.label" text="Locked by"/>:</TD>
			<TD CLASS="tableItem"><tag:userLink user_id="${docLock.userId}" /></TD>
		</c:otherwise>
	</c:choose>


<c:if test="${!document.directory}">
	<%	tableCellCounter.insertNewRow(); %>
		<TD CLASS="optional"><spring:message code="document.keptHistoryEntries.label" text="Max. Versions"/>:</TD>

		<c:set var="versions" value="${document.additionalInfo.keptHistoryEntries}" />
		<c:set var="allVersions" value="<%=Integer.MAX_VALUE%>" />
		<c:choose>
			<c:when test="${empty versions or versions == -1}">
				<%-- the "Default" sie selected, this can be either "ALL" or the number configured in general.xml --%>
				<c:set var="documentMaxHistory" value="<%=Config.getDocumentMaxHistory()%>" />
				<c:choose>
					<c:when test="${empty documentMaxHistory}">
						<spring:message var="keepVersions" code="document.keptHistoryEntries.all" text="All"/>
					</c:when>
					<c:otherwise>
						<spring:message var="keepVersions" code="document.keptHistoryEntries.default" text="Default {0}" arguments="${documentMaxHistory}"/>
					</c:otherwise>
				</c:choose>
			</c:when>

			<c:when test="${versions eq allVersions}">
				<spring:message var="keepVersions" code="document.keptHistoryEntries.all" text="All"/>
			</c:when>

			<c:when test="${versions eq 0}">
				<spring:message var="keepVersions" code="document.keptHistoryEntries.none" text="None"/>
			</c:when>

			<c:when test="${versions eq 1}">
				<spring:message var="keepVersions" code="document.keptHistoryEntries.prev" text="Previous"/>
			</c:when>

			<c:otherwise>
				<spring:message var="keepVersions" code="document.keptHistoryEntries.lastX" text="Last {0}" arguments="${versions}"/>
			</c:otherwise>
		</c:choose>
		<TD CLASS="tableItem"><c:out value="${keepVersions}" /></TD>
</c:if>

<c:if test="${userCanSeeTemporaryContent}">
	<%	tableCellCounter.insertNewRow(); %>
		<TD CLASS="optional"><spring:message code="document.temporaryFile.label" text="Temporary file"/>:</TD>

		<TD CLASS="tableItem">
			<spring:message code="document.temporaryFile.actions.label" text="Actions"/>:&nbsp;

			<c:url var="click_url" value="/displayDocument/${filename}">
				<c:param name="doc_id" value="${document.id}" />
				<c:param name="temp" value="1" />
			</c:url>
			<c:set var="onclick" value="launch_url('${click_url}');return false;" />

			<spring:message var="viewTempTitle" code="document.temporaryFile.view.tooltip" text="View temporary content."/>
			<A TITLE="${viewTempTitle}"
				<c:if test="${target != '_top'}">
					TARGET="<c:out value="${target}" />" ONCLICK="<c:out value="${onclick}" />"
				</c:if>
				HREF="<c:out value="${click_url}" />"><spring:message code="document.temporaryFile.view.label" text="View"/></A>&nbsp;

			<c:url var="activateTemp" value="/proj/doc/documentProperties.do">
				<c:param name="releaseTemp" value="true" />
				<c:param name="doc_id" value="${document.id}" />
			</c:url>
			<c:url var="deleteTemp" value="/proj/doc/documentProperties.do">
				<c:param name="releaseTemp" value="false" />
				<c:param name="doc_id" value="${document.id}" />
			</c:url>

			<spring:message var="activateTempTitle" code="document.temporaryFile.activate.tooltip" text="Activate temporary content."/>
			<a TITLE="${activateTempTitle}" HREF="<c:out value="${activateTemp}" />"><spring:message code="document.temporaryFile.activate.label" text="Activate"/></a>&nbsp;

			<spring:message var="deleteTempTitle" code="document.temporaryFile.delete.tooltip" text="Delete temporary content."/>
			<a TITLE="${deleteTempTitle}" HREF="<c:out value="${deleteTemp}" />"><spring:message code="document.temporaryFile.delete.label" text="Delete"/></a>
		</TD>
</c:if>

<c:if test="${!document.directory}">
	<c:forEach items="${attributes}" var="attribute">
		<% tableCellCounter.insertNewRow(); %>
		<TD CLASS="optional" title="<c:out value="${attribute.key.title}"/>"><c:out value="${attribute.key.label}" />:</TD>
		<TD CLASS="tableItem"><c:out value="${attribute.value}" default="--"/></TD>
	</c:forEach>
</c:if>

<% tableCellCounter.finishRow(); %>
</TABLE>
