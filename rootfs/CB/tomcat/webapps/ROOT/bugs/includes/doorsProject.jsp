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

	table.baselineSets th, table.modules th {
		font-weight: bold !important;
		padding-top: 2px !important;
		padding-bottom: 2px !important;
		background-color: #EEE !important;
	}

	table.baselineSets tr td {
		padding-top: 4px !important;
		padding-bottom: 4px !important;
	}

	table.baselineSets td.coverage.none a {
		color: red !important;
	}

	table.baselineSets td.coverage.part a {
		color: orange !important;
	}

	table.baselineSets td.coverage.full a {
		color: green !important;
	}

	table.baselineSets td.status {
		width: 20px;
		background-position: center center;
		background-repeat: no-repeat;
	}

	table.baselineSets td.status.importable {
		background-image : url("./../images/import.gif");
	}

	table.baselineSets td.status.imported {
		background-image : url("./../images/accept.png");
	}

	table.baselineSets td.status.blocked {
		background-image : url("./../images/icon_reject.png");
	}

	table.baselineSets td.status.pending {
		background-color : transparent;
		background-image : url("./../images/hourglass.png");
	}

	table.baselineSets td.status.running {
		background-image : url("./../images/ajax-running.gif");
	}

	table.baselineSets td.status.failed {
		background-image : url("./../images/icon_reject.png");
	}

	table.baselineSets td.status.skipped {
		background-image : url("./../images/choice-cancel.gif");
	}

	table.modules tr.module td {
		padding-top: 4px !important;
		padding-bottom: 4px !important;
	}

	div.progressBar {
		width  : 96%;
		height : 1em;
		margin : 2px 15px 4px 15px;
	}


</style>

<script type="text/javascript" src="<ui:urlversioned value='/bugs/includes/doorsProject.js'/>"></script>
<script type="text/javascript">

var doorsFolderSelectorConfig = {
	label		: '<spring:message code="doors.bridge.folder.selector.label"  text="Select..." javaScriptEscape="true"/>',
	title		: '<spring:message code="doors.bridge.folder.selector.title"  text="Please select the DOORS project/folder, whose baseline sets to import" javaScriptEscape="true" />',

	hierarchy	: {
		url		: '<c:url value="/ajax/doors/hierarchy.spr"/>',
		loading	: '<spring:message code="doors.bridge.module.tree.loading" 	  text="Loading folder tree, Please wait..." javaScriptEscape="true" />'
	},

	validation	: {
		url		: '<c:url value="/ajax/doors/projectMapping.spr"/>',
		error 	: '<spring:message code="doors.bridge.folder.associated.with" text="The DOORS project/folder {0} is already associated with project {1}" arguments="XXX,YYY" javaScriptEscape="true"/>'
	}
};


var doorsMergedSettingsConfig = $.extend(true, {}, doorsSettingsEditorConfig, {
	server	: false,

	modules	: '<spring:message code="doors.bridge.trackers.template.settings" text="These are the cummulative settings of {0} DOORS Modules to import" arguments="XXX" javaScriptEscape="true"/>',

	metaData: {
		url	: '<c:url value="/ajax/doors/metaData.spr"/>'
	}
});


var doorsMergedSettingsDialog = $.extend({}, doorsSettingsDialogConfig, {
	settingsURL		: '<c:url value="/ajax/doors/trackerTemplate.spr"/>',

	trackers		: {
		url 		: '<c:url value="/ajax/doors/createTrackers.spr"/>',
		creating	: '<spring:message code="doors.bridge.trackers.import.running" text="Creating Trackers for {0} DOORS Modules in Project {1} ..." arguments="XXX,YYY" javaScriptEscape="true"/>'
	},

	remove			: false

});


var doorsImportModulesDialog = {
	label			: '<spring:message code="doors.bridge.trackers.import.label"   text="Create Trackers ..." arguments="XXX,YYY" javaScriptEscape="true"/>',
	title			: '<spring:message code="doors.bridge.trackers.import.title"   text="Create Trackers for {0} DOORS Modules in Project {1}" arguments="XXX,YYY" javaScriptEscape="true"/>',
	loading			: '<spring:message code="doors.bridge.trackers.import.loading" text="Loading available template trackers ...." javaScriptEscape="true"/>',
	templateURL		: '<c:url value="/ajax/doors/trackerTemplate.spr"/>',

	hint			: '<spring:message code="doors.bridge.trackers.import.tooltip" text="Please select the Template (preferred) or the Type of the new target trackers." javaScriptEscape="true"/>',

	template		: {
		label		: '<spring:message code="tracker.template.choose.label"   text="Template" javaScriptEscape="true"/>',
		title		: '<spring:message code="tracker.template.choose.tooltip" text="The template of the new trackers" javaScriptEscape="true"/>',
		select		: '<spring:message code="tracker.template.choose.hint" 	  text="Please select the template of the new trackers" javaScriptEscape="true"/>',
		none		: '<spring:message code="tracker.template.choose.none" 	  text="None" javaScriptEscape="true"/>',
		confirm		: '<spring:message code="doors.bridge.trackers.template.confirm" text="Do you really want to create {0} new trackers, based on the selected template of type {1} ?" arguments="XXX,YYY" javaScriptEscape="true"/>',

		inherit 	: {
			label 	: '<spring:message code="tracker.template.inheritanceConfig.label" 	text="Inherit template configuration" javaScriptEscape="true"/>',
			title 	: '<spring:message code="tracker.template.inheritanceConfig.tooltip" 	text="Should the template configuration be inherited or copied?" javaScriptEscape="true"/>'
		}
	},

	type			: {
		label		: '<spring:message code="tracker.type.label"   text="Type" javaScriptEscape="true"/>',
		title		: '<spring:message code="tracker.type.tooltip" text="The stereotype of the tracker" javaScriptEscape="true"/>',
		select		: '<spring:message code="tracker.type.select"  text="Please select the stereotype of the new trackers" javaScriptEscape="true"/>',
		confirm		: '<spring:message code="doors.bridge.trackers.type.confirm" text="Do you really want to create {0} new trackers of type {1} without a template ?" arguments="XXX,YYY" javaScriptEscape="true"/>'
	},

	settings		: {
		dialog  	: doorsMergedSettingsDialog,
		config		: doorsMergedSettingsConfig
	},

	submitText  	: '<spring:message code="button.ok" 	text="OK" 		javaScriptEscape="true"/>',
	cancelText  	: '<spring:message code="button.cancel" text="Cancel" 	javaScriptEscape="true"/>'
};


var doorsBaselineSetModulesConfig = {
	label 			: 'Modules',
	none 			: 'There are no modules to display',
	toggleAll		: '(De-)Select all modules',
	toggleThis	 	: '(De-)Select this module',

	module 			: {
		label		: '<spring:message code="doors.bridge.module.label"    text="Module" javaScriptEscape="true"/>',
		title		: '<spring:message code="doors.bridge.module.tooltip"  text="The DOORS Module" javaScriptEscape="true"/>',
		preview 	: doorsPreviewDialogConfig,

		deleted 	: {
			icon	: '<c:url value="/images/brokenlink.gif"/>',
			label	: '<spring:message code="doors.bridge.module.deleted.label"   text="Deleted" javaScriptEscape="true"/>',
			title	: '<spring:message code="doors.bridge.module.deleted.tooltip" text="This module was deleted" javaScriptEscape="true"/>'
		}
	},

	baseline		: {
		label		: '<spring:message code="doors.bridge.baseline.label"    text="Baseline" javaScriptEscape="true"/>',
		title		: '<spring:message code="doors.bridge.baseline.tooltip"  text="The Module baseline" javaScriptEscape="true"/>'
	},

	tracker			: {
		label		: '<spring:message code="doors.bridge.module.tracker.label"    text="Tracker" javaScriptEscape="true"/>',
		title		: '<spring:message code="doors.bridge.module.tracker.tooltip"  text="The target tracker associated with this module" javaScriptEscape="true"/>',
		link   		: '<c:url value="/tracker/XXX"/>',

		settings 	: {
			image	: '<c:url value="/images/cog.png"/>',
			label	: '<spring:message code="doors.bridge.settings.label" text="Settings..." javaScriptEscape="true"/>',
			hint	: '<spring:message code="doors.bridge.settings.hint"  text="Click here, to show/edit the DOORS import settings for this tracker" javaScriptEscape="true"/>',
			config  : doorsSettingsEditorConfig,
			dialog  : doorsSettingsDialogConfig
		}
	},

	lastImport 		: {
		label		: '<spring:message code="doors.bridge.tracker.import.last.label"   text="Last Import" javaScriptEscape="true"/>',
		title		: '<spring:message code="doors.bridge.tracker.import.last.tooltip" text="Date, time and baseline of the last import" javaScriptEscape="true"/>',
		never		: '<spring:message code="doors.bridge.tracker.import.last.none"    text="Never" javaScriptEscape="true"/>',
		history 	: doorsImportConfig.history
	}
};


var doorsBaselineSetModulesDialog = {
	title			: '<spring:message code="doors.bridge.baselineSet.modules.title" text="Modules in Baseline Set {0}" arguments="XXX" javaScriptEscape="true"/>',
	submitText  	: '<spring:message code="button.ok" 	text="OK" 		javaScriptEscape="true"/>',
	cancelText  	: '<spring:message code="button.cancel" text="Cancel" 	javaScriptEscape="true"/>',
	closeText   	: '<spring:message code="button.close" 	text="Close" 	javaScriptEscape="true"/>',

	importDialog 	: doorsImportModulesDialog,
	importSuccess   : '<spring:message code="doors.bridge.trackers.import.success" text="Successfully created and configured {0} new Trackers for the selected DOORS Modules in Project {1}" arguments="XXX,YYY" javaScriptEscape="true"/>',
	importWithErrors: '<spring:message code="doors.bridge.trackers.import.failed"  text="Could only create and configure {0} new Trackers for the selected DOORS Modules in Project {1}.\n Creating Trackers for {2} Modules failed!\n Please see list for details." arguments="XXX,YYY,ZZZ" javaScriptEscape="true"/>'
};


var doorsImportBaselineSetsDialog = $.extend(true, {}, doorsImportConfig, {
	label			: '<spring:message code="doors.bridge.baselineSets.import.label"   text="Import selected baseline sets ..." javaScriptEscape="true"/>',
	title			: '<spring:message code="doors.bridge.baselineSets.import.title"   text="Import DOORS Baseline Sets" javaScriptEscape="true" />',
	loading			: '<spring:message code="doors.bridge.baselineSets.import.loading" text="Loading necessary steps, to import the selected baseline sets ..." javaScriptEscape="true" />',
	stepsURL		: '<c:url value="/ajax/doors/baselineSetImportSteps.spr" />',

	baselineSet		: {
		label		: '<spring:message code="doors.bridge.baselineSet.label" text="Baseline Set" javaScriptEscape="true"/>',
		url			: '<c:url value="/ajax/doors/importBaselineSet.spr" />'
	},

	baseline		: {
		url			: '<c:url value="/ajax/doors/import.spr" />',

		statistics	: {
			hint	: '<spring:message code="doors.bridge.baseline.import.statistics.label" text="Click here, to show statistics about the import of this baseline" javaScriptEscape="true"/>',
			config	: doorsImportStatisticsConfig,
			dialog	: {
				title : '<spring:message code="doors.bridge.baseline.import.statistics.title" text="Import of Baseline {0} of Module {1}" arguments="XXX,YYY" javaScriptEscape="true"/>'
			}
		}
	},

	tracker			: {
		label		: '<spring:message code="doors.bridge.module.tracker.label" text="Tracker" javaScriptEscape="true"/>',
		url			: '<c:url value="/tracker/XXX" />'
	},

	"import"		: {
		full		: {
			label	: '<spring:message code="doors.bridge.tracker.import.full.label"    text="full" javaScriptEscape="true"/>',
			title	: '<spring:message code="doors.bridge.tracker.import.full.tooltip"  text="A full import of all data in this module/baseline" javaScriptEscape="true" />'
		},

		incremental	: {
			label	: '<spring:message code="doors.bridge.tracker.import.incremental.label"   text="incremental" javaScriptEscape="true"/>',
			title	: '<spring:message code="doors.bridge.tracker.import.incremental.tooltip" text="An incremental import of modified data in this module/baseline" javaScriptEscape="true" />'
		},

		success		: '<spring:message code="doors.bridge.baselineSets.import.success" text="The DOORS Baseline Sets were imported successfully" javaScriptEscape="true"/>',

		cancel		: {
			label	: '<spring:message code="button.cancel" text="Cancel" 	javaScriptEscape="true"/>',
			required: '<spring:message code="doors.bridge.baselineSets.import.cancel.required" text="You cannot close this dialog, because an import is running. You have to Cancel the import first!" javaScriptEscape="true"/>',
			confirm	: '<spring:message code="doors.bridge.baselineSets.import.cancel.confirm"  text="Do you really want to cancel the running import ?" javaScriptEscape="true"/>'
		}
	},

	submitText  	: '<spring:message code="button.ok" text="OK" javaScriptEscape="true"/>'
});


var doorsBaselineSetConfig = $.extend({}, remoteConnectionConfig, {
	help		: {
		title	: '"Importing DOORS Projects, Folders and Baseline Sets" in codeBeamer Knowledge Base',
		URL		: 'https://codebeamer.com/cb/wiki/3860514'
	},

	folder			: {
		label		: '<spring:message code="doors.bridge.folder.label"   text="Project/Folder" javaScriptEscape="true"/>',
		title		: '<spring:message code="doors.bridge.folder.tooltip" text="The DOORS project/folder, whose defined baseline sets to import" javaScriptEscape="true" />',
		selector	: doorsFolderSelectorConfig
	},

	baselineSets	: {
		url			: '<c:url value="/ajax/doors/importableBaselineSets.spr?proj_id=" />',
		label		: '<spring:message code="doors.bridge.baselineSets.label"   text="Baseline Sets" javaScriptEscape="true"/>',
		title		: '<spring:message code="doors.bridge.baselineSets.tooltip" text="The defined baseline sets of the selected DOORS project/folder" javaScriptEscape="true" />',
		loading		: '<spring:message code="doors.bridge.baselineSets.loading" text="Loading the defined baseline sets of the selected DOORS project/folder ..." javaScriptEscape="true"/>',
		none		: '<spring:message code="doors.bridge.baselineSets.none"    text="There are no baseline sets in the selected DOORS project/folder" javaScriptEscape="true"/>',
		selectSet	: '<spring:message code="doors.bridge.baselineSets.select"  text="De-)Select this baseline set for import" javaScriptEscape="true"/>',
		toggleAll	: '<spring:message code="doors.bridge.baselineSets.toggleAll" text="De-)Select all importable baseline sets" javaScriptEscape="true"/>',

		importable	: {
			label	: '<spring:message code="doors.bridge.baselineSets.importable.label"   text="Importable" javaScriptEscape="true"/>',
			title	: '<spring:message code="doors.bridge.baselineSets.importable.tooltip" text="Whether to only show the importable baseline sets, or also those, that are already imported or cannot be imported" javaScriptEscape="true"/>'
		},

		definition	: {
			label	: '<spring:message code="doors.bridge.baselineSet.definition.label"   text="Definition" javaScriptEscape="true"/>',
			title	: '<spring:message code="doors.bridge.baselineSet.definition.tooltip" text="The name of the baseline set definition" javaScriptEscape="true" />'
		},

		version		: {
			label	: '<spring:message code="doors.bridge.baselineSet.version.label"   text="Version" javaScriptEscape="true"/>',
			title	: '<spring:message code="doors.bridge.baselineSet.version.tooltip" text="The version (major and minor number plus optional suffix) of the baseline set" javaScriptEscape="true" />'
		},

		createdAt	: {
			label	: '<spring:message code="doors.bridge.baselineSet.createdAt.label"   text="Created at" javaScriptEscape="true"/>',
			title	: '<spring:message code="doors.bridge.baselineSet.createdAt.tooltip" text="The date and time of baseline set creation" javaScriptEscape="true" />'
		},

		createdBy	: {
			label	: '<spring:message code="doors.bridge.baselineSet.createdBy.label"   text="Created by" javaScriptEscape="true"/>',
			title	: '<spring:message code="doors.bridge.baselineSet.createdBy.tooltip" text="The name of the DOORS user, that created this baseline set" javaScriptEscape="true" />'
		},

		status		: {
			label	: '<spring:message code="doors.bridge.baselineSet.status.label"   text="Status at" javaScriptEscape="true"/>',
			title	: '<spring:message code="doors.bridge.baselineSet.status.tooltip" text="The status of this baseline set" javaScriptEscape="true"/>',

			importable	: {
				label	: '<spring:message code="doors.bridge.baselineSet.status.importable.label"   text="Importable" javaScriptEscape="true"/>',
				title	: '<spring:message code="doors.bridge.baselineSet.status.importable.tooltip" text="This baseline set can be imported" javaScriptEscape="true"/>'
			},

			imported	: {
				label	: '<spring:message code="doors.bridge.baselineSet.status.imported.label"   text="Imported" javaScriptEscape="true"/>',
				title	: '<spring:message code="doors.bridge.baselineSet.status.imported.tooltip" text="This baseline set was already imported" javaScriptEscape="true"/>'
			},

			blocked		: {
				label	: '<spring:message code="doors.bridge.baselineSet.status.blocked.label"   text="Blocked" javaScriptEscape="true"/>',
				title	: '<spring:message code="doors.bridge.baselineSet.status.blocked.tooltip" text="This baseline set cannot be imported, because at least one of the included modules has already been imported beyond the module version in this set" javaScriptEscape="true"/>',
				config  : doorsBaselineSetModulesConfig,
				dialog  : $.extend({}, doorsBaselineSetModulesDialog, {
					title 	: '<spring:message code="doors.bridge.baselineSet.status.blocked.title" text="The imports of these Modules block the import of Baseline Set {0}" arguments="XXX" javaScriptEscape="true"/>',
					modules : 'blockers'
				})
			}
		},

		coverage	: {
			label	: '<spring:message code="doors.bridge.baselineSet.coverage.label"   text="Coverage" javaScriptEscape="true"/>',
			title	: '<spring:message code="doors.bridge.baselineSet.coverage.tooltip" text="The ratio of modules in this baseline set, that are associated with trackers" javaScriptEscape="true" />',
			hint	: '<spring:message code="doors.bridge.baselineSet.coverage.hint"    text="Click here, to view modules in this set and their associated target tracker" javaScriptEscape="true" />',
			config  : doorsBaselineSetModulesConfig,
			dialog  : doorsBaselineSetModulesDialog
		}
	}
});

var doorsBaselineSetDialogConfig = {
	title			: '<spring:message code="doors.bridge.folder.import.label" text="DOORS Project/Folder" javaScriptEscape="true" />',
	loading			: '<spring:message code="doors.bridge.settings.loading"	text="Loading settings, please wait ..." javaScriptEscape="true" />',
	saving			: '<spring:message code="doors.bridge.folder.saving" text="Associating project with the selected DOORS project/folder ..." javaScriptEscape="true" />',
	folderURL		: '<c:url value="/ajax/doors/projectFolder.spr"/>',
	importDialog	: doorsImportBaselineSetsDialog,
	submitText  	: '<spring:message code="button.ok" 	text="OK" 		javaScriptEscape="true"/>',
	cancelText  	: '<spring:message code="button.cancel" text="Cancel" 	javaScriptEscape="true"/>'
};


function importDoorsBaselineSets(projectId) {
	var popup = $('#DoorsBaselineSetPopup');
	if (popup.length == 0) {
		popup = $('<div>', { id : 'DoorsBaselineSetPopup', "class" : 'editorPopup', style : 'display: None;' });
		$(document.documentElement).append(popup);
	} else {
		popup.empty();
	}

	popup.showDoorsBaselineSetDialog(projectId, doorsBaselineSetConfig, doorsBaselineSetDialogConfig);

	return false;
}

</script>
