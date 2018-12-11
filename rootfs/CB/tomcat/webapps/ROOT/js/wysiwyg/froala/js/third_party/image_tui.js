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
    imageTUIOptions: {
      includeUI: {
        theme: {
          // main icons
          'menu.normalIcon.path': 'https://cdn.jsdelivr.net/npm/tui-image-editor@3.2.2/dist/svg/icon-d.svg',
          'menu.activeIcon.path': 'https://cdn.jsdelivr.net/npm/tui-image-editor@3.2.2/dist/svg/icon-b.svg',
          'menu.disabledIcon.path': 'https://cdn.jsdelivr.net/npm/tui-image-editor@3.2.2/dist/svg/icon-a.svg',
          'menu.hoverIcon.path': 'https://cdn.jsdelivr.net/npm/tui-image-editor@3.2.2/dist/svg/icon-c.svg',

          // submenu icons
          'submenu.normalIcon.path': 'https://cdn.jsdelivr.net/npm/tui-image-editor@3.2.2/dist/svg/icon-d.svg',
          'submenu.normalIcon.name': 'icon-d',
          'submenu.activeIcon.path': 'https://cdn.jsdelivr.net/npm/tui-image-editor@3.2.2/dist/svg/icon-c.svg',
          'submenu.activeIcon.name': 'icon-c'
        },
        initMenu: 'filter',
        menuBarPosition: 'left'
      }
    },
    tui: window.tui
  });

  $.FE.PLUGINS.imageTUI = function (editor) {
    var current_image;

    function _init () {
      var body = editor.o_doc.body;

      var tuiContainer = editor.o_doc.createElement('div');
      tuiContainer.setAttribute('id', 'tuiContainer');
      tuiContainer.style.cssText = "position: fixed; top: 0;left: 0;margin: 0;padding: 0;width: 100%;height: 100%;background: rgba(0,0,0,.5);z-index: 9998;display:none";
      body.appendChild(tuiContainer);
    }

    function launch(instance) {
      if (typeof editor.opts.tui === 'object') {
        var body = editor.o_doc.body;
        var tuiEditorContainerDiv = editor.o_doc.createElement('div');
        tuiEditorContainerDiv.setAttribute('id', 'tuieditor');

        var popupContainer = editor.o_doc.getElementById("tuiContainer");
        popupContainer.appendChild(tuiEditorContainerDiv);
        popupContainer.style.display = "block";

        var current_image = instance.image.get();

        var opts = editor.opts.imageTUIOptions;
        opts.includeUI.loadImage = {
          path: current_image[0].src,
          name: ' '
        }

        var tuiEditorObject = new editor.opts.tui.ImageEditor(editor.o_doc.querySelector('#tuieditor'), opts);

        var canvasContainer = editor.o_doc.getElementById('tuieditor');
        canvasContainer.style.minHeight = (300 + 290) + "px";
        canvasContainer.style.width = "94%";
        canvasContainer.style.height = "94%";
        canvasContainer.style.margin = "auto";

        $(".tui-image-editor-header-buttons").html(
          '<button class="tui-editor-cancel-btn" data-cmd="cancel_tui_image">Cancel</button> <button class="tui-editor-save-btn">Save</button>'
        );

        $(".tui-editor-cancel-btn").click(function (e) {
          destroyTuiEditor(popupContainer);
        });

        $(".tui-editor-save-btn").click(function (e) {
          saveTuiImage(tuiEditorObject, instance, current_image);
          destroyTuiEditor(popupContainer);
        });

      }

    }

    function destroyTuiEditor(container) {
      $("#tuieditor").remove();
      container.style.display = "none";
    }

    function saveTuiImage(tuiEditorObject, instance, current_image) {
      var savedImg = tuiEditorObject.toDataURL();
      var binary = atob(savedImg.split(',')[1]);
      var array = [];

      for (var i = 0; i < binary.length; i++) {
        array.push(binary.charCodeAt(i));
      }
      var upload_img = new Blob([new Uint8Array(array)], {
        type: 'image/png'
      });

      instance.image.edit($(current_image));
      instance.image.upload([upload_img]);
    }

    return {
      _init: _init,
      launch: launch
    }

  };

  $.FE.DefineIcon('imageTUI', {
    NAME: 'sliders',
    FA5NAME: 'sliders-h'
  });

  $.FE.RegisterCommand('imageTUI', {
    title: 'Advanced Edit',
    undo: false,
    focus: false,
    callback: function (cmd, val) {
      this.imageTUI.launch(this);
    },
    plugin: 'imageTUI'
  });

  // Look for image plugin.
  if (!$.FE.PLUGINS.image) {
    throw new Error('TUI image editor plugin requires image plugin.');
  }

  $.FE.DEFAULTS.imageEditButtons.push('imageTUI');

}));
