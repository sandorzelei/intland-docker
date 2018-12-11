$("#exportProperties").change(function(){
	var checked = $(this).is(":checked");
	$("#exportItemHistory").attr("disabled", !checked);
	$("#propertiesEditable").attr("disabled", !checked);
	$("#propertiesEditableLabel").toggleClass("disabledLabel", !checked);
});
$("#exportProperties2").change(function(){
	var checked = $(this).is(":checked");
	$("#exportItemHistory2").attr("disabled", !checked);
});

// update dependent checkboxes on load
$(function() {
	$("#exportProperties").change();
	$("#exportProperties2").change();
});

$("#exportReviews").change(function(){
	var checked = $(this).is(":checked");
	$("#exportReviewComments").attr("disabled", !checked);
});

$("#exportReviews2").change(function(){
	var checked = $(this).is(":checked");
	$("#exportReviewComments2").attr("disabled", !checked);
});

if( exportIsTestRunExport ) {
	var optionWrapper = $("#advancedWordExportWrapper");
	optionWrapper.css("display", "none");

	$(".templateSelection select").change(function() {
		if ($(this).val() == "") {
			optionWrapper.css("display", "none");
		} else {
			optionWrapper.css("display", "block");
		}
	});
}

function updateOnRoundtripExportChange() {
	var $selectedKind = $("input[name=exportKind]:checked");
	var exportKind = $selectedKind.val();

	// add the selected kind's value as css class to body
	$("input[name=exportKind]").each(function() {
		var val = $(this).val();
		$("body").toggleClass(val, $(this).is(":checked"));
	});

	var $templateSelect = $(".templateSelection select");
	var templateOptions = $templateSelect.data("templateOptions");
	if (templateOptions == null) {
		// save current options as template options
		templateOptions = $templateSelect.html();
		$templateSelect.data("templateOptions", templateOptions);
	} else {
		$templateSelect.html(templateOptions);	// restore original/unfiltered content
	}

    // filter the template block to show only .doc* files for word or .xl* files files for excel export
    $templateSelect.val([]);
    $templateSelect.find("option").each(function() {
    	var templateName = $(this).val();
    	var keep = false;
    	if (exportKind.toLowerCase().indexOf("word") != -1) {
    		// keep only word files
    		keep = templateName.indexOf(".doc") != -1;
    	} else {
    		// Excel: keep only excel files
    		keep = templateName.indexOf(".xl") != -1;
    	}
    	if (templateName == "") {
    		keep = true;	// keep the "default" always
    	}
    	if (!keep) {
    		$(this).remove();
    	}
    });

    // refresh the template selector select widget
    $("select.templateName").multiselect('refresh');

	$(".exportBlock").removeClass("selectedExportBlock").addClass("disabledRoundtripOptions");

	var $selectedExportBlock = $selectedKind.closest(".exportBlock");
	$selectedExportBlock.addClass("selectedExportBlock").removeClass("disabledRoundtripOptions");

	$(".exportBlock").each(function() {
		var selected = $(this).hasClass("selectedExportBlock");

		$(this).find("div.options").each(function() {
			$(this).find("input, select").not("#exportReviewComments2,#exportReviewComments").attr("disabled", ! selected) ;
			if (selected) {
				if (!$(this).is(":visible")) {
					$(this).show();
				}
			} else {
				$(this).hide();
			}
		});
	});
}
$("input[name=exportKind]").change(updateOnRoundtripExportChange);
$(updateOnRoundtripExportChange);

$(".exportTemplate").bind("switchToExcelTab", function() {
	var changingTab = !($("#excelExport").is(":visible"));
	org.ditchnet.jsp.TabUtils.switchTab(document.getElementById('excelExportTabPane-tab'));
	if (changingTab) {
		$("#excelExport").click();
	}
});

$(".exportTemplate").bind("switchToWordTab", function() {
	var changingTab = !($("#simpleWordExport").is(":visible"));
	org.ditchnet.jsp.TabUtils.switchTab(document.getElementById('wordExportTabPane-tab'));
	if (changingTab) {
		$("#simpleWordExport").click();
	}
});

function onTabChange(e) {
	var selectedTabPane = e.getTabPane();

	if( exportIsTestRunExport ) {
		$("#advancedWordExportWrapper").css("display", "none");
	}

	switch(selectedTabPane.id) {
		case "wordExportTabPane": $("#simpleWordExport").click();
				break;
		case "excelExportTabPane": $("#excelExport").click();
				break;
		case "msProjectExportTabPane": $("#msprojectExport").click();
				break;
		default: break;
	}
}
