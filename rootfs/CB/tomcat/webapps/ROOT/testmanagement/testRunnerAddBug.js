/*
 * Javascripts for testRunnerAddBug.jsp
 */

/*
 * Close the overlay for adding bug and write back the newly added bug to the TestRunner
 * @param bugId The id of the bug
 * @param bugName The name of the bug: should be html escaped
 * @param url The url of the bug
 */
function closeWithBugAdded(bugId, bugName, url) {
	console.log("Closing overlay when bug added, bugId:" + bugId +", name:" + bugName +", url:" + url);
	try {
		var added = parent.reportBug.bugAdded(bugId);
		if (added) {
			if (bugName != null) {
				bugName = bugName.trim();
			}

			// this will show the globalMessage on the ui about the issue being added
			parent.reportBug.showBugAddedMessage(bugId, bugName, url);
		}
	} catch (ignored) {
		console.log("Failed to call 'bugAdded' callback on the opener page:" + ignored);
	};

	inlinePopup.close();
}
