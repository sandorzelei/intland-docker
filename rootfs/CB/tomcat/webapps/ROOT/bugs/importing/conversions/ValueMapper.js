/**
 * Javascript companion for configuring value-mapping. See ValueMapper.jsp
 */
var valueMapper = {
	init: function() {
		$(".valueMapping").each(function() { valueMapper.initValueMappingBlock(this); });		
	},
	
	initValueMappingBlock: function(valueMapping) {
		valueMapper.createAtleastOneMapping(valueMapping);
	},

	createAtleastOneMapping:function(valueMapping) {
		if ($(valueMapping).find(".mappings li").length == 0) {
			valueMapper.addOneValueMapping(valueMapping);
		}
	},
	
	addOneValueMapping:function(valueMapping) {
		var $valueMapping = $(valueMapping).closest(".valueMapping");
		
		var $template = $valueMapping.find(".template");
		if ($template.length > 0) {
			var templateHtml = $template.html();
			templateHtml = "<li>" + templateHtml +"</li>";	// change the css from template to oneMapping so this will be visible
			var $x = $valueMapping.find("ul.mappings").append(templateHtml);
			
			$x.find("select").each(function() {
				// init multi-select widget
				$(this).multiselect({
					multiple: true,
					selectedList: 99,
					noneSelectedText: "--select at least one value--"	// TODO: i18n & better text
				}).multiselectfilter();
			});
		}
	},
	
	deleteMapping: function(el) {
		var $oneMapping = $(el).closest("li");
		$oneMapping.remove();
	}

};

$(valueMapper.init);
