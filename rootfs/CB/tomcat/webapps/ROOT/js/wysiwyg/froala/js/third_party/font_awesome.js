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

  

  // Extend defaults.
  $.extend($.FE.DEFAULTS, {
    fontAwesomeTemplate: '<i class="fa fa-[NAME] fr-deletable" aria-hidden="true">&nbsp;</i>',
    fontAwesomeSets: [
      {
        title: 'Web Application Icons',
        list: ['address-book', 'address-book-o', 'address-card', 'address-card-o', 'adjust', 'american-sign-language-interpreting', 'anchor', 'archive', 'area-chart', 'arrows', 'arrows-h', 'arrows-v', 'asl-interpreting ', 'assistive-listening-systems', 'asterisk', 'at', 'audio-description', 'automobile ', 'balance-scale', 'ban', 'bank ', 'bar-chart', 'bar-chart-o ', 'barcode', 'bars', 'bath', 'bathtub ', 'battery ', 'battery-0 ', 'battery-1 ', 'battery-2 ', 'battery-3 ', 'battery-4 ', 'battery-empty', 'battery-full', 'battery-half', 'battery-quarter', 'battery-three-quarters', 'bed', 'beer', 'bell', 'bell-o', 'bell-slash', 'bell-slash-o', 'bicycle', 'binoculars', 'birthday-cake', 'blind', 'bluetooth', 'bluetooth-b', 'bolt', 'bomb', 'book', 'bookmark', 'bookmark-o', 'braille', 'briefcase', 'bug', 'building', 'building-o', 'bullhorn', 'bullseye', 'bus', 'cab ', 'calculator', 'calendar', 'calendar-check-o', 'calendar-minus-o', 'calendar-o', 'calendar-plus-o', 'calendar-times-o', 'camera', 'camera-retro', 'car', 'caret-square-o-down', 'caret-square-o-left', 'caret-square-o-right', 'caret-square-o-up', 'cart-arrow-down', 'cart-plus', 'cc', 'certificate', 'check', 'check-circle', 'check-circle-o', 'check-square', 'check-square-o', 'child', 'circle', 'circle-o', 'circle-o-notch', 'circle-thin', 'clock-o', 'clone', 'close ', 'cloud', 'cloud-download', 'cloud-upload', 'code', 'code-fork', 'coffee', 'cog', 'cogs', 'comment', 'comment-o', 'commenting', 'commenting-o', 'comments', 'comments-o', 'compass', 'copyright', 'creative-commons', 'credit-card', 'credit-card-alt', 'crop', 'crosshairs', 'cube', 'cubes', 'cutlery', 'dashboard ', 'database', 'deaf', 'deafness ', 'desktop', 'diamond', 'dot-circle-o', 'download', 'drivers-license ', 'drivers-license-o ', 'edit ', 'ellipsis-h', 'ellipsis-v', 'envelope', 'envelope-o', 'envelope-open', 'envelope-open-o', 'envelope-square', 'eraser', 'exchange', 'exclamation', 'exclamation-circle', 'exclamation-triangle', 'external-link', 'external-link-square', 'eye', 'eye-slash', 'eyedropper', 'fax', 'feed ', 'female', 'fighter-jet', 'file-archive-o', 'file-audio-o', 'file-code-o', 'file-excel-o', 'file-image-o', 'file-movie-o ', 'file-pdf-o', 'file-photo-o ', 'file-picture-o ', 'file-powerpoint-o', 'file-sound-o ', 'file-video-o', 'file-word-o', 'file-zip-o ', 'film', 'filter', 'fire', 'fire-extinguisher', 'flag', 'flag-checkered', 'flag-o', 'flash ', 'flask', 'folder', 'folder-o', 'folder-open', 'folder-open-o', 'frown-o', 'futbol-o', 'gamepad', 'gavel', 'gear ', 'gears ', 'gift', 'glass', 'globe', 'graduation-cap', 'group ', 'hand-grab-o ', 'hand-lizard-o', 'hand-paper-o', 'hand-peace-o', 'hand-pointer-o', 'hand-rock-o', 'hand-scissors-o', 'hand-spock-o', 'hand-stop-o ', 'handshake-o', 'hard-of-hearing ', 'hashtag', 'hdd-o', 'headphones', 'heart', 'heart-o', 'heartbeat', 'history', 'home', 'hotel ', 'hourglass', 'hourglass-1 ', 'hourglass-2 ', 'hourglass-3 ', 'hourglass-end', 'hourglass-half', 'hourglass-o', 'hourglass-start', 'i-cursor', 'id-badge', 'id-card', 'id-card-o', 'image ', 'inbox', 'industry', 'info', 'info-circle', 'institution ', 'key', 'keyboard-o', 'language', 'laptop', 'leaf', 'legal ', 'lemon-o', 'level-down', 'level-up', 'life-bouy ', 'life-buoy ', 'life-ring', 'life-saver ', 'lightbulb-o', 'line-chart', 'location-arrow', 'lock', 'low-vision', 'magic', 'magnet', 'mail-forward ', 'mail-reply ', 'mail-reply-all ', 'male', 'map', 'map-marker', 'map-o', 'map-pin', 'map-signs', 'meh-o', 'microchip', 'microphone', 'microphone-slash', 'minus', 'minus-circle', 'minus-square', 'minus-square-o', 'mobile', 'mobile-phone ', 'money', 'moon-o', 'mortar-board ', 'motorcycle', 'mouse-pointer', 'music', 'navicon ', 'newspaper-o', 'object-group', 'object-ungroup', 'paint-brush', 'paper-plane', 'paper-plane-o', 'paw', 'pencil', 'pencil-square', 'pencil-square-o', 'percent', 'phone', 'phone-square', 'photo ', 'picture-o', 'pie-chart', 'plane', 'plug', 'plus', 'plus-circle', 'plus-square', 'plus-square-o', 'podcast', 'power-off', 'print', 'puzzle-piece', 'qrcode', 'question', 'question-circle', 'question-circle-o', 'quote-left', 'quote-right', 'random', 'recycle', 'refresh', 'registered', 'remove ', 'reorder ', 'reply', 'reply-all', 'retweet', 'road', 'rocket', 'rss', 'rss-square', 's15 ', 'search', 'search-minus', 'search-plus', 'send ', 'send-o ', 'server', 'share', 'share-alt', 'share-alt-square', 'share-square', 'share-square-o', 'shield', 'ship', 'shopping-bag', 'shopping-basket', 'shopping-cart', 'shower', 'sign-in', 'sign-language', 'sign-out', 'signal', 'signing ', 'sitemap', 'sliders', 'smile-o', 'snowflake-o', 'soccer-ball-o ', 'sort', 'sort-alpha-asc', 'sort-alpha-desc', 'sort-amount-asc', 'sort-amount-desc', 'sort-asc', 'sort-desc', 'sort-down ', 'sort-numeric-asc', 'sort-numeric-desc', 'sort-up ', 'space-shuttle', 'spinner', 'spoon', 'square', 'square-o', 'star', 'star-half', 'star-half-empty ', 'star-half-full ', 'star-half-o', 'star-o', 'sticky-note', 'sticky-note-o', 'street-view', 'suitcase', 'sun-o', 'support ', 'tablet', 'tachometer', 'tag', 'tags', 'tasks', 'taxi', 'television', 'terminal', 'thermometer ', 'thermometer-0 ', 'thermometer-1 ', 'thermometer-2 ', 'thermometer-3 ', 'thermometer-4 ', 'thermometer-empty', 'thermometer-full', 'thermometer-half', 'thermometer-quarter', 'thermometer-three-quarters', 'thumb-tack', 'thumbs-down', 'thumbs-o-down', 'thumbs-o-up', 'thumbs-up', 'ticket', 'times', 'times-circle', 'times-circle-o', 'times-rectangle ', 'times-rectangle-o ', 'tint', 'toggle-down ', 'toggle-left ', 'toggle-off', 'toggle-on', 'toggle-right ', 'toggle-up ', 'trademark', 'trash', 'trash-o', 'tree', 'trophy', 'truck', 'tty', 'tv ', 'umbrella', 'universal-access', 'university', 'unlock', 'unlock-alt', 'unsorted ', 'upload', 'user', 'user-circle', 'user-circle-o', 'user-o', 'user-plus', 'user-secret', 'user-times', 'users', 'vcard ', 'vcard-o ', 'video-camera', 'volume-control-phone', 'volume-down', 'volume-off', 'volume-up', 'warning ', 'wheelchair', 'wheelchair-alt', 'wifi', 'window-close', 'window-close-o', 'window-maximize', 'window-minimize', 'window-restore', 'wrench']
      },
      {
        title: 'Accessibility Icons',
        list: ['american-sign-language-interpreting', 'asl-interpreting ', 'assistive-listening-systems', 'audio-description', 'blind', 'braille', 'cc', 'deaf', 'deafness ', 'hard-of-hearing ', 'low-vision', 'question-circle-o', 'sign-language', 'signing ', 'tty', 'universal-access', 'volume-control-phone', 'wheelchair', 'wheelchair-alt']
      },
      {
        title: 'Hand Icons',
        list: ['hand-grab-o ', 'hand-lizard-o', 'hand-o-down', 'hand-o-left', 'hand-o-right', 'hand-o-up', 'hand-paper-o', 'hand-peace-o', 'hand-pointer-o', 'hand-rock-o', 'hand-scissors-o', 'hand-spock-o', 'hand-stop-o ', 'thumbs-down', 'thumbs-o-down', 'thumbs-o-up', 'thumbs-up']
      },
      {
        title: 'Transportation Icons',
        list: ['ambulance', 'automobile ', 'bicycle', 'bus', 'cab ', 'car', 'fighter-jet', 'motorcycle', 'plane', 'rocket', 'ship', 'space-shuttle', 'subway', 'taxi', 'train', 'truck', 'wheelchair', 'wheelchair-alt']
      },
      {
        title: 'Gender Icons',
        list: ['genderless', 'intersex ', 'mars', 'mars-double', 'mars-stroke', 'mars-stroke-h', 'mars-stroke-v', 'mercury', 'neuter', 'transgender', 'transgender-alt', 'venus', 'venus-double', 'venus-mars']
      },
      {
        title: 'Form Control Icons',
        list: ['check-square', 'check-square-o', 'circle', 'circle-o', 'dot-circle-o', 'minus-square', 'minus-square-o', 'plus-square', 'plus-square-o', 'square', 'square-o']
      },
      {
        title: 'Payment Icons',
        list: ['cc-amex', 'cc-diners-club', 'cc-discover', 'cc-jcb', 'cc-mastercard', 'cc-paypal', 'cc-stripe', 'cc-visa', 'credit-card', 'credit-card-alt', 'google-wallet', 'paypal']
      },
      {
        title: 'Chart Icons',
        list: ['area-chart', 'bar-chart', 'bar-chart-o ', 'line-chart', 'pie-chart']
      },
      {
        title: 'Currency Icons',
        list: ['bitcoin ', 'btc', 'cny ', 'dollar ', 'eur', 'euro ', 'gbp', 'gg', 'gg-circle', 'ils', 'inr', 'jpy', 'krw', 'money', 'rmb ', 'rouble ', 'rub', 'ruble ', 'rupee ', 'shekel ', 'sheqel ', 'try', 'turkish-lira ', 'usd', 'viacoin', 'won ', 'yen']
      },
      {
        title: 'Text Editor Icons',
        list: ['align-center', 'align-justify', 'align-left', 'align-right', 'bold', 'chain ', 'chain-broken', 'clipboard', 'columns', 'copy ', 'cut ', 'dedent ', 'eraser', 'file', 'file-o', 'file-text', 'file-text-o', 'files-o', 'floppy-o', 'font', 'header', 'indent', 'italic', 'link', 'list', 'list-alt', 'list-ol', 'list-ul', 'outdent', 'paperclip', 'paragraph', 'paste ', 'repeat', 'rotate-left ', 'rotate-right ', 'save ', 'scissors', 'strikethrough', 'subscript', 'superscript', 'table', 'text-height', 'text-width', 'th', 'th-large', 'th-list', 'underline', 'undo', 'unlink']
      },
      {
        title: 'Brand Icons',
        list: ['500px', 'adn', 'amazon', 'android', 'angellist', 'apple', 'bandcamp', 'behance', 'behance-square', 'bitbucket', 'bitbucket-square', 'bitcoin ', 'black-tie', 'bluetooth', 'bluetooth-b', 'btc', 'buysellads', 'cc-amex', 'cc-diners-club', 'cc-discover', 'cc-jcb', 'cc-mastercard', 'cc-paypal', 'cc-stripe', 'cc-visa', 'chrome', 'codepen', 'codiepie', 'connectdevelop', 'contao', 'css3', 'dashcube', 'delicious', 'deviantart', 'digg', 'dribbble', 'dropbox', 'drupal', 'edge', 'eercast', 'empire', 'envira', 'etsy', 'expeditedssl', 'fa ', 'facebook', 'facebook-f ', 'facebook-official', 'facebook-square', 'firefox', 'first-order', 'flickr', 'font-awesome', 'fonticons', 'fort-awesome', 'forumbee', 'foursquare', 'free-code-camp', 'ge ', 'get-pocket', 'gg', 'gg-circle', 'git', 'git-square', 'github', 'github-alt', 'github-square', 'gitlab', 'gittip ', 'glide', 'glide-g', 'google', 'google-plus', 'google-plus-circle ', 'google-plus-official', 'google-plus-square', 'google-wallet', 'gratipay', 'grav', 'hacker-news', 'houzz', 'html5', 'imdb', 'instagram', 'internet-explorer', 'ioxhost', 'joomla', 'jsfiddle', 'lastfm', 'lastfm-square', 'leanpub', 'linkedin', 'linkedin-square', 'linode', 'linux', 'maxcdn', 'meanpath', 'medium', 'meetup', 'mixcloud', 'modx', 'odnoklassniki', 'odnoklassniki-square', 'opencart', 'openid', 'opera', 'optin-monster', 'pagelines', 'paypal', 'pied-piper', 'pied-piper-alt', 'pied-piper-pp', 'pinterest', 'pinterest-p', 'pinterest-square', 'product-hunt', 'qq', 'quora', 'ra ', 'ravelry', 'rebel', 'reddit', 'reddit-alien', 'reddit-square', 'renren', 'resistance ', 'safari', 'scribd', 'sellsy', 'share-alt', 'share-alt-square', 'shirtsinbulk', 'simplybuilt', 'skyatlas', 'skype', 'slack', 'slideshare', 'snapchat', 'snapchat-ghost', 'snapchat-square', 'soundcloud', 'spotify', 'stack-exchange', 'stack-overflow', 'steam', 'steam-square', 'stumbleupon', 'stumbleupon-circle', 'superpowers', 'telegram', 'tencent-weibo', 'themeisle', 'trello', 'tripadvisor', 'tumblr', 'tumblr-square', 'twitch', 'twitter', 'twitter-square', 'usb', 'viacoin', 'viadeo', 'viadeo-square', 'vimeo', 'vimeo-square', 'vine', 'vk', 'wechat ', 'weibo', 'weixin', 'whatsapp', 'wikipedia-w', 'windows', 'wordpress', 'wpbeginner', 'wpexplorer', 'wpforms', 'xing', 'xing-square', 'y-combinator', 'y-combinator-square ', 'yahoo', 'yc ', 'yc-square ', 'yelp', 'yoast', 'youtube', 'youtube-play', 'youtube-square']
      }
    ]
  });

  $.FE.PLUGINS.fontAwesome = function (editor) {
    var $modal;
    var modal_id = 'font_awesome';

    var $head;
    var $body;

    /*
     * Init Font Awesome.
     */
    function _init () {

    }

    /*
     * Build html body.
     */
    function _buildBody () {

      // Begin body.
      var body = '<div class="fr-font-awesome-modal">';

      for (var k = 0; k < editor.opts.fontAwesomeSets.length; k++) {
        var set = editor.opts.fontAwesomeSets[k];
        var list = set.list;

        // Add title.
        var html_list = '<div class="fr-font-awesome-list"><p class="fr-font-awesome-title">' + editor.language.translate(set.title) + '</p>';

        for (var i = 0; i < list.length; i++) {
          var item = list[i];
          html_list += '<span class="fr-command fr-font-awesome" tabIndex="-1" role="button" value="' + item + '">' + editor.opts.fontAwesomeTemplate.replace(/\[NAME\]/g, item) + '<span class="fr-sr-only">' + editor.language.translate('Example of') + item + '&nbsp;&nbsp;&nbsp;</span></span>';

        }

        // Add list to body.
        body += html_list + '</div>';
      }

      // End body.
      body += '</div>';

      return body;
    }

    /*
     * Focus a font awesome.
     */
    function _focusChar ($char, e) {

      editor.events.disableBlur();
      $char.focus();

      e.preventDefault();
      e.stopPropagation();
    }

    function _addAccessibility () {

      // Keydown handler.
      editor.events.$on($body, 'keydown', function (e) {
        var keycode = e.which;
        var $focused_char = $body.find('span.fr-font-awesome:focus:first');

        // Alt + F10.
        if (!$focused_char.length && keycode == $.FE.KEYCODE.F10 && !editor.keys.ctrlKey(e) && !e.shiftKey && e.altKey) {

          // Focus first character.
          var $char = $body.find('span.fr-font-awesome:first');
          _focusChar($char, e);

          return false;
        }

        // Tab and arrows.
        else if (keycode == $.FE.KEYCODE.TAB || keycode == $.FE.KEYCODE.ARROW_LEFT || keycode == $.FE.KEYCODE.ARROW_RIGHT) {

          // The next char that will get focused.
          var $next_char = null;

          // Forward of backward.
          var forward = null;

          // Arrow or Tab.
          var isArrow = false;

          if (keycode == $.FE.KEYCODE.ARROW_LEFT || keycode == $.FE.KEYCODE.ARROW_RIGHT) {
            forward = keycode == $.FE.KEYCODE.ARROW_RIGHT;
            isArrow = true;
          }
          else {
            forward = !e.shiftKey;
          }

          if ($focused_char.length) {

            // Next or previous char from a category. Only if arrow are used.
            if (isArrow) {
              if (forward) {
                $next_char = $focused_char.nextAll('span.fr-font-awesome:first');
              }
              else {
                $next_char = $focused_char.prevAll('span.fr-font-awesome:first');
              }
            }

            // First or last char reached within a category. Or Tab is used.
            if (!$next_char || !$next_char.length) {

              // First or last char from next or previous category.
              if (forward) {
                $next_char = $focused_char.parent().next().find('span.fr-font-awesome:first');
              }
              else {
                $next_char = $focused_char.parent().prev().find('span.fr-font-awesome:' + (isArrow ? 'last' : 'first'));
              }

              // First or last category reached.
              if (!$next_char.length) {

                // First category and first char or last category and last char.
                $next_char = $body.find('span.fr-font-awesome:' + (forward ? 'first' : 'last'));
              }
            }
          }

          // First category and first char or last category and last char.
          else {
            $next_char = $body.find('span.fr-font-awesome:' + (forward ? 'first' : 'last'));
          }
          _focusChar($next_char, e);

          return false;
        }

        // Enter on a focused item.
        else if (keycode == $.FE.KEYCODE.ENTER && $focused_char.length) {
          var instance = $modal.data('instance') || editor;

          instance.fontAwesome.insert($focused_char);
        }
        else {

          return true;
        }
      }, true);
    }

    /*
     * Show Font Awesome.
     */
    function show () {
      if (!$modal) {
        var head = '<h4>' + editor.language.translate('Font Awesome') + '</h4>';
        var body = _buildBody();
        var modalHash = editor.modals.create(modal_id, head, body);
        $modal = modalHash.$modal;
        $head = modalHash.$head;
        $body = modalHash.$body;

        // Resize Font Awesome modal on window resize.
        editor.events.$on($(editor.o_win), 'resize', function () {
          var instance = $modal.data('instance') || editor;

          instance.modals.resize(modal_id);
        });

        // Insert image.
        editor.events.bindClick($body, '.fr-font-awesome', function (e) {
          var instance = $modal.data('instance') || editor;
          var $target = $(e.currentTarget);

          instance.fontAwesome.insert($target);
        });

        _addAccessibility();
      }


      // Show modal.
      editor.modals.show(modal_id);

      // Modal may not fit window size.
      editor.modals.resize(modal_id);
    }

    /*
     * Hide font awesome.
     */
    function hide () {
      editor.modals.hide(modal_id);
    }

    /*
     * Insert font awesome.
     */
    function insert($target) {

      // Hide modal.
      editor.fontAwesome.hide();

      // Insert character.
      editor.undo.saveStep();
      editor.html.insert(editor.opts.fontAwesomeTemplate.replace(/\[NAME\]/g, $target.attr('value')), true);
      editor.undo.saveStep();
    }

    return {
      _init: _init,
      show: show,
      hide: hide,
      insert: insert
    };
  };

  $.FroalaEditor.DefineIcon('fontAwesome', {
    NAME: 'font-awesome'
  })

  $.FE.RegisterCommand('fontAwesome', {
    title: 'Font Awesome',
    icon: 'fontAwesome',
    undo: false,
    focus: false,
    modal: true,
    callback: function () {
      this.fontAwesome.show();
    },
    plugin: 'fontAwesome',
    showOnMobile: true
  });

}));
