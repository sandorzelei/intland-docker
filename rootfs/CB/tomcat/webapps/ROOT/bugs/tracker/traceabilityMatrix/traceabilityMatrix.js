var traceabilityMatrix = {
	
	initTooltip: function() {
		$(document).tooltip({
			items: ".traceabilityMatrix td",
			tooltipClass: "traceabilityMatrixTooltip",
			position: { my: "left top", at: "right-12 bottom-8", collision: "flipfit" },
			show: false, // no animation
			hide: { delay: 50, duration: 0 },
			content: function() {
				console.log("tooltip is called");
				var $td = $(this);
				var coords = getCoordinates($td);
				var $horizontalTH = $("#horizontal-" + coords.horizontal);
				var $verticalTH = $("#vertical-" + coords.vertical);
				
				// highlight the cell headers
	/*				
				$(".highlighted").removeClass("highlighted");
				$horizontalTH.addClass("highlighted");
				$verticalTH.addClass("highlighted");
	*/				
				
				var getName = function(th) {
					// show as simple label: 
					// return $(th).find("label").html();
					// show as link
					return $(th).find("a").outerHTML();
				};
				
				var horizontalIssueName = getName($horizontalTH);
				var verticalIssueName = getName($verticalTH);
				
				return "<table><tr><td>&uarr;</td><td>" + horizontalIssueName +"</td></tr><tr><td>&larr;</td><td>" + verticalIssueName + "</td></tr></table>";
			},
			close: function(event, ui) {
				// remove previous highlights				
//				$(".highlighted").removeClass("highlighted");
				
				jquery_ui_keepTooltipOpen(ui);
			}		
		});
	}		
};

var overlayContent;

function getCoordinates(td) {
	var id = $(td).attr("id");
	var parts = id.split("-");
	return {horizontal: parts[1], vertical: parts[2]};
}

var dependencyEditor;

function editDependency(e) {
	var $td = $(e.target).closest("td[id]");

	var self = this;
	$(self).one("click", editDependency);
	if ($td.hasClass("noteditable") || $td.hasClass("axial")) {
		return;
	}
	
	var coords = getCoordinates($td);
	$.ajax({
		type: "get",
		url: contextPath + "/proj/tracker/getdependency.spr?task_id=" + coords.horizontal + "&v_task_id=" + coords.vertical,
		dataType: "json",
		success: function(data) {
			if (data == null) {
				showOverlayMessage(i18n.message("tracker.traceability.error.loading.dependency"), 3, true);
				return;
			}
			dependencyEditor = showModalDialogWithArgs("inlinedPopup", overlayContent, null, null, false, { width: "500px" });
			
			var $overlay = $(".inlinedPopup");
			$overlay.find("#horizontalId").val(coords.horizontal);
			$overlay.find("#horizontalName").text(data.dependency.horizontalTrackerItemName);
			$overlay.find("#verticalId").val(coords.vertical);
			$overlay.find("#verticalName").text(data.dependency.verticalTrackerItemName);
			$overlay.find("#direction label").removeAttr("class");
			$overlay.find("#direction #" + data.dependency.direction).attr("checked", "checked");
			$overlay.find("#direction").buttonset();
			$overlay.find("#propagateSuspected").prop("checked", data.dependency.propagateSuspected);
			$overlay.find("input[type='button']").click(updateDependency);
			$overlay.find("label").dblclick(updateDependency);

			dependencyEditor.dialog("open");
		},
		error: function(jqXHR, textStatus, errorThrown) {
			showOverlayMessage(i18n.message("tracker.traceability.error.loading.dependency"), 3, true);
		}
	});

	return false;
}

function updateDependency(e) {
	// debugger;
	var $overlay = $(".inlinedPopup");
	//var $directions = $overlay.find("#direction input[name=direction]:checked");
	var data = {
		"task_id": $overlay.find("#horizontalId").val(),
		"v_task_id": $overlay.find("#verticalId").val(),
		"direction": $overlay.find("#direction input[name=direction]:checked").attr("id"),
		"propagateSuspected": $overlay.find("#propagateSuspected").is(":checked")
	};
	console.log("direction:" + data.direction);
	
	dependencyEditor.destroy();
	$.ajax({
		type: "post",
		url:  contextPath + "/proj/tracker/updatedependency.spr",
		data: data,
		dataType: "json",
		success: function(ajaxResult) {
			var $td1 = $("#dependency-" + data.task_id + "-" + data.v_task_id);
			var $td2 = $("#dependency-" + data.v_task_id + "-" + data.task_id); // opposite direction dependency

			var dir = ajaxResult.dependency.direction;
			if(dir == "h2v") {
				$td1.html("<img src='" + contextPath + "/images/top_to_left_arrow.png'>");
				$td2.html("<img src='" + contextPath + "/images/left_to_top_arrow.png'>");
			} else if (dir == "v2h") {
				$td1.html("<img src='" + contextPath + "/images/left_to_top_arrow.png'>");
				$td2.html("<img src='" + contextPath + "/images/top_to_left_arrow.png'>");
			} else if (dir == "bi") {
				$td1.html("<img src='" + contextPath + "/images/top_left_bidir_arrow.png'>");
				$td2.html("<img src='" + contextPath + "/images/top_left_bidir_arrow.png'>");
			} else {
				$td1.html("");
				$td2.html("");
			}
			console.log("image set to:<" + $td1.html() +"> and <" + $td2.html() +">, direction:<" + dir +">");

			var suspected = ajaxResult.dependency.propagateSuspected;
			$td1.toggleClass("propagate-suspected", suspected);
			$td2.toggleClass("propagate-suspected", suspected);
		},
		error: function(jqXHR, textStatus, errorThrown) {
			alert("Error: " + textStatus + " - " + errorThrown);
		}
	});
}

$(function() {
	// avoid multiple initialization of the event handlers here
	if (typeof traceabilityMatrixAlreadyInitialized != "undefined") {
		return;
	}
	traceabilityMatrixAlreadyInitialized = true;	// not a mistake, it is a "global" variable 
	
	// initialize tooltip
	traceabilityMatrix.initTooltip();
	
	// add table hover
	$('.traceabilityMatrix').tableHover({colClass: 'hover', headCols: true, ignoreCols: [1], items: "td, tr:not(.extraHeaderRow) th"});

	// initialize dependency editor on traceability matrixes which are "editable"
	$(".configurableTraceabilityMatrix td").one("click", editDependency);

	// save the overlay's template and remove it from DOM, because the html-ids of the template will conflict otherwise with the overlay's html fragment!
	var $overlayTemplate = $("#dependency-editor-overlay");
	overlayContent = $.trim($overlayTemplate.html());
	$overlayTemplate.remove();
});	

