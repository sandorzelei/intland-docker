function hideLoading() {
	if (document.layers) {
		// Netscape-4.x
		document.loading.visibility="hide";
	} else if (document.all) {
		// Microsoft IE
		document.all.loading.style.visibility="hidden";
	}
	else if (document.getElementById) {
		// Netscape 6.x
		document.getElementById('loading').style.visibility = 'hidden';
	}
	else {
		document.loading.visibility="hide";
	}
}
