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
    lineHeights: {
      Default: '',
      Single: '1',
      '1.15': '1.15',
      '1.5': '1.5',
      Double: '2'
    }
  });

  $.FE.PLUGINS.lineHeight = function (editor) {
    /**
     * Apply style.
     */
    function apply (val) {
      editor.selection.save();
      editor.html.wrap(true, true, true, true);
      editor.selection.restore();

      var blocks = editor.selection.blocks();

      // Save selection to restore it later.
      editor.selection.save();

      for (var i = 0; i < blocks.length; i++) {
        $(blocks[i]).css('line-height', val)

        if ($(blocks[i]).attr('style') === '') {
          $(blocks[i]).removeAttr('style');
        }
      }

      // Unwrap temp divs.
      editor.html.unwrap();

      // Restore selection.
      editor.selection.restore();
    }

    function refreshOnShow($btn, $dropdown) {
      var blocks = editor.selection.blocks();

      if (blocks.length) {
        var $blk = $(blocks[0]);

        $dropdown.find('.fr-command').each (function () {
          var lineH = $(this).data('param1');
          var active = ($blk.attr('style') || '').indexOf('line-height: ' + lineH + ';') >= 0;
          $(this).toggleClass('fr-active', active).attr('aria-selected', active);
        })
      }
    }

    function _init () {
    }

    return {
      _init: _init,
      apply: apply,
      refreshOnShow: refreshOnShow
    }
  }

  // Register the font size command.
  $.FE.RegisterCommand('lineHeight', {
    type: 'dropdown',
    html: function () {
      var c = '<ul class="fr-dropdown-list" role="presentation">';
      var options =  this.opts.lineHeights;

      for (var val in options) {
        if (options.hasOwnProperty(val)) {
          c += '<li role="presentation"><a class="fr-command ' + val + '" tabIndex="-1" role="option" data-cmd="lineHeight" data-param1="' + options[val] + '" title="' + this.language.translate(val) + '">' + this.language.translate(val) + '</a></li>';
        }
      }
      c += '</ul>';

      return c;
    },
    title: 'Line Height',
    callback: function (cmd, val) {
      this.lineHeight.apply(val);
    },
    refreshOnShow: function ($btn, $dropdown) {
      this.lineHeight.refreshOnShow($btn, $dropdown);
    },
    plugin: 'lineHeight'
  })

  // Add the font size icon.
  $.FE.DefineIcon('lineHeight', {
    NAME: 'arrows-v'
  });

}));
