// $Id$
// Javascript file for approvalSteps.jsp

function selectStep(id) {
	/*// old code with radio buttons for selected step.
	var radioStep = document.getElementById("selectedStep_" + id);
	if (!radioStep) {
		throw "Step with id=" + id + " not found!";
	}
	radioStep.checked = true;
	*/
	var selectedStepField = document.getElementById("selectedStep");
	selectedStepField.value = id;
}

// delete one step
// @param id The step's id
function deleteStep(id) {
	selectStep(id);
	//if (confirmDeleteStep()) {
		var deleteStepSubmit = document.getElementById("deleteStepSubmit");
		deleteStepSubmit.value="OK";
		deleteStepSubmit.form.submit();
	//}
}

// edit a step
// @param id The step's id
function editStep(id) {
	selectStep(id);
	var editStepSubmit = document.getElementById("editStepSubmit");
	editStepSubmit.value="OK";
	editStepSubmit.form.submit();
}

