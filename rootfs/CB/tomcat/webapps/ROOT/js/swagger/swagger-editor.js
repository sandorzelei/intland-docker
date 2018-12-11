$(function() {

	function HideTopbarPlugin() {
		return {
			components : {
				Topbar : function() {
					return null
				}
			}
		}
	}
	
	var url = $('#swagger-editor').data('url');
	var ui = SwaggerUIBundle({
		url : url,
		docExpansion: 'none',
		dom_id : '#swagger-editor',
		deepLinking : true,
		presets : [ SwaggerUIBundle.presets.apis, SwaggerUIStandalonePreset ],
		plugins : [ SwaggerUIBundle.plugins.DownloadUrl, HideTopbarPlugin ],
		layout : "StandaloneLayout"
	})

});