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

<%--
	this is a popup that is displayed after a user unsuccessfully tries to link a test case
	to a requirement on document view.
--%>
<meta name="decorator" content="popup"/>

<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<script src="<ui:urlversioned value='/js/itemLinking.js' />"></script>

<style type="text/css">
	fieldset {
		margin-top: 20px;
	}

	span.hint{
		display: inline-block;
	    width: 50%;
	    margin-left: 10px;
	    float: right;
    }

    #field-mapping {
		margin-top: 30px;
	}
</style>

<script type="text/javascript">
	function closePopup() {
		parent.trackerObject.refreshNode("${requirement.id}");
		inlinePopup.close();
	}
</script>

<c:set var="requirementName"><c:out value="${requirement.name }" escapeXml="true"/></c:set>

<ui:actionMenuBar >
	<ui:pageTitle>
		<c:if test="${not empty requirement.name }">
			<spring:message code="tracker.view.layout.document.linking.page.title" text="Linking test cases to ${requirementName }" arguments="${requirementName }"/>
		</c:if>
		<c:if test="${empty requirement.name }">
			<spring:message code="tracker.view.layout.document.linking.page.empty.name.title" text="Linking Test Cases to Requirement"/>
		</c:if>
	</ui:pageTitle>
</ui:actionMenuBar>
<form:form commandName="command" method="post">
	<div class="actionBar">
			<spring:message var="saveText" code="button.save" />
			<spring:message var="cancelText" code="button.cancel" />
			<input type="submit" class="button" value="${saveText}" />
			<a href="#" onclick="closePopup(); return false;" class="cancelButton">${cancelText}</a>
	</div>
	<div class="contentWithMargins">
		<div class="information">
			<c:url value="${requirement.urlLink }" var="requirementUrl"/>
			<c:set var="testCaseCount" value="${fn:length(testCases) }"/>
			<spring:message code="${testCaseCount == 1 ? 'tracker.view.layout.document.linking.hint' : 'tracker.view.layout.document.linking.hint.plural' }"
				arguments="${testCaseCount },${requirementUrl }, ${requirementName } "/><br/>
			<a href="#" onclick="$(this).next().show(); $(this).hide(); return false;">
				<spring:message code="tracker.view.layout.document.linking.show.test.cases.label" text="Show Test Cases"/>
			</a>
			<div style="display:none;">
				<c:forEach items="${testCases }" var="item" varStatus="status">
					<ui:itemLink item="${item }"></ui:itemLink>
					<c:if test="${!status.last }">, </c:if>
				</c:forEach>
			</div>
		</div>

		<c:if test="${fn:length(alreadyAssociated) > 0 }">
			<div class="warning">
				<spring:message code="tracker.view.layout.document.linking.already.associated.hint"/>
				<a href="#" onclick="$(this).next().show(); $(this).hide(); return false;">
					<spring:message code="tracker.view.layout.document.linking.show.test.cases.label" text="Show Test Cases"/>
				</a>
				<div style="display:none;">
					<c:forEach items="${alreadyAssociated }" var="item" varStatus="status">
						<c:url value="${item.urlLink }" var="itemUrl"/>
						<a href="${itemUrl}" target="_blank"><c:out escapeXml="true" value="${ui:removeXSSCodeAndHtmlEncode(item.name)}"/></a>
						<c:if test="${!status.last }">, </c:if>
					</c:forEach>
				</div>
			</div>
		</c:if>

		<c:if test="${fn:length(incompatibleItems) > 0 }">
			<div class="warning">
				<spring:message code="tracker.view.layout.document.linking.incompatible.hint"/>
				<a href="#" onclick="$(this).next().show(); $(this).hide(); return false;">
					<spring:message code="tracker.view.layout.document.linking.show.test.cases.label" text="Show Test Cases"/>
				</a>
				<div style="display:none;">
					<c:forEach items="${incompatibleItems }" var="item" varStatus="status">
						<ui:itemLink item="${item }"></ui:itemLink>
						<c:if test="${!status.last }">, </c:if>
					</c:forEach>
				</div>
			</div>
		</c:if>

		<%-- when some of the items can reference the current requirement tracker show these options --%>
		<div class="form-element">
			<form:radiobutton path="verifyOrCopy" id="verify" value="verify" onclick="$('#testCaseTrackerSelector').hide();" disabled="${allIncompatible}"/>
			<label for="verify"><spring:message code="tracker.view.layout.document.linking.verify.with.original.label" text="Verify requirement with the original Test Cases"/></label>
		</div>
		<div class="form-element">
			<form:radiobutton path="verifyOrCopy" id="copy" value="copy" onclick="$('#testCaseTrackerSelector').show();"/>
			<label for="copy">
				<spring:message code="tracker.view.layout.document.linking.verify.with.copy.label" text="Make a copy of the Test Cases and verify the requirement with the copies"/>
			</label>
		</div>

		<c:if test="${allIncompatible }">
			<%-- when all test cases are incompatible with the requirement always select the 'copy' option by default --%>
			<form:hidden path="verifyOrCopy" id="copy" value="copy" />
		</c:if>

		<c:if test="${empty testCaseTrackers }">
			<div class="warning">
				<spring:message code="tracker.view.layout.document.copy.test.cases.no.tracker"
					text="The Test Cases cannot be copied because there is no Test Case tracker configured to reference this tracker"/>
			</div>
		</c:if>
		<c:if test="${not empty testCaseTrackers }">
			<div class="form-element" id="testCaseTrackerSelector" style="${not allIncompatible ? 'display: none;' : ''} margin-left: 22px;">
				<label for="testCaseTrackerId">
					<spring:message code="tracker.view.layout.document.linking.test.case.tracker.label" text="Test Case tracker to copy to"/>:
				</label>
				<form:select path="testCaseTrackerId" id="testCaseTracker">
					<c:forEach items="${testCaseTrackers }" var="entry">
						<optgroup label="<c:out value="${entry.key.name }"/>">
							<c:forEach items="${entry.value }" var="tracker">
								<option value="${tracker.id }">
									<c:out value="${tracker.name }"/>
								</option>
							</c:forEach>
						</optgroup>
					</c:forEach>
				</form:select>
				<span class="hint" style="width: 51%">
					<spring:message code="tracker.view.layout.document.linking.copy.hint"/>
				</span>
				<div id="field-mapping">

				</div>
			</div>
			<c:if test="${not empty baselines }">
				<div class="form-element" style="padding-left: 27px;">
					<label for="baselineId">
						<spring:message code="baseline.label" text="Baseline"/>:
					</label>
					<form:select path="baselineId" items="${baselines }" itemLabel="name" itemValue="version" id="baselineId"></form:select>
					<span class="hint">
						<spring:message code="tracker.view.layout.document.linking.baseline.hint"/>
					</span>
				</div>
			</c:if>
		</c:if>
	</div>

</form:form>

<script type="text/javascript">


	$(document).ready(function () {
		$("#testCaseTracker").change(function () {
			var $fieldMappingBox = $("#field-mapping");
			var $select = $("#testCaseTracker");
			var destinationTrackerId = $select.val();
			var sourceTrackerId = "${testCaseTrackerId }";
			codebeamer.itemLinking.loadFieldMapping($fieldMappingBox, sourceTrackerId, destinationTrackerId);
		});
	});
</script>

