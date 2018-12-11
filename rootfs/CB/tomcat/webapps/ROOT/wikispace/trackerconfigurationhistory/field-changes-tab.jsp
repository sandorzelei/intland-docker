<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>

<c:if test="${isExportMode}"><br><b>${tabTitle}</b><br></c:if>

<style type="text/css">
	.group_move_placeholder {
	  	display: table-row;
	}

	tbody.table {
		background-color: #FCFCFC !important;
	}

	span.indenter {
	  display: inline-block;
	  margin: 0;
	  padding: 0;
	  text-align: right;
	  user-select: none;
	  -khtml-user-select: none;
	  -moz-user-select: none;
	  -o-user-select: none;
	  -webkit-user-select: none;
	  width: 19px;
	}

	tr.table span.indenter {
		background-image: url("${tableCollapseImageUrl}");
		background-position: center center !important;
		background-repeat: no-repeat !important;
		height: 12px !important;
	}

	tr.table span.indenter.collapsed {
		background-image: url("${tableExpandImageUrl}");
	}

	tr.tableColumn span.indenter {
		background-image: url("${tableColumnImageUrl}");
		background-position: right center !important;
		background-repeat: no-repeat !important;
	 	width:	38px;
		height: 12px !important;
	}

	span.fixedType {
		color: #777;
	}

	span.choiceTypes {
			color: #777;
	}

	ul.projectRoles li.projectRole, ul.projectRoles li.moreProjectRoles {
		list-style-type: circle;
	}

	li.projectQualifier > label {
		font-weight: bold;
	}

	li.permission > label {
		font-weight: bold;
	}

	li.trackerType, li.moreTrackerTypes {
		list-style-type: circle;
	}

	li.trackerType > label {
		font-weight: bold;
	}

	li.tracker {
		list-style-type: circle;
	}

	li.tracker > label {
		font-weight: bold;
	}

	li.folder {
		margin-top: 4px;
	}

	li.folder > label {
		font-weight: bold;
	}

	li.project, li.moreProjects {
		margin-top: 6px;
	}

	li.project > label {
		font-weight: bold;
	}

	select.componentSelector optGroup {
		font-weight: normal;
	}

	div.combinationsDialog {
		padding: 1em !important;
	}

	div.mandatoryDialog {
		padding: 1em !important;
	}

	div.requiredIn {
		padding: 4px 0px 4px 0px !important;
	}

	div.defaultValuesDialog {
		padding: 1em !important;
	}

	#trackerFields {
		border: 1px solid #ddd;
		margin-top: 15px !important;
	}

	#trackerFields tr:hover {
		background-color: #f4f4f4;
	}

	#trackerFields .yuimenubaritemlabel {
		float: right;
	}

	#trackerFields td .fieldType {
		padding: 1px 5px;
	}

	#trackerFields td:hover .fieldType.highlight-on-hover {
		padding: 0px 4px;
	}

	#trackerFields tr {
		line-height: 24px;
	}

	#trackerFields td span.highlight-on-hover form {
		display: inline;
		margin-left: -5px;
		margin-right: -5px;
	}

	#trackerFields td span.fieldLabel.hidden {
		color: gray;
	}

	span.removeButton {
		width: 16px;
		height: 16px;
		background-image: url("../../images/newskin/action/delete-grey-16x16.png");
		display: inline-block;
		margin: 0 3px 0 0;
		top: 3px;
		position: relative;
		cursor: pointer;
	}

	span.removeButton:hover {
		background-image: url("../../images/newskin/action/delete-grey-16x16_on.png");
	}

	span.editButton {
		background-image: url("../../images/newskin/action/edit-s.png");
	    margin-right: 5px;
	    margin-top: 4px;
		width: 12px;
	    height: 12px;
	    display: inline-block;
	    opacity: 0.4;
	    cursor: pointer;
	}

	span.editButton:hover {
		opacity: 0.7;
	}
	#toggleBoxes {
		margin-top: 15px;
	}

	#toggleBoxes .subtext {
		font-size: 13px;
		margin-right: 20px;
	}

	#tracker-customize td.matrixCell, #tracker-customize th.permOwner {
		width: 7%;
	}

	#tracker-customize th.permOwner {
		padding-left: 10px;
		padding-right: 10px;
	}

	.newskin td.issueHandle {
		background-image: url("../../images/newskin/action/dragbar-dark.png");
		background-position: 3px center;
		background-color: #d1d1d1;
	}

	.ui-resizable-se {
   		right: 0px !important;
    	bottom: 10px !important;
  	}

  	.tooltipHeader {
  		border-bottom: 1px solid lightgray;
  		padding-bottom: 4px;
  	}

  	div.labelAndSelectorWrapper {
  		padding: 5px;
  		display: inline-block;
  	}

  	div.externalProjectCountBadge {
  		width: 35px;
  		height: 15px;
  		display: inline-block;
  		text-align: left;
  		vertical-align: middle;
  	}

  	div.externalProjectCountBadge img {
  		padding-left: 3px;
  		vertical-align: middle;
  	}

  	div.externalProjectCountBadge label {
  		color: white;
  		padding-right: 5px;
  		font-weight: bold;
  		line-height: normal;
  	}

  	div.externalProjectCountBadge span {
  		color: white;
  		font-weight: bold;
  	}

  	div.externalProjectCountBadgeGreen {
  		background: #03BC0E;
  	}

  	div.externalProjectCountBadgeYellow {
  		background: #FFCD17;
  	}

  	div.externalProjectCountBadgeRed {
  		background: #C40000;
  	}

  	span.externalProjectIconWrapper {
  		display: inline-block;
  		height: 100%;
  		vertical-align: middle;
  	}

	.ui-multiselect-menu.ui-widget-content .ui-widget-header {
		display: block !important;
	}

</style>

<table class="tracker-history-entries"${tableStyle}>
    <thead>
        <tr>
            <th></th>
            <th><spring:message code="tracker.configuration.history.plugin.field.label" text="Field" /></th>
            <th><spring:message code="tracker.configuration.history.plugin.action.label" text="Action" /></th>
            <th><spring:message code="tracker.configuration.history.plugin.new.value.label" text="New value" /></th>
            <th><spring:message code="tracker.configuration.history.plugin.old.value.label" text="Old value" /></th>
        </tr>
    </thead>
    <c:forEach var="auditEntry" items="${mapEntry.value.fieldChanges}" varStatus="auditEntryLoop">
        <c:if test="${not auditEntry.baselineEntry}">
            <c:forEach var="change" items="${auditEntry.configurationChanges}" varStatus="loop">
                <tr style="vertical-align: top;">
                    <c:if test="${loop.count eq 1}">
                        <td class="user-photo-cell" rowspan="${fn:length(auditEntry.configurationChanges)}">
                            <div class="user-photo"${displayNoneStyle}><ui:userPhoto userId="${auditEntry.user.id}" userName="${auditEntry.user.name}" url="/userdata/${auditEntry.user.id}"></ui:userPhoto></div>
                            <div>
                                <a href="${pageContext.request.contextPath}/userdata/${auditEntry.user.id}">${auditEntry.user.name}</a>
                                <div><tag:formatDate value="${auditEntry.date}" /></div>
                            </div>
                        </td>
                    </c:if>
                    <td>${auditEntry.fieldLabel}</td>
                    <td>
                        <spring:message code="tracker.configuration.history.${change.action}.label" />
                        <c:if test="${auditEntry.inheritedEntry}"><span class="inherited-change">(inherited)</span></c:if>
                    </td>
                    <td>
                   		<c:choose>
                   			<c:when test="${not empty change.data and change.action eq 'FIELD_REFERENCE_TYPE_UPDATED' and change.data['newFieldConfig']['fieldReferences'] != null}">
                   				${ui:getStringWithDefaultValue(change.newValue, '--')}
                   				<c:choose>
                   					<c:when test="${change.data['newFieldConfig']['refType'] != null && (change.data['newFieldConfig']['refType'] == 9 || change.data['newFieldConfig']['refType'] == 3 || change.data['newFieldConfig']['refType'] == 18)}">
                   						<c:set var="fieldConfig" value="${change.data['newFieldConfig']}" scope="request" />
		                   				<jsp:include page="referenceField.jsp" />
                   					</c:when>
                   					<c:when test="${change.data['newFieldConfig']['refType'] != null && (change.data['newFieldConfig']['refType'] == 1)}">
		                   				<c:set var="fieldConfig" value="${change.data['newFieldConfig']}" scope="request" />
		                   				<jsp:include page="userField.jsp" />
		                   			</c:when>
		                   			<c:when test="${change.data['newFieldConfig']['refType'] != null && (change.data['newFieldConfig']['refType'] == 2)}">
		                   				<c:set var="fieldConfig" value="${change.data['newFieldConfig']}" scope="request" />
		                   				<jsp:include page="projectField.jsp" />
		                   			</c:when>
                   				</c:choose>
                   			</c:when>
                   			<c:when test="${not empty change.data and change.action eq 'FIELD_REFERENCE_TYPE_UPDATED' and change.data['newFieldConfig']['fieldOptions'] != null}">
                   				<c:set var="fieldConfig" value="${change.data['newFieldConfig']}" scope="request" />
                   				<jsp:include page="optionField.jsp" />
                   			</c:when>
                   			<c:otherwise>
                   				${ui:getStringWithDefaultValue(change.newValue, '--')}
                   			</c:otherwise>
                   		</c:choose>
                    </td>
                    <td>
                   		<c:choose>
                   			<c:when test="${not empty change.data and change.action eq 'FIELD_REFERENCE_TYPE_UPDATED' and change.data['oldFieldConfig']['fieldReferences'] != null}">
                   				${ui:getStringWithDefaultValue(change.oldValue, '--')}
                   				<c:choose>
                   					<c:when test="${change.data['oldFieldConfig']['refType'] != null && (change.data['oldFieldConfig']['refType'] == 9 || change.data['oldFieldConfig']['refType'] == 3 || change.data['oldFieldConfig']['refType'] == 18)}">
		                   				<c:set var="fieldConfig" value="${change.data['oldFieldConfig']}" scope="request" />
		                   				<jsp:include page="referenceField.jsp" />
		                   			</c:when>
		                   			<c:when test="${change.data['oldFieldConfig']['refType'] != null && (change.data['oldFieldConfig']['refType'] == 1)}">
		                   				<c:set var="fieldConfig" value="${change.data['oldFieldConfig']}" scope="request" />
		                   				<jsp:include page="userField.jsp" />
		                   			</c:when>
		                   			<c:when test="${change.data['oldFieldConfig']['refType'] != null && (change.data['oldFieldConfig']['refType'] == 2)}">
		                   				<c:set var="fieldConfig" value="${change.data['oldFieldConfig']}" scope="request" />
		                   				<jsp:include page="projectField.jsp" />
		                   			</c:when>
		                   		</c:choose>
                   			</c:when>
                   			<c:when test="${not empty change.data and change.action eq 'FIELD_REFERENCE_TYPE_UPDATED' and change.data['oldFieldConfig']['fieldOptions'] != null}">
               					<c:set var="fieldConfig" value="${change.data['oldFieldConfig']}" scope="request" />
                   				<jsp:include page="optionField.jsp" />
                   			</c:when>
                   			<c:otherwise>
                   				${ui:getStringWithDefaultValue(change.oldValue, '--')}
                   			</c:otherwise>
                   		</c:choose>
                    </td>
                </tr>
            </c:forEach>
        </c:if>
        <c:set var="auditEntry" value="${auditEntry}" scope="request"/>
        <jsp:include page="audit-baseline-row.jsp">
            <jsp:param value="5" name="columnCount" />
        </jsp:include>
    </c:forEach>
</table>
