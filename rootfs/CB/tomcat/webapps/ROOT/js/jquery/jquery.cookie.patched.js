// patch JQuery's $.cookie so it should automatically set secure flag for cookies when used with https
(function() {
	var patched = jQuery.cookie;
	jQuery.cookie = function(name,value,options) {
		options = options || {};
		// set the correct secure flag
		options.secure =  (location.protocol === 'https:');
		return patched(name,value,options);
	}
})();