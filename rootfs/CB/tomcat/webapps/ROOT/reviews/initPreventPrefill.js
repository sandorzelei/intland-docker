$(document).ready(function() {
	codebeamer.prefill.prevent($("input[name=baselineSignature]"), getBrowserType());
});