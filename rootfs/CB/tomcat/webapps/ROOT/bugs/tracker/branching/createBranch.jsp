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

The overlay for creating new tracker branches

--%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>

<meta name="decorator" content="popup"/>
<meta name="moduleCSSClass" content="newskin trackersModule"/>
<meta name="module" content="tracker"/>

<link rel="stylesheet" href="<ui:urlversioned value='/stylesheet/selectorUtils.less' />" type="text/css" media="all" />

<style type="text/css">
	.mock-optgroup label {
		font-weight: bold;
	}

	.mock-optgroup label.ui-state-disabled {
		opacity: 1;
	}

	.mock-optgroup input {
		display: none;
	}

	.ui-widget.ui-widget-content {
		box-shadow: 3px 3px 10px rgba(0, 0, 0, 0.75);
	}

	.no-tracker-permission.ui-multiselect-optgroup  {
		background-color: #fff7eb;
	}

	.ui-widget-header.ui-corner-all.ui-multiselect-header.ui-helper-clearfix {
		display: none;
	}
</style>

<c:choose>
	<c:when test="${hasBranchLicense}">

		<ui:actionMenuBar>
			<c:set var="trackerTitle">
				<c:out value="${tracker.name }" ></c:out>
			</c:set>

			<spring:message code="tracker.branching.create.title" arguments="${trackerTitle }"></spring:message>
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
					<spring:message code="tracker.branching.create.hint"></spring:message><br/><br/>
					<spring:message code="tracker.branching.branch.create.background.hint.singular"></spring:message>
				</div>
				<form:hidden path="trackerId"/>
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

					<c:if test="${not empty baselines and baselines.size() != 0 }">
						<tr>
							<td class="optional">
								<label for="baselineId"><spring:message code="baseline.label" text="Baseline"/>:</label>
							</td>

							<td>
								<form:select path="baselineId" id="baselineId">
									<c:forEach items="${baselines }" var="baseline">
										<form:option value="${empty baseline.baseline ? baseline.id : baseline.baseline.id }" label="${baseline.name }"/>
									</c:forEach>
								</form:select>
								<form:errors path="baselineId" cssClass="invalidfield"></form:errors>
							</td>
						</tr>
					</c:if>

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
							<label for="description">
								<spring:message code="tracker.branching.association.settings.label" text="Branch Permissions"/>:
							</label>
						</td>
						<td>

							<div>
								<form:checkbox path="branchReferenceModel.copyIncomingAssociations" id="copyIncomingAssociations"/>
								<label for="copyIncomingAssociations">
									<spring:message code="tracker.branching.copy.incoming.associations.label" text="Copy incoming Associations"/>
								</label>
							</div>
							<div>
								<form:checkbox path="branchReferenceModel.copyOutgoingAssociations" id="copyOutgoingAssociations"/>
								<label for="copyOutgoingAssociations">
									<spring:message code="tracker.branching.copy.outgoing.associations.label" text="Copy outgoing Associations"/>
								</label>
							</div>
							<div>
								<form:checkbox path="branchReferenceModel.replaceAssociations" id="replaceAssociations"/>
								<label for="replaceAssociations">
									<spring:message code="tracker.branching.replace.associations.label" text="Replace original associations"/>
								</label>
							</div>
						</td>
					</tr>
					<c:if test="${not empty incomingReferenceFields }">
						<tr>
							<td class="optional">
								<label for="description" style="width: 370px;">
									<spring:message code="tracker.branching.branch.incoming.references.label" text="Downstream References to update"/>:
								</label>
							</td>

							<td>
								<div class="hint">
									<spring:message code="tracker.branching.branch.incoming.references.hint"></spring:message>
								</div>
								<c:if test="${!isAdminOnAllReferringTrackers }">
									<div class="warning">
										<spring:message code="tracker.branching.branch.incoming.references.no.admin.warning"/>
									</div>
								</c:if>
								<select name="branchReferenceModel.incomingReferencesToRewriteRaw" multiple="multiple" id="incomingFieldsToUpdate">
									<c:forEach items="${incomingReferenceFields }" var="entry">
										<tag:branchName trackerId="${entry.key.id }" var="trackerName"></tag:branchName>

										<%-- disabled this incoming field if the user has no permission on the project of the referring tracker --%>
										<c:set var="noTrackerPermission" value="${(entry.key.category and projectsWithNoCmdbAdminPermission[entry.key.project] != null)
											or (!entry.key.category and projectsWithNoTrackerAdminPermission[entry.key.project] != null)}"></c:set>

										<optgroup label="${trackerName }" class="${noTrackerPermission ? 'no-tracker-permission' : '' }">
											<c:forEach items="${entry.value }" var="field">
												<spring:message code="tracker.field.${field.label }.label" text="${field.label }"
													var="fieldLabel"></spring:message>

												<option value="${entry.key.id}-${ field.id }" title="${fieldLabel }">
													${fieldLabel }
												</option>
											</c:forEach>
										</optgroup>
									</c:forEach>
								</select>

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
					</c:if>

					<c:if test="${not empty branchesByReferencedTracker }">
						<tr>
							<td class="optional">
								<label for="description" style="width: 370px;">
									<spring:message code="tracker.branching.branch.outgoing.references.label" text="Upstream References to update"/>:
								</label>
							</td>

							<td>
								<div class="hint">
									<spring:message code="tracker.branching.branch.outgoing.references.hint"></spring:message>
								</div>
								<input type="hidden" name="branchReferenceModel.outgoingReferencesToRewriteRaw" id="outgoingReferencesToRewriteRaw"/>
								<select multiple="multiple" id="outgoingFieldsToUpdate">
									<c:forEach items="${outgoingReferenceFields }" var="entry">
										<spring:message code="tracker.field.${entry.key.label }.label" text="${entry.key.label }" var="fieldLabel"></spring:message>

										<optgroup label="${fieldLabel }">
											<c:forEach items="${entry.value }" var="tracker">
												<c:if test="${branchesByReferencedTracker[tracker] != null }">
													<%-- only show this tracker in the option list if it has branches --%>
													<c:set var="trackerName"> <c:out value="${tracker.name }"></c:out></c:set>

													<option title="${trackerName }" disabled="disabled" class="mock-optgroup">
														${trackerName }
													</option>

													<option value="-${tracker.id }-${entry.key.id}" selected="selected" class="branchTracker tracker-${tracker.id}-${entry.key.id}" data-tracker-id="${tracker.id}-${entry.key.id}">
														<spring:message code="tracker.branching.master.label" text="Master"></spring:message>
													</option>
													<c:forEach items="${branchesByReferencedTracker[tracker] }" var="branchNode">
														<c:set var="branchName"> <c:out value="${branchNode.branch.name }"></c:out></c:set>
														<c:set var="level" value="${branchNode.level > 6 ? 6 : branchNode.level }"/>
														<option style="margin-left: 10px;"
															data-tracker-id="${tracker.id}-${entry.key.id}"
															value="${ entry.key.id }-${branchNode.branch.id}" title="${branchName }"
															class="branchTracker level-${level } tracker-${tracker.id}-${entry.key.id}">
															${branchName }
														</option>
													</c:forEach>
												</c:if>
											</c:forEach>
										</optgroup>
									</c:forEach>
								</select>

							</td>
						</tr>
					</c:if>

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
			hideInProgressDialog();
			$("#form").submit(function () {
				$(parent.document).find("#inProgressDialogMarkup img").attr("src", contextPath + "/images/newskin/branch_create_in_progress.gif");
				parent.inProgressDialog.show();
			});

			function cancel() {
				hideInProgressDialog();
				closePopupInline();
			}

			function hideInProgressDialog () {
				try {
					$(parent.document).find("#inProgressDialogMarkup img").attr("src", contextPath + "/images/newskin/baseline_create_in_progress.gif");
					parent.inProgressDialog.destroy();
				} catch (e) {
					console.warn("couldn't destroy dialog");
				}
			}

			function updateAssociationOptionDependencies() {
                $('#replaceAssociations').prop('disabled',
					!$('#copyIncomingAssociations').is(':checked') && !$('#copyOutgoingAssociations').is(':checked'));
            };

			(function ($) {
				var selectOne = function ($list, value, selector) {
					$list.multiselect("widget").find(selector + " :checkbox:checked").each(function() {
						var $this = $(this);
						if ($this.val() != value && $this.is(":checked")) {
							$this.attr("checked", false);
							$this.siblings(".checker").removeClass("checked");
						}
					});
				};

				$('#incomingFieldsToUpdate,#outgoingFieldsToUpdate').multiselect({
					position: {
						my: 'left bottom',
						at: 'left top'
					},
					selectedText: function (numChecked, numTotal, checked) {
						var masterLabel = i18n.message('tracker.branching.master.label');
						var branchNames = $.map(checked, function(a) {
							var text = $(a).next('span').html().trim();
							if (text != masterLabel) {
								return text;
							}

							return null;
						})

						branchNames.remove("");
						return branchNames.length ? branchNames.join(", ") : i18n.message('multiselect.empty.options.label');
					},
					create: function () {
						$(document).on("click", ".ui-multiselect-checkboxes li.branchTracker label", function(event) {
							var $this = $(this);
							var input = $this.find("input");
							var $item = $this.closest("li");
							var $option = $('option[value=' + input.val() + ']'); // the original select option

							var trackerId = $option.data("trackerId");
							selectOne($("#outgoingFieldsToUpdate"), input.val(), ".tracker-" + trackerId);
						});
					}
				});

				$("#form").submit(function () {
					// on submit we need to collect the outgoing references that need to be rewritten
					var ids = [];
					$('#outgoingFieldsToUpdate').multiselect('getChecked').each(function () {
						var value = $(this).val();

						if (!value.startsWith('-')) {
							ids.push(value);
						}
					});

					$('#outgoingReferencesToRewriteRaw').val(ids.join(','));

				});

				$('#copyIncomingAssociations,#copyOutgoingAssociations').change(function () {
				    updateAssociationOptionDependencies();
				});

                updateAssociationOptionDependencies();
			})(jQuery);
		</script>

	</c:when>
	<c:otherwise>
		<div class="warning">
			<spring:message code="tracker.branching.branch.no.license.warning" text="You cannot use this feature because you don't have the <b>Branching</b> license. To read more about this feature visit our <a target=\"_blank\" href=\"https://codebeamer.com/cb/wiki/85612\">Knowledge base</a>."/>
		</div>
	</c:otherwise>
</c:choose>

