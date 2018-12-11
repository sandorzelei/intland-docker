/*
 * Copyright by Intland Software
 *
 * All rights reserved.
 *
 * This software is the confidential and proprietary information
 * of Intland Software. ("Confidential Information"). You
 * shall not disclose such Confidential Information and shall use
 * it only in accordance with the terms of the license agreement
 * you entered into with Intland.
 *
 */

jQuery(function($) {
    
    var resize = function(editor) {
        var $window = $(window),
            existingHeight = $(editor).height(),
            windowHeight = $window.height(),
            bodyHeight = $(editor).closest('body').height(),
            otherElementsHeight = bodyHeight - existingHeight,
            windowWidth = $window.width();
        
        $(editor).height(windowHeight - otherElementsHeight);
        $(editor).width((windowWidth - $(editor).position().left) - (windowWidth * 0.05));
    }
    
    $(".code-editor textarea").each(function(index, element) {
        var parent = $(element).parent();
        parent.removeClass("offscreen");

        var dataAttributes = $(element).data();
        dataAttributes.gutters = [];
        
        if(dataAttributes["lint"]) {
            dataAttributes.gutters.push("CodeMirror-lint-markers");
        }
        
        if(dataAttributes["lineNumbers"]) {
            dataAttributes.gutters.push("CodeMirror-linenumbers");
        }

        if(dataAttributes["foldGutter"]) {
            dataAttributes.gutters.push("CodeMirror-foldgutter");
        }
        
        var editor = CodeMirror.fromTextArea(element, dataAttributes);
        
        if(dataAttributes["autoResize"]) {
            resize(parent);
            
            if ($(element).data()["autoRefresh"] == true) {     
                $(window).resize(throttleWrapper(function() {
                    resize(parent);
                    editor.refresh();
                }));
            }
        }
        
    });
    
});
