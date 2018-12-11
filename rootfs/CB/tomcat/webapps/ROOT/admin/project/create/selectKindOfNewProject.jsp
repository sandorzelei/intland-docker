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
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<%@ taglib uri="uitaglib" prefix="ui" %>

<meta name="decorator" content="main"/>
<meta name="module" content="project_browser"/>
<meta name="moduleCSSClass" content="projectModule newskin"/>

<style type="text/css">
	div.selection {
		margin-bottom: 15px;
		clear: both;
	}
	div.disabled * {
		color: #777;
	}

	input[type="radio"] {
		margin-left: -22px;
		vertical-align: text-top;
	}

	select {
		min-width: 150px;
	}

	h3 {
		display: inline;
	}

	#projectTemplateFileSelector {
		margin-bottom: 5px;
	}

	.jiraConnectStatus {
		margin-bottom: 7px;
	}

	.jiraConnectStatus .infoMessages > div {
		margin: 0;
	}

	.connectionInProgress {
		display: inline-block;
		width: 12px;
		height: 11px;
		background: url('images/ajax-loading_16.gif') no-repeat;
		visibility: hidden;
	}

	.connectionInProgress.loading {
		visibility: visible;
	}

	.explanation .new {
		display: inline-block;
		background-color: #CCF4FF;
		padding: 0.2em 0.5em;
		margin-left: 0.5em;
		color: black;
	}

</style>


<ui:actionMenuBar>
	<ui:pageTitle>
		<spring:message code="project.creation.title" text="Create New Project"/>
		<spring:message code="project.creation.kind.breadcrumb" />
	</ui:pageTitle>
</ui:actionMenuBar>

<form:form commandName="createProjectForm" action="${flowUrl}">

	<ui:actionBar>
		<spring:message var="nextButton" code="button.goOn" text="Next &gt;"/>
		&nbsp;&nbsp;<input type="submit" class="button" name="_eventId_submit" value="${nextButton}" />

		<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>
		<input type="submit" class="cancelButton" name="_eventId_cancel" value="${cancelButton}" />
	</ui:actionBar>

	<div class="contentWithMargins" style="width: 50em; margin-left: 50px;">
		<form:errors cssClass="error"/>

		<c:set var="kindOfNewProjectsAvailable" value="${createProjectForm.kindOfNewProjectsAvailable}" />

		<div class="selection">
			<label for="newProject">
				<form:radiobutton path="kindOfNewProject" value="clean" id="newProject" />
				<h3><spring:message code="project.creation.kind.clean.label" /></h3>
			</label>

			<p class="explanation">
				<spring:message code="project.creation.kind.template.explanation" />
			</p>

			<p>
				<spring:message code="project.creation.template.title" text="Project Template"/>:
				<form:select id="templateProjectSelector" path="templateProjId">
					<form:option value="-1"><spring:message code="project.Default.label" text="Default"/></form:option>

					<c:forEach items="${createProjectForm.templateProjects}" var="templateProj">
						<c:set var="templateTitle">
							<c:out value="${fn:substring(templateProj.description, 0, 80)}" escapeXml="true"/>
						</c:set>
						<form:option value="${templateProj.id}" title="${templateTitle}"><c:out value="${templateProj.name}" /></form:option>
					</c:forEach>
				</form:select>
			</p>
			<form:errors path="templateProjId" cssClass="invalidfield"/>

			<p class="explanation">
				<spring:message code="project.template.import.description" />
			</p>

			<div id="projectTemplateFileSelector">
				<ui:fileUpload single="true" submitFormOnComplete="true" uploadConversationId="${createProjectForm.templateUploadConversationId}" />
			</div>
		</div>

		<c:if var="hasDataPacks" test="${! empty kindOfNewProjectsAvailable['demo']}" >
			<div class="selection">
				<label for="demoProject">
					<form:radiobutton path="kindOfNewProject" value="demo" id="demoProject" />
					<h3><spring:message code="project.creation.kind.demo.label" /></h3>
				</label>

				<p class="explanation">
					<spring:message code="project.creation.kind.demo.explanation" />
				</p>

				<p>
					<spring:message code="project.smart.template.select.label" text="Template" />:
					<form:select path="demoDataPack" disabled="${!hasDataPacks}" >
						<c:forEach items="${createProjectForm.demoDataPackNames}" var="demoDataPackName">
							<form:option value="${demoDataPackName}"><c:out value="${demoDataPackName}" /></form:option>
						</c:forEach>
					</form:select>
				</p>
			</div>
		</c:if>
	</div>



<script type="text/javascript">
	var RADIOBUTTONS = "input[name='kindOfNewProject']";
	function disableSelectboxesForUncheckedSelections() {
		var $radiobuttons = $(RADIOBUTTONS);
		$radiobuttons.each(function() {
			var selected = $(this).is(":checked");
			var $selects = $(this).closest(".selection").find("select");

			$selects.each(function(){
				var disabled =$(this).is(":disabled");
				if (!disabled) {
					// remember that this select box was enabled once, so can be enabled again
					$(this).attr("canBeEnabled", "true");
				}
				var enable = selected && $(this).attr("canBeEnabled") == 'true';
				$(this).attr("disabled", enable ? null : "true");
			});
		});
	}

	function toggleJiraImport() {
		var jiraSection = $('#remoteServer');
		var show = $('#jiraImport').is(":checked");
		jiraSection.toggle(show);
		if (show && jiraSection.find(":focus").length == 0) {
			$('#jiraServer').focus();
		}
	}

	jQuery(function($) {

		var sizeLimitInByte = ${createProjectForm.confirmDialogFileSizeLimit} * 1024 * 1024;

		var createProjectForm = $("#createProjectForm");
		createProjectForm.find('input[name="_eventId_submit"]').click(function() {
			var fileList = createProjectForm.find('ul.qq-upload-list').first();
			var files = fileList.find('li.qq-upload-success');
			var totalSize = 0;
			files.each(function() {
				totalSize += $(this).find('.qq-upload-size').data('size');
			});
			if (createProjectForm.find('input#uploadedTemplate').is(':checked') && files.length > 0 && totalSize >= sizeLimitInByte) {
				return showFancyConfirmDialog(this, i18n.message("project.create.from.template.confirm"));
			}
			return true;
		});

		disableSelectboxesForUncheckedSelections();

		(function setupRadioButtons() {
			var radioButtonSelector = "input[type=radio][name=kindOfNewProject]";

			var afterSelectionChanged = function() {
				disableSelectboxesForUncheckedSelections();
				toggleJiraImport();
			};

			$(radioButtonSelector).not(":disabled").click(function(event) {
				afterSelectionChanged();
				event.stopPropagation();
			});

			$(".selection").click(function(event) {
				$(this).find(radioButtonSelector).not(":disabled").prop("checked", true);
				afterSelectionChanged();
				return event.target != this;
			});
		})();

		$('#templateProjectSelector').change(function() {
			$('#newProject').val(this.value == '-1' ? 'clean' : 'template');
		}).change();

		$('#jiraImport').click(toggleJiraImport);

		$("#jiraServer,#jiraUsername,#jiraPassword").change(function() {
			$(".dependsOnValidJiraConnection").hide();
			$("#jiraProjectSelector").get(0).selectedIndex = -1;
		});

		$("#jiraProjectsReload").click(function() {
			var button = $(this);
			var loadIndicator = button.siblings(".connectionInProgress");
			button.prop("disabled", true);
			loadIndicator.addClass("loading");

			var projectSelector = $("#jiraProjectSelector");

			var connection = {
				server   : $('#jiraServer').val(),
				username : $('#jiraUsername').val(),
				password : $('#jiraPassword').val()
			};

			var cloneNextButton = function() { // for better usability
				if ($(".jiraNextButtonRow").length == 0) {
					var button = $("#createProjectForm").find(".actionBar input[type=submit].button");
					var newButton = button.clone();
					var lastRow = $("#remoteServer").find("tr").last();
					newButton.click(function() {
						button.click();
						return false;
					});
					var secondCell = $("<td>").append(newButton);
					var firstCell = $("<td>");
					var newRow = $("<tr>").addClass("dependsOnValidJiraConnection jiraNextButtonRow").append(firstCell).append(secondCell);
					newRow.insertAfter(lastRow);
				}
			};

			var jiraConnectStatus = $(".jiraConnectStatus");
			jiraConnectStatus.empty();

			$.ajax('<c:url value="/ajax/jira/projects.spr"/>', {
				type  		: 'POST',
				contentType : 'application/json',
				dataType 	: 'json',
				data 		: JSON.stringify(connection)
			}).done(function(projects) {
				$('option', projectSelector).remove();
	            $.each(projects, function(i, project) {
					projectSelector.append($("<option>", {
						value : escapeHtml(project.keyName),
						selected: i == 0
					}).text(project.name));
	            });
				var message = createInfoMessageBox(i18n.message("project.creation.kind.jira.connection.success"), "information");
				jiraConnectStatus.html(message);
				cloneNextButton();
				$(".dependsOnValidJiraConnection").show();
				projectSelector.focus();
			}).fail(function(data) {
				$(".jiraNextButtonRow").remove();
				$(".dependsOnValidJiraConnection").hide();
				var returnedErrorMessage;
				try {
					var response = $.parseJSON(data.responseText);
					returnedErrorMessage = " " + response["message"];
				} catch (ex) {
					returnedErrorMessage = "";
				}
				var errorMessage = i18n.message("project.creation.kind.jira.connection.failed") + returnedErrorMessage;
				var message = createInfoMessageBox(errorMessage, "error");
				jiraConnectStatus.html(message);
			}).always(function() {
				button.prop("disabled", false);
				loadIndicator.removeClass("loading");
			});

			return false;
		});

		var templateSelector = $("#demoDataPack");
		var uploader = $("#uploadConversationId_dropZone");

		var layoutFix = function() {
			uploader.find(".qq-upload-list").addClass("qq-upload-list-has-files"); // layout fix
		};

		var addFileUploadChangeHandler = function() {
			uploader.find(".qq-upload-button input").click(function() {
				// if a file is selected, template should be set to none
				templateSelector.find('option:first').prop('selected', true);
				return true;
			});
		};

		layoutFix();
		setTimeout(function() {
			layoutFix(); // again, for IE8
			addFileUploadChangeHandler();
		}, 500);


		templateSelector.change(function() {
			if (templateSelector.val() != "--") {
				// remove all selected files
				uploader.find(".qq-upload-remove").each(function() {
					this.click(); // deliberately using native click method because jQuery can only trigger click events that are attached by itself
				});
				// valums file uploader removes event handler on click, so always re-add it
				addFileUploadChangeHandler();
			}
		});

	});

</script>

</form:form>
