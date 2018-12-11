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
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>

<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="acltaglib" prefix="acl" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<meta name="decorator" content="main"/>
<meta name="module" content="tracker"/>
<meta name="moduleCSSClass" content="trackersModule newskin ${importForm.tracker.isBranch() ? 'tracker-branch' : ''}" />

<ui:actionMenuBar>
	<jsp:attribute name="rightAligned">
		<c:if test="${importForm.tracker.isBranch()}">
			<ui:branchBaselineBadge branch="${importForm.branch}"/>
		</c:if>
	</jsp:attribute>
	<jsp:body>
		<ui:breadcrumbs showProjects="false" projectAware="${importForm.tracker}"><span class='breadcrumbs-separator'>&raquo;</span>
			<ui:pageTitle prefixWithIdentifiableName="false"><spring:message code="issue.import.configure.conversions.title" text="Configure field conversions"/></ui:pageTitle>
		</ui:breadcrumbs>
	</jsp:body>
</ui:actionMenuBar>

<form:form commandName="importForm" action="${flowUrl}" onsubmit="removeHiddenConversionBlocks();">

<form:hidden path="trackerId"/>
<ui:actionBar>
	<jsp:include page="./includes/nextPrevButtons.jsp"/>
</ui:actionBar>

<div class="contentWithMargins">
<form:errors cssClass="error"/>

<style type="text/css">
fieldset {
	margin: 5px 0;
	border: solid 1px silver;
}

.conversionConfigurationBlock {
	/*border-bottom: solid 1px silver;*/
	width: 98%;
	margin-left: 10px;
	padding: 0;
}

.oneConversionBlock {
	display: none;
	margin: 0 0 10px 40px;
}

select, .ui-multiselect {
	margin-left: 5px;
}

#conversionOptions select {
	min-width: 25em;
}
#conversionOptions .hint {
	margin-left: 10px;
}

</style>

<script type="text/javascript">
	function removeHiddenConversionBlocks() {
		// before submitting the form remove the hidden conversion blocks, so these won't be bound by Spring and won't cause conversion errors
		// this is kind of a hack, but it seems nearly impossible to remove these from the Spring's binder's errors !
		$(".oneConversionBlock:hidden").remove();
	}

	// show only the selected conversion, and hide all others
	function updateSelectedConversions() {
		var update = function() {
			var $select = $(this);
			var $block = $select.closest(".conversionConfigurationBlock");
			var value = $select.val();
			$block.find(".oneConversionBlock").each(function() {
				var conversionId = $(this).attr("conversionId");
				if (conversionId == value) {
					$(this).show();
				} else {
					$(this).hide();
				}
			});
		};

		$("select.conversionSelect").change(update).each(update);
	};

	$(updateSelectedConversions);
</script>

<fieldset style="border: none;">
<legend style="font-weight: bold;"><spring:message code="useradmin.importUsers.conversions.legend"/></legend>
<TABLE BORDER="0" class="formTableWithSpacing displaytag" CELLPADDING="0" style="width: auto;" id="conversionOptions">
	<TR>
		<TD class="optional"><spring:message code="issue.import.defaultUserId.label" text="Account Mapping"/>:</TD>
		<TD>
			<form:select path="defaultUserId">
				<form:options items="${importForm.userList}" itemLabel="name" itemValue="value" />
			</form:select>
		</TD>
		<TD>
			<div class='hint'><spring:message code="issue.import.defaultUserId.tooltip" text="map all unknown accounts to this one."/></div>
		</TD>
	</TR>

	<TR>
		<TD class="optional"><spring:message code="issue.import.defaultStatusId.label" text="Status Mapping"/>:</TD>
		<TD>
			<form:select path="defaultStatusId">
				<form:options items="${importForm.statusList}" itemLabel="name" itemValue="value" />
			</form:select>
		</TD>
		<TD>
			<div class='hint'><spring:message code="issue.import.defaultStatusId.tooltip" text="map all unknown status values to this one."/></div>
		</TD>
	</TR>

    <TR>
        <TD class="optional"><spring:message code="issue.import.strict.for.new.items.label" />:</TD>
        <TD>
            <form:checkbox path="strictImportForNewItems" id="strictImportForNewItems" />
        </TD>
        <TD>
            <div class='hint'><spring:message code="issue.import.strict.for.new.items.hint" /></div>
        </TD>
    </TR>

    <TR>
		<TD class="optional">
			<spring:message code="issue.import.new.items.keep.empty.import.data" />:
		</TD>
		<TD>
			<form:select path="keepEmptyImportData">
				<form:option value="true"><spring:message code="issue.import.new.items.keep.empty.import.data.leave.empty"/></form:option>
				<form:option value="false"><spring:message code="issue.import.new.items.keep.empty.import.data.tracker.default"/></form:option>
			</form:select>
		</TD>
		<TD>
			<%--<div class='hint'><spring:message code="issue.import.new.items.keep.empty.import.data.explanation" /></div> --%>
		</TD>
	</TR>

	<acl:isUserInRole value="issue_delete">
		<TR>
			<TD class="optional"><spring:message code="issue.import.emptyTracker.label" text="Clear Tracker"/>:</TD>
			<TD colspan="2">
				<form:checkbox path="emptyTracker" />
				<spring:message code="issue.import.emptyTracker.tooltip" />
			</TD>
		</TR>
	</acl:isUserInRole>

	<TR>
		<TD class="optional"><spring:message code="issue.import.import.fields.for.new.items" />:</TD>
		<TD>
			<c:set var="mappedFieldsTranslated" value="${importForm.mappedFieldsTranslated}" />
			<form:select multiple="true" path="importFieldsForNewItems" id="importFieldsForNewItems">
	            <c:forEach var="fieldLabels" items="${mappedFieldsTranslated}">
	                <c:set var="fieldDescription" value="${fieldLabels}" />
	                <c:set var="field" value="${fieldLabels.field}"/>
	                <form:option value="${field.id}" label="${fieldDescription}" />
	            </c:forEach>
	        </form:select>

	        <script type="text/javascript">
	        	$(function(){ initImportFieldSelect("importFieldsForNewItems"); });
	        </script>
		</TD>
		<TD>
			<div class='hint'><spring:message code="issue.import.import.fields.for.new.items.hint" /></div>
		</TD>
	</TR>

	<TR>
		<TD class="optional"><spring:message code="issue.import.import.fields.for.updating.items" />:</TD>
		<TD>
			<form:select multiple="true" path="importFieldsForExistingItems" id="importFieldsForExistingItems">
	            <c:forEach var="fieldLabels" items="${mappedFieldsTranslated}">
	                <c:set var="fieldDescription" value="${fieldLabels}" />
	                <c:set var="field" value="${fieldLabels.field}"/>
	                <form:option value="${field.id}" label="${fieldDescription}" />
	            </c:forEach>
	        </form:select>
	        <script type="text/javascript">
	        	$(function(){ initImportFieldSelect("importFieldsForExistingItems"); });
	        </script>
		</TD>
		<TD>
			<div class='hint'><spring:message code="issue.import.import.fields.for.updating.items.hint" /></div>
		</TD>
	</TR>
</TABLE>
</fieldset>

<spring:message var="allFieldsLabel" code="issue.import.import.fields.all" />
<script type="text/javascript">
	function initImportFieldSelect(name) {
		$("#" + name).multiselect({
			            multiple: true,
			            noneSelectedText: "--",
			            selectedText: function(numChecked, numTotal, checkedItems) {
			            	if (numChecked == numTotal) {
			            		return "${allFieldsLabel}";	// show "All" when all items checked
			            	} else {
			            		var value = [];
			            		$(checkedItems).each(function(){
			            			value.push($(this).next().html());
			            		});
			            		return value.join(", ");
			            	}
			            },
			            "classes" : "rawImportData"
			        }
			    ).multiselectfilter();
	}
</script>

<c:choose>
<c:when test="${empty importForm.conversions}">
	<div class="information"><spring:message code="issue.import.no.advanced.conversions.available" text="The selected fields does not provide any conversions."/></div>
</c:when>
<c:otherwise>
<form:hidden path="showAdvancedConversions" id="showAdvancedConversions"/>
<script type="text/javascript">
function advancedConversionsChange() {
	var $el = $("#showAdvancedConversions");
	var value = $el.val();
	value = (value == 'true' ? 'false' : 'true');
	$el.val(value);
}
</script>

<spring:message var="advancedConversionsLabel" code="issue.import.advanced.conversions" />
<ui:collapsingBorder open="${importForm.showAdvancedConversions}" onChange="advancedConversionsChange" label="${advancedConversionsLabel}">
	<c:forEach var="conversionConfig" items="${importForm.conversions}" varStatus="status">
		<c:set var="field" value="${conversionConfig.field}" />
		<div class="conversionConfigurationBlock">
			<p>
			<c:set var="fieldLabels" value="${importForm.getFieldLabels(field)}" />
			<c:set var="descr"><c:out value="${fieldLabels}"/></c:set>
			<spring:message code="issue.import.advanced.conversion.field.label" arguments="${conversionConfig.column},${descr}"
					text="Column #<b>${conversionConfig.column}</b> is mapped to <b>${descr}</b> field, using conversion:"
			/>
			<spring:message var="conversionSelectTitle" code="issue.import.advanced.conversion.choose.title" text="Choose how to convert the values"/>
			<form:select cssClass="conversionSelect" path="conversions[${status.index}].selectedConversionId" title="${conversionSelectTitle}">
				<form:option value="" label="--"/>
				<%-- show the select block to select which conversion will be applied --%>
				<c:forEach var="conversion" items="${field.availableImportValueConverters}">
					<spring:message var="conversionLabel" code="issue.import.advanced.conversion.${conversion.id}.label" text="${conversion.id}" />
					<form:option value="${conversion.id}" label="${conversionLabel}"/>
				</c:forEach>
			</form:select>
			</p>

			<c:forEach var="conversion" items="${conversionConfig.availableImportValueConverters}" varStatus="availabelConverters_status">
				<fieldset class="oneConversionBlock" conversionId="${conversion.id}">
					<spring:message var="conversionLabel" code="issue.import.advanced.conversion.${conversion.id}.label" text="${conversion.id}" />
					<legend><spring:message code="issue.import.advanced.conversion" text="Conversion"/>: ${conversionLabel}</legend>
					<c:set var="converter" value="${conversion}" scope="request"/>
					<spring:nestedPath path="conversions[${status.index}].availableImportValueConverters[${availabelConverters_status.index}]">
						<jsp:include page="${conversion.configurationJSP}"/>
					</spring:nestedPath>
					<c:remove var="converter" />
				</fieldset>
			</c:forEach>
		</div>
	</c:forEach>
</ui:collapsingBorder>
</c:otherwise>
</c:choose>

</div>

</form:form>
