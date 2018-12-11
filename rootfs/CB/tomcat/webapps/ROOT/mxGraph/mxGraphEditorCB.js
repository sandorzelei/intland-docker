/**
 * Copyright by Intland Software
 *
 * All rights reserved.
 *
 * This software is the confidential and proprietary information
 * of Intland Software. ("Confidential Information"). You
 * shall not disclose such Confidential Information and shall use
 * it only in accordance with the terms of the license agreement
 * you entered into with Intland.
 */
function getContainerPluginSourceBlock(selectedNode) {
	return $(selectedNode).closest('.pluginSource');
}

/**
 * Use this method to generate hash.
 *
 * @param str is a string
 * @returns hash
 */
function hash(str) {
	var i, l,
	hval = 0x811c9dc5;

	for (i = 0, l = str.length; i < l; i++) {
		hval ^= str.charCodeAt(i);
		hval += (hval << 1) + (hval << 4) + (hval << 7) + (hval << 8) + (hval << 24);
	}
	return hval >>> 0;
}
