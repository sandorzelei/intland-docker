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
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="uitaglib" prefix="ui" %>

<style type="text/css">

	table.baselines th {
		font-weight: bold !important;
		padding-top: 2px !important;
		padding-bottom: 2px !important;
		background-color: #EEE !important;
	}

	table.baselines tr.baseline td {
		padding-top: 4px !important;
		padding-bottom: 4px !important;
	}

	table.baselines tr.baseline td.status {
		width: 20px;
		background-position: center center;
		background-repeat: no-repeat;
	}

	table.baselines tr.baseline td.status.importable {
		background-image : url("./../images/import.gif");
	}

	table.baselines tr.baseline  td.status.pending {
		background-color : transparent;
		background-image : url("./../images/hourglass.png");
	}

	table.baselines tr.baseline  td.status.running {
		background-image : url("./../images/ajax-running.gif");
	}

	table.baselines tr.baseline  td.status.imported {
		background-image : url("./../images/accept.png");
	}

	table.baselines tr.baseline  td.status.failed {
		background-image : url("./../images/icon_reject.png");
	}

	table.baselines tr.baseline  td.status.skipped {
		background-image : url("./../images/choice-cancel.gif");
	}


</style>

<script type="text/javascript" src="<ui:urlversioned value='/bugs/includes/doorsBridge.js'/>"></script>
<script type="text/javascript">

	var doorsPreviewDialogConfig = {
		label		: '<spring:message code="doors.bridge.module.preview.label"   text="Preview..." javaScriptEscape="true"/>',
		tooltip		: '<spring:message code="doors.bridge.module.preview.tooltip" text="Show a preview of the first 50 items in the selected DOORS module (without OLEs and pictures)" javaScriptEscape="true"/>',
		title		: '<spring:message code="doors.bridge.module.preview.title"   text="Preview of first {0} items in {1}" arguments="XXX,YYY" javaScriptEscape="true"/>',
		loading		: '<spring:message code="doors.bridge.module.preview.loading" text="Loading the preview can take several seconds. Please wait ..." javaScriptEscape="true"/>',
		previewURL 	: '<c:url value="/ajax/doors/preview.spr"/>',
		length		: 50
	};

	var doorsModuleSelectorConfig = {
		label		: '<spring:message code="doors.bridge.module.selector.label"  text="Select..." javaScriptEscape="true"/>',
		title		: '<spring:message code="doors.bridge.module.selector.title"  text="Please select the DOORS module to import" javaScriptEscape="true" />',

		hierarchy	: {
			url		: '<c:url value="/ajax/doors/hierarchy.spr"/>',
			loading	: '<spring:message code="doors.bridge.module.tree.loading" 	  text="Loading folder tree, Please wait..." javaScriptEscape="true" />'
		},

		validation	: {
			url		: '<c:url value="/ajax/doors/mapping.spr"/>',
			error 	: '<spring:message code="doors.bridge.module.associated.with" text="The DOORS module {0} is already associated with tracker {1} in project {2}" arguments="XXX,YYY,ZZZ" javaScriptEscape="true"/>'
		},

		preview		: doorsPreviewDialogConfig,

		submitText  : '<spring:message code="button.ok" 	text="OK" 	  javaScriptEscape="true"/>',
		cancelText 	: '<spring:message code="button.cancel" text="Cancel" javaScriptEscape="true"/>'
	};

	var doorsSettingsEditorConfig = $.extend(true, {}, remoteImportSettingsConfig, {
		informationMessage : '<spring:message code="doors.bridge.settings.info.message" text="DOORS Bridge must be installed onto the Target System. Please find more details about the installation processes using the <a target=\"_blank\" href=\"https://codebeamer.com/cb/wiki/2411231\">following link</a>" javaScriptEscape="true"/>',

		help		: {
			title	: '"codeBeamer DOORS Bridge" in codeBeamer Knowledge Base',
			URL		: 'https://codebeamer.com/cb/wiki/2411231'
		},

		server		: {
			title  	: '<spring:message code="doors.bridge.server.tooltip" text="The address/URL of the codeBeamer DOORS Bridge server" javaScriptEscape="true"/>',
			test	: {
				label	: '<spring:message code="doors.bridge.server.test.label"   text="Test" javaScriptEscape="true"/>',
				title	: '<spring:message code="doors.bridge.server.test.tooltip" text="Test, if there is a DOORS Bridge Server, at the entered URL (web address)" javaScriptEscape="true"/>',
				success : '<spring:message code="doors.bridge.server.test.success" text="Server test was successful" javaScriptEscape="true"/>',
				failed  : '<spring:message code="doors.bridge.server.test.failed"  text="Server test failed: Did not find a DOORS Bridge Server, at the entered URL (web address) !" javaScriptEscape="true"/>'
			}
		},

		module		: {
			label	: '<spring:message code="doors.bridge.module.label"   text="Module" javaScriptEscape="true"/>',
			title	: '<spring:message code="doors.bridge.module.tooltip" text="The DOORS formal module to import" javaScriptEscape="true"/>',
			selector: doorsModuleSelectorConfig
		},

		"import"	: {
			label	: '<spring:message code="doors.bridge.module.import.label"   text="Import" javaScriptEscape="true"/>',
			title	: '<spring:message code="doors.bridge.module.import.tooltip" text="Options for the import from the selected DOORS Module" javaScriptEscape="true"/>'
		},

		reliable	: {
			label	: '<spring:message code="doors.bridge.history.reliable.label"   text="Reliable" javaScriptEscape="true"/>',
			title	: '<spring:message code="doors.bridge.history.reliable.tooltip" text="Is the history of the selected DOORS module reliable ?" javaScriptEscape="true"/>'
		},

		metaData	: {
			url		: '<c:url value="/ajax/doors/metaData.spr"/>',
			loading	: '<spring:message code="doors.bridge.module.metaData.loading" text="Loading module meta data, please wait..." javaScriptEscape="true"/>'
		},

		references	: {
			label	: '<spring:message code="doors.bridge.references.label"	  text="References" javaScriptEscape="true"/>',
			title	: '<spring:message code="doors.bridge.references.tooltip" text="How to handle specific DOORS object references" javaScriptEscape="true"/>'
		},

		users		: {
			label	: '<spring:message code="doors.bridge.users.label"	 text="Users" javaScriptEscape="true"/>',
			title	: '<spring:message code="doors.bridge.users.tooltip" text="Whether DOORS users referenced by requirements, should be imported as CodeBeamer users, or should be simply referenced by name" javaScriptEscape="true"/>'
		},

		attributes	: {
			label	: '<spring:message code="doors.bridge.attributes.label"   	 text="Attributes" javaScriptEscape="true"/>',
			title	: '<spring:message code="doors.bridge.attributes.tooltip" 	 text="The importable attributes of the selected DOORS formal module" javaScriptEscape="true"/>',
			none	: '<spring:message code="doors.bridge.attributes.none"    	 text="There are no importable attributes of the selected DOORS formal module" javaScriptEscape="true"/>',
			dxl 	: {
				image : '<c:url value="/images/warn.gif"/>',
				label : '<spring:message code="doors.bridge.attribute.dxl.label"   text="DXL" javaScriptEscape="true"/>',
				title : '<spring:message code="doors.bridge.attribute.dxl.tooltip" text="The value of this attribute is computed via DXL" javaScriptEscape="true"/>',
			}
		},

		linkTypes	: {
			label	: '<spring:message code="doors.bridge.links.label"   text="Link Types" javaScriptEscape="true"/>',
			title	: '<spring:message code="doors.bridge.links.tooltip" text="The importable link types of the selected DOORS formal module" javaScriptEscape="true"/>',
			none	: '<spring:message code="doors.bridge.links.none"    text="There are no importable link types of the selected DOORS formal module" javaScriptEscape="true"/>',
		}
	});


	var doorsSettingsDialogConfig = $.extend({}, remoteImportSettingsDialog, {
		label		: '<spring:message code="doors.bridge.settings.label" 	text="Settings..." javaScriptEscape="true" />',
		title		: '<spring:message code="doors.bridge.settings.title" 	text="DOORS Bridge Settings" javaScriptEscape="true" />',
		loading		: '<spring:message code="doors.bridge.settings.loading"	text="Loading settings, please wait ..." javaScriptEscape="true" />',
		settingsURL	: '<c:url value="/ajax/doors/settings.spr"/>',
		remove		: {
			label	: '<spring:message code="doors.bridge.settings.remove.label" 	text="Remove..." javaScriptEscape="true" />',
			confirm : '<spring:message code="doors.bridge.settings.remove.confirm" 	text="Do you really want to irreversible remove the DOORS Bridge Settings of this tracker ?" javaScriptEscape="true" />'
		}
	});


	var doorsImportStatisticsConfig = $.extend(true, {}, remoteImportStatisticsConfig, {
		nothing 	: '<spring:message code="doors.bridge.tracker.import.nothing" text="The import has finished successfully, but there was no new data to import" javaScriptEscape="true" />',

		objects		: remoteImportStatisticsConfig.items,

		history	  	: {
			label	: '<spring:message code="doors.bridge.history.label"	text="History" javaScriptEscape="true"/>',
			title	: '<spring:message code="doors.bridge.history.imported" text="The number of DOORS object history entries, that were imported to CodeBeamer" javaScriptEscape="true"/>'
		},

		links		: {
			label	: '<spring:message code="doors.bridge.links.label"	  text="Links" javaScriptEscape="true"/>',
			title	: '<spring:message code="doors.bridge.links.imported" text="The number of DOORS object links, that were imported, updated or deleted in CodeBeamer" javaScriptEscape="true"/>'
		},

		discussions	: {
			label	: '<spring:message code="doors.bridge.discussions.label"	text="Discussions" javaScriptEscape="true"/>',
			title	: '<spring:message code="doors.bridge.discussions.imported" text="The number of DOORS object discussions, that were imported, updated or deleted in CodeBeamer" javaScriptEscape="true"/>'
		},

		comments	: {
			label	: '<spring:message code="doors.bridge.comments.label"	 text="Comments" javaScriptEscape="true"/>',
			title	: '<spring:message code="doors.bridge.comments.imported" text="The number of DOORS object comments, that were imported, updated or deleted in CodeBeamer" javaScriptEscape="true"/>'
		},

		attachments	: {
			label	: '<spring:message code="doors.bridge.attachments.label"	text="Attachments" javaScriptEscape="true"/>',
			title	: '<spring:message code="doors.bridge.attachments.imported" text="The number of DOORS OLE objects and pictures, that were imported, updated or deleted in CodeBeamer" javaScriptEscape="true"/>'
		},

		baselines  	: {
			label	: '<spring:message code="doors.bridge.baselines.label"	 text="Baselines" javaScriptEscape="true"/>',
			title	: '<spring:message code="doors.bridge.baselines.tooltip" text="The importable baselines of the selected DOORS formal module" javaScriptEscape="true"/>'
		}
	});


	var doorsImportHistoryDialog = $.extend(true, {}, remoteImportHistoryDialog, {
		label		: '<spring:message code="doors.bridge.tracker.import.history.label"    text="History ..." javaScriptEscape="true"/>',
		title		: '<spring:message code="doors.bridge.tracker.import.history.title"    text="DOORS Import History" javaScriptEscape="true"/>',
		loading		: '<spring:message code="doors.bridge.tracker.import.history.loading"  text="Loading DOORS Import History ..." javaScriptEscape="true"/>',
		historyURL 	: '<c:url value="/ajax/doors/import/history.spr"/>',
		baselineLabel: '<spring:message code="doors.bridge.baseline.label"   text="Baseline" javaScriptEscape="true"/>'
	});


	var doorsImportConfig = {
		module		: {
			label	: '<spring:message code="doors.bridge.module.label"     text="Module" javaScriptEscape="true"/>',
			title	: '<spring:message code="doors.bridge.module.tooltip"   text="The DOORS formal module to import" javaScriptEscape="true"/>',
			preview	: doorsPreviewDialogConfig
		},

		baselines 	: {
			label 		: '<spring:message code="doors.bridge.baselines.label"   text="Baselines" javaScriptEscape="true"/>',
			title 		: '<spring:message code="doors.bridge.baselines.tooltip" text="The importable baselines of the selected DOORS formal module" javaScriptEscape="true"/>',
			toggleAll	: '<spring:message code="doors.bridge.baseline.toggleAll" text="(De-)Select all importable baselines" javaScriptEscape="true"/>'
		},

		baseline 	: {
			multiple	: true,
			label 		: '<spring:message code="doors.bridge.baseline.label"   text="Baseline" javaScriptEscape="true"/>',
			title 		: '<spring:message code="doors.bridge.baseline.tooltip" text="The importable baselines of the selected DOORS formal module" javaScriptEscape="true"/>',
			toggleThis 	: '<spring:message code="doors.bridge.baseline.select"  text="(De-)Select this baseline for import" javaScriptEscape="true"/>',

			createdAt	: {
				label	: '<spring:message code="doors.bridge.baseline.createdAt.label"   text="Created at" javaScriptEscape="true"/>',
				title	: '<spring:message code="doors.bridge.baseline.createdAt.tooltip" text="The date and time of baseline creation" javaScriptEscape="true"/>',
				now     : '<spring:message code="Now"  text="Now" javaScriptEscape="true"/>'
			},

			createdBy	: {
				label	: '<spring:message code="doors.bridge.baseline.createdBy.label"   text="Created by" javaScriptEscape="true"/>',
				title	: '<spring:message code="doors.bridge.baseline.createdBy.tooltip" text="The name of the DOORS user, that created this baseline" javaScriptEscape="true"/>',
			},

			status		: {
				label	: '<spring:message code="doors.bridge.baseline.status.label"   text="Status" javaScriptEscape="true"/>',
				title	: '<spring:message code="doors.bridge.baseline.status.tooltip" text="The import status of this baseline" javaScriptEscape="true"/>',

				importable	: {
					label	: '<spring:message code="doors.bridge.baseline.status.importable.label"   text="Importable" javaScriptEscape="true"/>',
					title	: '<spring:message code="doors.bridge.baseline.status.importable.tooltip" text="This baseline can be imported" javaScriptEscape="true"/>'
				},

				imported	: {
					label	: '<spring:message code="doors.bridge.baseline.status.imported.label"   text="Imported" javaScriptEscape="true"/>',
					title	: '<spring:message code="doors.bridge.baseline.status.imported.tooltip" text="This baseline was already imported" javaScriptEscape="true"/>'
				},

				failed		: {
					label	: '<spring:message code="doors.bridge.baseline.status.failed.label"   text="Failed" javaScriptEscape="true"/>',
					title	: '<spring:message code="doors.bridge.baseline.status.failed.tooltip" text="Importing this baseline failed" javaScriptEscape="true"/>'
				},

				skipped		: {
					label	: '<spring:message code="doors.bridge.baseline.status.skipped.label"   text="Skipped" javaScriptEscape="true"/>',
					title	: '<spring:message code="doors.bridge.baseline.status.skipped.tooltip" text="This baseline was skipped" javaScriptEscape="true"/>'
				}
			},

			none  	: {
				label : '<spring:message code="doors.bridge.baseline.none.label"   text="None" javaScriptEscape="true"/>',
				title : '<spring:message code="doors.bridge.baseline.none.tooltip" text="Do not import a baseline, but the head revision" javaScriptEscape="true"/>'
			},
			last  	: {
				label : '<spring:message code="doors.bridge.baseline.last.label"   text="Last" javaScriptEscape="true"/>',
				title : '<spring:message code="doors.bridge.baseline.last.tooltip" text="Import the most recent baseline" javaScriptEscape="true"/>'
			},
			head    : {
				label : '<spring:message code="doors.bridge.baseline.head.label"   text="Current (head) revision" javaScriptEscape="true"/>',
				title : '<spring:message code="doors.bridge.baseline.head.tooltip" text="The current (head) revision of the module" javaScriptEscape="true"/>'
			},
			mirror	: {
				label : '<spring:message code="doors.bridge.baseline.mirror.label"   text="Mirror" javaScriptEscape="true"/>',
				title : '<spring:message code="doors.bridge.baseline.mirror.tooltip" text="Also create an appropriate CodeBeamer baseline, that mirrors the imported DOORS baseline" javaScriptEscape="true"/>'
			}
		},

		history : {
			config 	 : doorsImportStatisticsConfig,
			dialog 	 : doorsImportHistoryDialog,
			settings : {
				config : $.extend({}, doorsSettingsEditorConfig, {
					editable : false
				}),
				dialog : doorsSettingsDialogConfig
			}
		},

		lastModified : {
			label 	: '<spring:message code="doors.bridge.module.lastModified.label"   text="Last Modification" javaScriptEscape="true"/>',
			title 	: '<spring:message code="doors.bridge.module.lastModified.tooltip" text="Date, time and user, that made the last modification of the DOORS module" javaScriptEscape="true"/>',
		},

		lastImport	: {
			label 	: '<spring:message code="doors.bridge.tracker.import.last.label"   text="Last Import" javaScriptEscape="true"/>',
			title 	: '<spring:message code="doors.bridge.tracker.import.last.tooltip" text="Date, time and baseline of the last import from the associated DOORS module" javaScriptEscape="true"/>',
			never	: '<spring:message code="doors.bridge.tracker.import.last.none"    text="Never" javaScriptEscape="true"/>'
		},

		nextImport	: {
			label 	: '<spring:message code="doors.bridge.tracker.import.next.label"   text="Next Import" javaScriptEscape="true"/>',
			title 	: '<spring:message code="doors.bridge.tracker.import.next.tooltip" text="Date and time of the next scheduled import from the associated DOORS module" javaScriptEscape="true"/>',
			none	: '<spring:message code="doors.bridge.tracker.import.next.none"    text="Not scheduled" javaScriptEscape="true"/>',
			disabled: '<spring:message code="doors.bridge.tracker.import.next.disabled" text="Disabled" javaScriptEscape="true"/>'
		}
	};

	var doorsImportDialogConfig = {
		importURL		: '<c:url value="/ajax/doors/import.spr"/>',
		title			: '<spring:message code="doors.bridge.tracker.import.label" 	text="Import from DOORS" javaScriptEscape="true" />',
		loading			: '<spring:message code="doors.bridge.tracker.import.loading" 	text="Loading information about the DOORS Module to import ..." javaScriptEscape="true" />',
		disabled		: '<spring:message code="doors.bridge.tracker.import.disabled" 	text="Importing from IBM Rational DOORS has been disabled for this tracker!" javaScriptEscape="true" />',
		running			: '<spring:message code="doors.bridge.tracker.import.running"	text="Importing {0} from IBM Rational DOORS ..." arguments="XXX" javaScriptEscape="true" />',
		importSuccess   : '<spring:message code="doors.bridge.tracker.import.success" 	text="All selected module baselines were imported successfully. To see the import statistics of a baseline, click on that baseline." javaScriptEscape="true" />',
		confirmCancel	: '<spring:message code="doors.bridge.tracker.import.cancel.confirm" text="Do you really want to cancel the running import ?" javaScriptEscape="true" />',
		continueLabel	: '<spring:message code="button.continue" 	text="Continue" javaScriptEscape="true" />',

		settings		: {
			none		: '<spring:message code="doors.bridge.settings.none" 		text="This tracker has not been configured for an Import from DOORS yet!" javaScriptEscape="true" />',
			confirm		: '<spring:message code="doors.bridge.settings.confirm" 	text="No DOORS formal module has been associated with this tracker yet. Do you want to configure one now ?" javaScriptEscape="true" />',
			config  	: doorsSettingsEditorConfig,
			dialog  	: doorsSettingsDialogConfig
		},

		result			: doorsImportStatisticsConfig,

		statistics		: {
			hint		: '<spring:message code="doors.bridge.baseline.import.statistics.label" text="Click here, to show statistics about the import of this baseline" javaScriptEscape="true"/>',
			config		: doorsImportStatisticsConfig,
			dialog		: {
				title 	: '<spring:message code="doors.bridge.baseline.import.statistics.title" text="Import of Baseline {0} of Module {1}" arguments="XXX,YYY" javaScriptEscape="true"/>'
			}
		}
	};


	function importFromDOORS(trackerId) {
		var popup = $('#DoorsImportPopup');
		if (popup.length == 0) {
			popup = $('<div>', { id : 'DoorsImportPopup', "class" : 'editorPopup', style : 'display: None;' });
			$(document.documentElement).append(popup);
		} else {
			popup.empty();
		}

		popup.showDoorsImportDialog(trackerId, doorsImportConfig, doorsImportDialogConfig);

		return false;
	}

</script>