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
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<meta name="decorator" content="popup"/>
<meta name="moduleCSSClass" content="newskin reviewModule"/>
<meta name="module" content="review"/>

<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/review/review.less' />" type="text/css" media="all" />
<script src="<ui:urlversioned value='/js/itemLinking.js' />"></script>

<ui:actionMenuBar>
	<spring:message code="review.merge.title" text="Merge"/>
</ui:actionMenuBar>

<ui:actionBar>
	<c:if test="${not empty approvedItems and not noTargetTracker }">
		<spring:message code="review.complete.merge.label" text="Merge" var="mergeLabel"></spring:message>
		<input type="button" class="button merge-action" value="${mergeLabel }"/>
	</c:if>
</ui:actionBar>


<div class="contentWithMargins">

	<div>
		<div id="field-mapping">

		</div>

		<c:if test="${empty approvedItems }">
			<div class="information">
				<spring:message code="review.merge.no.items.to.merge.message" text="There are no items to merge"/>
			</div>
		</c:if>

		<c:if test="${noTargetTracker }">
			<div class="error">
				<spring:message code="review.merge.no.target.error" text="You have no permission to access the target tracker"/>

			</div>
		</c:if>

		<c:if test="${not empty approvedItems and not noTargetTracker}">
			<!--  <div style="margin-top: 15px;">
				<h2><label class="mandatory"><spring:message code="testrun.field.conclusion" text="Conclusion"></spring:message>:</label></h2>-->
				<textarea name="conclusion" rows="5" style="width: 100%; display: none;">${form.comment }</textarea>
			<!--  </div>-->

			<h1><spring:message code="review.progress.item.progress.label" text="Items"/></h1>
			<c:forEach var="item" items="${approvedItems }">
				<div data-id="${item.id }" class="item-box">
					<c:choose>
						<c:when test="${diffsPerItem[item.id] != null }">
							<%-- this item has been already merged to the target tracker so we can display the diff. --%>

							<h2 id="${item.id }"><c:out value="${item.name}"/></h2>
							<%-- set request scope variables for the diff rendering --%>
							<c:set var="diff" value="${diffsPerItem[item.id] }" scope="request"></c:set>
							<c:set var="copy" value="${itemMergePairs[item.id] }" scope="request"></c:set>
							<c:set var="original" value="${item }" scope="request"></c:set>
							<c:set var="editable" value="${true }" scope="request"></c:set>

							<jsp:include page="/diff/diffTable.jsp"></jsp:include>
						</c:when>
						<c:otherwise>
							<%-- this will be the first time that this item will be merged to the target tracker, so there is no diff --%>

							<h2 id="${item.id }"><c:out value="${item.name}"/>
							</h2>
							<div>

								<table class="diffTable" style="margin-left: 15px;">
									<tr>
										<td class="copy value">
											<input type="checkbox" name="copyToTarget" id="copyToTarget${item.id }" value="${item.id }"/>
											<label for="copyToTarget${item.id }" style="margin-left: 10px;">
												<spring:message code="review.complete.merge.copy.to.target.label" text="Copy to Target Tracker"></spring:message>
											</label>
										</td>
									</tr>
								</table>
							</div>
						</c:otherwise>
					</c:choose>
				</div>

			</c:forEach>
		</c:if>

	</div>
</div>

<script type="text/javascript">
	var submit = function () {
		var updatedFields = {};
		var copyToTarget = [];

		var conclusion = $("[name=conclusion]").val();

		var hasUpdatedField = false;
		$('.item-box').each(function () {
			var $box = $(this);

			var fieldIds = [];
			// find all checked apply boxes
			var $checkboxes = $box.find(".applyCheckbox.checked input");
			$checkboxes.each(function () {
				var $checkbox = $(this);
				var fieldId = $checkbox.data('fieldId');
				if (fieldId) {
					fieldIds.push(fieldId);
				}
			});

			var $copyToTarget = $box.find("[name=copyToTarget]");
			if ($copyToTarget.is(":checked")) {
				copyToTarget.push($copyToTarget.val());
			}

			if (fieldIds.length) {
				hasUpdatedField = true;
				updatedFields[$box.data('id') + ""] = fieldIds;
			}
		});

		var fieldMappings = [];
		$('[name=fieldMappings]').each(function () {
			fieldMappings.push(this.value);
		});

		// validate the form
		var errors = [];
		/*if (!conclusion) {
			errors.push(i18n.message('review.merge.conclusion.mandatory.error'));
		}*/

		if (copyToTarget.length == 0 && !hasUpdatedField) {
			errors.push(i18n.message('Please select one more items to merge'));
		}

		if (errors.length) {
			var errorHtml = '<ul>';
			for (var i = 0; i < errors.length; i++) {
				errorHtml += '<li>' + errors[i] + '</li>';
			}
			errorHtml += '</ul>';

			showFancyAlertDialog(errorHtml, 'error');

			return;
		}


		var busyPage = ajaxBusyIndicator.showBusyPage();
		var parameters = {
				'updatedFields': updatedFields,
				'copyToTarget': copyToTarget,
				'reviewId': "${review.id}",
				'fieldMappings': fieldMappings,
				'conclusion': conclusion,
				'baselineSignature': '${command.baselineSignature}'
		};
		$.ajax({
			url: contextPath + '/ajax/review/merge.spr',
			data: JSON.stringify(parameters),
			contentType: 'application/json',
			method: 'POST',
			dataType: 'json'
		}).done(function (data) {
			parent.location.href = contextPath + "${review.urlLink}";
		}).error(function (err) {
			console.log("error", err);
			showOverlayMessage(i18n.message(err.responseText), 5, true);
		}).always(function () {
			busyPage.remove();
		});
	};

	var loadFieldMapping = function () {
		var $fieldMappingBox = $("#field-mapping");
		var destinationTrackerId = "${targetTracker.id}";
		var sourceTrackerId = "${sourceTracker.id }";
		codebeamer.itemLinking.loadFieldMapping($fieldMappingBox, sourceTrackerId, destinationTrackerId, "fieldMappings", false, null,
				"/mergerequest/ajax/getFieldMapping.spr");

	};

	(function ($) {
		if ($('.item-box').size()) {
			loadFieldMapping();
		}

		$('.merge-action').click(submit);
	})(jQuery);

</script>

<script src="<ui:urlversioned value='/js/diff.js' />"></script>
