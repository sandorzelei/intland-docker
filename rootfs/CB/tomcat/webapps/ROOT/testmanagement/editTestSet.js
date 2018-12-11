
var editTestSet = {

	initEvents: function(table) {
		$(table).click(function(event) {
			var $target = $(event.target);

			// handling delete button
			// using event delegation to catch the clicks on delete icons, better performance than subscribing to each delete buttons individually
			if ($target.hasClass("deleteTestCaseIcon")) {
				var $tr = $target.closest("tr");
				//console.log("deleting row:" + $tr);
				var $table = $tr.closest("table");
				$tr.remove();
				$table.trigger("changed", [ $tr ]);

				duplicatesHandling.handleDuplicates($table);
			}

			if ($target.hasClass("removeOtherDuplicates")) {
				var $tr = $target.closest("tr");
				var $table = $tr.closest("table");

				duplicatesHandling.removeOtherDuplicates($tr);
			}

			if ($target.hasClass("expandTestSet")) {
				var $tr = $target.closest("tr");
				editTestSet._expandTestSet($tr);
			}
		});

		duplicatesHandling.highlightDuplicates($(table));
	},

	/**
	 * Expand TestSet to its TestCases
	 * @param tr The table-row contains the TestSet
	 */
	_expandTestSet:function(tr) {
		var testSetId = $(tr).find("[name='testCaseIdsInOrder']").val();
		if (testSetId != "") {
			editTestSet.addTestCasesOrTestSets([testSetId], [], tr, true);
		}
	},

	/**
	 * Add the TestCases/TestSets and content of trackers to the table
	 * @param testCaseOrTestSetIds The ids or the TestCase's items or TestSets' items to add
	 * @param trackerIds
	 * @param $placeToDrop The html element where the test-cases will be added to. This element will be removed from DOM !
	 * @param expandTestSets If the TestSets are exploded and only their TestCases are added
	 */
	addTestCasesOrTestSets: function(testCaseOrTestSetIds, trackerIds, $placeToDrop, expandTestSets) {
		console.log("Adding items:" + testCaseOrTestSetIds +", dropped trackers:" + trackerIds);
		var start = new Date().getTime();

        var $table = $placeToDrop.closest("table");
        var busySign = ajaxBusyIndicator.showBusySignOnPanel($table);

        $.ajax({
			url : contextPath
					+ "/ajax/testset/testCasesListForTestSet.spr",
			type : "POST",
			data : {
				"testCaseOrTestSetIds" : testCaseOrTestSetIds,
				"trackerIds" : trackerIds,
				"allowDuplicates" : duplicatesHandling.allowDuplicates(),
				"expandTestSets": expandTestSets
			},
			complete: function() {
                if (busySign) {
                    ajaxBusyIndicator.close(busySign);
                }
			},
			success : function(html) {
			    var loaded = new Date().getTime();
			    var LOG = "testCasesListForTestSet: ";
			    console.log(LOG + "Time to load data via ajax:" + (loaded - start) + "ms");

				try {
					var $rows = $(html).find("tbody tr");

					var $table = $placeToDrop.closest("table");

					// insert the new rows before the placeholder
					$rows.detach();
					$placeToDrop.before($rows);

                    // remove the placeholder used for dropping
                    $placeToDrop.remove();

                    var firstPart = new Date().getTime();
                    console.log(LOG + "Adding rows to DOM:" + (firstPart - loaded) + "ms");

                    // a bit later trigger events so the page will be more responsive
                    var triggerChangedEvent = function() {
                        var start = new Date().getTime();
                        // a bit later trigger events
                        $table.trigger("changed", [ $rows ]);
                        var end = new Date().getTime();
                        console.log(LOG + "Changed event fire took:" + (end - start) + "ms");
                    };

                    setTimeout(function() { flashChanged($rows); }, 200);
                    setTimeout(function() {
                        // remove or highlight duplicates
                        duplicatesHandling.handleDuplicates($table);
                    }, 150);

                    setTimeout(triggerChangedEvent, 1000);
				} catch (e) {
					console.log("Can't insert nodes, error: " + e);
				}
			},
			error : function(jqXHR, textStatus, errorThrown) {
				// TODO: handle error
				console.log(LOG + "Ajax error after drop:" + textStatus);
			}
		});
	}
}

/**
 * Functions to handle duplicates
 */
var duplicatesHandling = {

	allowDuplicatesFieldId: null,
	allowDuplicatesDefault: false,

	/**
	 * Compute if the TestSet allows duplicates. This may change as the user may change the "allowDuplicates" flag while editing
	 */
	allowDuplicates: function() {
		var $allowDuplicatesSelect = $("#dynamicChoice_references_" + duplicatesHandling.allowDuplicatesFieldId).first();
		if ($allowDuplicatesSelect.length > 0) {
			var val = $allowDuplicatesSelect.val();
			if ("true" == val) {
				return true;
			} else if ("false" == val) {
				return false;
			}
			// otherwise use default
		} else {
			// the field is not visible: that means we force to allow duplicates even that that the tracker config does not allow that
			return true;
		}
		return duplicatesHandling.allowDuplicatesDefault;
	},

	// get the test-case's id from a row
	getId: function(row) {
		var id = $(row).find(idFieldSelector).val();
		return id;
	},

	// find the duplicates and return them
	// @param The table too look into
	// @param id The id to look for
	// @return the duplicate rows, or only the one row if found
	findDuplicates: function(table, id) {
		// check if the same appears in the old table
		var $duplicates = $(table).find(idFieldSelector + "[value='" + id + "']").closest("tr");
		return $duplicates;
	},

	scanDuplicates: function(table, callback) {
        var start = (new Date()).getTime();

        // map that contains the id->array of duplicated elements
        var duplicatesMap = {};

        $(table).find("tr").each(function () {
            var id = duplicatesHandling.getId(this);
            if (id) {
                var dupes = duplicatesMap[id];
                if (dupes == null) {
                    dupes = [];
                    duplicatesMap[id] = dupes;
                }
                dupes.push(this);
            }
        });

        $.each(duplicatesMap, function (id, dupes) {
            var duplicate = dupes.length > 1;
            callback(duplicate, dupes);
        });

        var end = (new Date()).getTime();
        console.log("scanDuplicates took " + (end-start) + "ms");
    },

	highlightDuplicates: function(table) {
		duplicatesHandling.scanDuplicates(table, function(duplicate, duplicates) {
			$(duplicates).toggleClass("duplicate", duplicate);
		});

		//if (! duplicatesHandling.allowDuplicates()) {
			var duplicates = $(table).find(".duplicate");

			if (duplicates.length > 0) {
				$("#duplicatesWarning").show();
			} else {
				$("#duplicatesWarning").hide();
			}
		//}
	},

	removeDuplicates: function(table) {
		duplicatesHandling.scanDuplicates(table, function(duplicate, duplicates) {
			if (duplicate) {
				$(duplicates).removeClass("duplicate");
				$(duplicates).slice(1).remove();	// remove duplicates except the 1st (the slice(1) skips the 1st)
			}
		});

		duplicatesHandling.handleDuplicates(table);
	},

	/**
	 * Handle if the same TestCase is dropped again
	 * @param $table The table with the old rows
	 */
	handleDuplicates: function(table) {
		duplicatesHandling.highlightDuplicates(table);
	},

	/**
	 * Find and remove other duplicates of a row
	 */
	removeOtherDuplicates: function(tr) {
		var id = duplicatesHandling.getId(tr);
		var table = $(tr).closest("table");
		var $duplicates = duplicatesHandling.findDuplicates(table, id);

		$duplicates.not(tr).remove();
		duplicatesHandling.handleDuplicates(table);
	}

}