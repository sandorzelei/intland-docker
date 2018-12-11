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

The overlay for creating new branches from multiple trackers at the same time

--%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>

<meta name="decorator" content="popup"/>
<meta name="moduleCSSClass" content="newskin trackersModule"/>
<meta name="module" content="tracker"/>

<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/selectorUtils.less' />" type="text/css" media="all" />

<style type="text/css">
	.ui-widget.ui-widget-content {
		box-shadow: 3px 3px 10px rgba(0, 0, 0, 0.75);
	}

	.propertyTable .reportSelectorTag {
		border-bottom: 0px;
		background-color: transparent;
	}

	.reportSelectorTag .reportSelectorTable .filterTd .filterLabel.actionBarIcon {
		display: none;
	}

	.newskin .ui-multiselect-menu.queryConditionSelector {
		max-width: 300px !important;
		min-width: 300px !important;
	}

	.reportSelectorTag button.ui-multiselect.queryConditionSelector.projectAndTrackerSelector {
		max-width: 210px !important;
    	overflow: hidden;
    	text-overflow: ellipsis;
	}


	.newskin .ui-multiselect-menu.queryConditionSelector {
		max-width: 500px !important;
		min-width: 500px !important;
	}
</style>

<c:choose>
	<c:when test="${hasBranchLicense}">

		<ui:actionMenuBar>
			Creating Branch from multiple Trackers
		</ui:actionMenuBar>

		<form:form id="form">
			<ui:actionBar>
				<spring:message code="button.save" text="Save" var="saveLabel"/>
				<spring:message code="button.cancel" text="Cancel" var="cancelLabel"/>
				<form:button class="button">${saveLabel }</form:button>
				<a href="#" class="cancelButton" onclick="cancel(); return true;">${cancelLabel }</a>
			</ui:actionBar>
			<div class="contentWithMargins">
				<div class="hint">
					<spring:message code="tracker.branching.branch.create.background.hint.plural"></spring:message>
				</div>

				<table class="propertyTable fixedWidthForm">
					<tr>
						<td class="mandatory">
							<label for="branchName"><spring:message code="tracker.branching.branch.name.label" text="Name"/>:</label>
						</td>
						<td>
							<div>
								<form:errors path="branchName" cssClass="invalidfield" cssStyle="margin-bottom: 10px; display: inline-block;"/>
							</div>
							<form:input path="branchName" id="branchName"/>
						</td>
					</tr>

					<tr>
						<td class="optional">
							<label for="branchColor"><spring:message code="tracker.field.Color.label" text="Color"/>:</label>
						</td>
						<td>
							<input type="text" name="branchColor" id="branchColor" value="${command.branchColor }" readonly="readonly" style="width: 6em;"/>
							<ui:colorPicker fieldId="branchColor" showClear="${true}" disableReservedColors="${true }"/>
						</td>
					</tr>

					<tr>
						<td class="optional">
							<label for="branchKeyPostfix"><spring:message code="tracker.branching.branchKeyPostfix.label" text="Key postfix"/>:</label>
						</td>
						<td>
							<spring:message code="tracker.branching.branchKeyPostfix.title"
											text="This text will be added to the branch key as a prefix" var="keyPrefixTitle"/>
							<form:input path="branchKeyPostfix" id="branchKeyPostfix" title="${keyPrefixTitle}"/>
						</td>
					</tr>

					<tr>
						<td class="mandatory">
							<label><spring:message code="tracker.branching.trackers.label" text="Trackers"/>:</label>
						</td>
						<td>
							<input type="hidden" name="trackerIds"/>
							<ui:reportSelector hideAndOr="true" showGroupBy="false" showOrderBy="false" mergeToActionBar="false"
								onlyBranchableTrackers="true" autoHeight="true" useSimpleSelectedText="true"></ui:reportSelector>
							<div>
								<form:errors path="trackerIds" cssClass="invalidfield" cssStyle="margin-bottom: 10px; display: inline-block;"/>
							</div>
						</td>
					</tr>

					<tr>
						<td class="optional">
							<label for="description" style="width: 370px;">
								<spring:message code="tracker.branching.branch.permission.label" text="Branch Permissions"/>:
							</label>
						</td>

						<td>
							<c:forEach items="${inheritanceOptions }" var="inheritanceOption">
								<div>
									<label>
										<form:radiobutton path="inheritance" value="${inheritanceOption.name }"/>
										<spring:message code="tracker.branching.branch.permission.${inheritanceOption.name }.label"/>
									</label>
								</div>
							</c:forEach>
						</td>
					</tr>

					<tr>
						<td class="optional">

						</td>
						<td>
							<form:checkbox path="branchReferenceModel.replaceIncomingReferences"/>
							<label for="replaceIncomingReferences" id="replaceIncomingReferences">
								<spring:message code="tracker.branching.replace.incoming.references.label" text="Replace incoming References"/>
							</label>
						</td>
					</tr>

					<tr>
						<td class="optional">
							<label for="description" style="width: 370px;">
								<spring:message code="tracker.branching.branch.description.label" text="Description"/>:
							</label>
						</td>

						<td>
							<form:textarea path="description" cols="60" rows="3"/>
						</td>
					</tr>
				</table>
			</div>
		</form:form>

		<script type="text/javascript">
			function cancel() {
				hideInProgressDialog();
				closePopupInline();
			}

			function hideInProgressDialog () {
				try {
					parent.inProgressDialog.destroy();
				} catch (e) {
					console.warn("couldn't destroy dialog");
				}
			}

			(function ($) {
				hideInProgressDialog();

				$('#form').submit(function () {
					var ids = [];
					$('.trackerSelector').multiselect('getChecked').each(function () { ids.push($(this).val())});
					$('[name=trackerIds]').val(ids.join(','));

					parent.inProgressDialog.show();
				});
			})(jQuery);
		</script>
	</c:when>
	<c:otherwise>
		<div class="warning">
			<spring:message code="tracker.branching.branch.no.license.warning"
				text="You cannot use this feature because you don't have the <b>Branching</b> license. To read more about this feature visit our <a target=\"_blank\" href=\"https://codebeamer.com/cb/wiki/85612\">Knowledge base</a>."/>
		</div>
	</c:otherwise>
</c:choose>