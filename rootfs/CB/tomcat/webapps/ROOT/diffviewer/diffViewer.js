
$(function() {
	floatingOverlay.show("findDiffButtonsPanel", "actionBar1");

	try {
		// immediately scroll to the first change
		JumpToDiff.jumpToNext();
	} catch(e) {
		console.log(e);
	}
});

// called when the revision select changes
function onRevisionSelectChange(select) {
	$(select).closest("form").submit();
}

function updateAllowWrap() {
	var allowWrap = $("#allowWrap").is(":checked");
	$("#diffContainer").toggleClass("allow_pre_wrap", allowWrap);
}
$(function() {
	$("#allowWrap").click(updateAllowWrap);
	updateAllowWrap();
});

function submitForm(element) {
	$(element).closest("form").submit();
}

function fetchRevisions(url) {
	var $form = $("form").first();
	var params = $form.serialize();
	url += "?" + params;
	$.ajax(url, {
		success: function(data) {
			var fillRevisionSelect = function(revisionSelect, revisions) {
				var $revisionSelect = $(revisionSelect);

				var currentValue = $revisionSelect.val();
				var $optionsBefore = $revisionSelect.find("option");
				var selectionFound = false;
				var options = [];
				for (var i=0; i< revisions.length; i++) {
					var rev = revisions[i];
					var selected = "";
					if (currentValue == rev.value) {
						selected = "selected";
						selectionFound = true;
					}
					if (rev.value == null) {
						rev.value = "";
					}
					if (rev.name == null) {
						rev.name = "";
					}

					var option = "<option title='" + rev.title +"' value='" + rev.value +"' " + selected +" >" + rev.name +"</option>";
					options.push(option);
				}
				$revisionSelect.append(options.join("\n"));

				if (selectionFound) {
					// remove the old options
					$optionsBefore.remove();
				}

				// remove if there is duplicate blanks in the option links
				var blanks = $revisionSelect.find("option[value='']");
				if (blanks.length > 1) {
					for (var i=1; i<blanks.length; i++) {
						var blank = blanks[i];
						$(blank).remove();
					}
				}
			};

			fillRevisionSelect("#revision1", data);
			fillRevisionSelect("#revision2", data);
		}
		// TODO: error handling ?
	});
}
