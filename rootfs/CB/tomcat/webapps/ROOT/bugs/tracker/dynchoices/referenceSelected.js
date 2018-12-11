// $Id$
//
// script writes back the data to opener, and closes popup
// @param the part of the full html-id identifies the span (without referenceForLabel) text
function writeBackChoosenReferences(htmlIdPart, referencesRendered) {
	// build the html id of the content to be written back composite key for label
	var htmlId = "referencesForLabel_" + htmlIdPart;

	// write back the selected data to the original window
	if (parent.document) {
		var openerDoc = parent.document;
		var openerRefHTML = openerDoc.getElementById(htmlId);
		if (openerRefHTML && openerRefHTML.reinitAjaxReferenceControl != null) {
			openerRefHTML.reinitAjaxReferenceControl(referencesRendered);
		}
	}

	// close the popup
	inlinePopup.close();
}
