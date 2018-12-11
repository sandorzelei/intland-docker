/*!
 * froala_editor v2.9.0 (https://www.froala.com/wysiwyg-editor)
 * License https://froala.com/wysiwyg-editor/terms/
 * Copyright 2014-2018 Froala Labs
 */

(function (factory) {
    if (typeof define === 'function' && define.amd) {
        // AMD. Register as an anonymous module.
        define(['jquery'], factory);
    } else if (typeof module === 'object' && module.exports) {
        // Node/CommonJS
        module.exports = function( root, jQuery ) {
            if ( jQuery === undefined ) {
                // require('jQuery') returns a factory that requires window to
                // build a jQuery instance, we normalize how we use modules
                // that require this pattern but the window provided is a noop
                // if it's defined (how jquery works)
                if ( typeof window !== 'undefined' ) {
                    jQuery = require('jquery');
                }
                else {
                    jQuery = require('jquery')(root);
                }
            }
            return factory(jQuery);
        };
    } else {
        // Browser globals
        factory(window.jQuery);
    }
}(function ($) {

  

  $.extend($.FE.DEFAULTS, {
    inlineClasses: {
      'fr-class-code': 'Code',
      'fr-class-highlighted': 'Highlighted',
      'fr-class-transparency': 'Transparent'
    }
  });

  $.FE.PLUGINS.inlineClass = function (editor) {
    function apply (val) {
      editor.format.toggle('span', { 'class': val });
    }

    function refreshOnShow($btn, $dropdown) {
      $dropdown.find('.fr-command').each (function () {
        var val = $(this).data('param1');
        var active = editor.format.is('span', { 'class': val });
        $(this).toggleClass('fr-active', active).attr('aria-selected', active);
      })
    }

    return {
      apply: apply,
      refreshOnShow: refreshOnShow
    }
  };

  // Register the inlineClass size command.
  $.FE.RegisterCommand('inlineClass', {
    type: 'dropdown',
    title: 'Inline Class',
    html: function () {
      var c = '<ul class="fr-dropdown-list" role="presentation">';
      var options = this.opts.inlineClasses;

      for (var val in options) {
        if (options.hasOwnProperty(val)) {
          c += '<li role="presentation"><a class="fr-command" tabIndex="-1" role="option" data-cmd="inlineClass" data-param1="' + val + '" title="' + options[val] + '">' + options[val] + '</a></li>';
        }
      }
      c += '</ul>';

      return c;
    },
    callback: function (cmd, val) {
      this.inlineClass.apply(val);
    },
    refreshOnShow: function ($btn, $dropdown) {
      this.inlineClass.refreshOnShow($btn, $dropdown);
    },
    plugin: 'inlineClass'
  });

  // Add the inlineClass icon.
  $.FE.DefineIcon('inlineClass', {
    NAME: 'tag'
  });

}));
