function handleResize() {
	document.location.reload();
	return false;
}
if (document.layers) {
	window.captureEvents(Event.RESIZE);
	window.onresize = handleResize;
}
