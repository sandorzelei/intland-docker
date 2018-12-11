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
    
    var $form = $('form.js-configuration-form');
    if($form.length == 0) {
        return;
    }
    
    var submitActor = null;
    var $submitActors = $form.find('input[type=submit]');

    $form.submit(function(event) {
        if (null === submitActor) {
            submitActor = $submitActors[0];
        }

        if(submitActor.name === '_select' || submitActor.name === '_cancel') {
            return true;
        }

        if(submitActor.name === '_save') {
            return confirm(i18n.message("sysadmin.configuration.confirm.save.message"));
        }
        
        if(submitActor.name === '_restore') {
            return confirm(i18n.message("sysadmin.configuration.confirm.restore.message"));
        }
       
        return false;
    });

    $submitActors.click(function(event) {
        submitActor = this;
    });
    
});
