/*
 * Copyright by Intland Software
 *
 * All rights reserved.
 *
 * This is an extended/improved version of https://www.npmjs.com/package/jquery.ajaxq, with the following additions
 * - Fixed obsolete java script code
 * - Allow to create new running (default) or stopped Queues
 * - Allow to explicitly start and stop a Queue.
 * - Allow to clear queue (remove pending requests), optionally with also cancelling already running requests
 *
 * This software is the confidential and proprietary information
 * of Intland Software. ("Confidential Information"). You
 * shall not disclose such Confidential Information and shall use
 * it only in accordance with the terms of the license agreement
 * you entered into with Intland.
 */

(function($) {
	'use strict';


	var Request = (function (argument) {

	    function Request(url, settings) {
	    	this._settings  = $.isPlainObject(url) ? url : $.extend(true, settings || {}, {
				url : url
			});
	    	this._aborted   = false;
	    	this._jqXHR     = null;
	    	this._calls     = {};
	    	this._deferred  = $.Deferred();

	    	this._deferred.pipe = this._deferred.then;

	    	this.readyState = 1;
	    }

	    var proto = Request.prototype;

	    $.extend(proto, {

	    	// start jqXHR by calling $.ajax
	    	run : function() {
	    		if (this._jqXHR == null) {
		    		// create new jqXHR object
		    		var deferred = this._deferred;

		    		var jqXHR = $.ajax.call($, this._settings).done(function() {
		    			deferred.resolve.apply(deferred, arguments);
		    		}).fail(function() {
		    			deferred.reject.apply(deferred, arguments);
		    		});

		    		if (this._aborted) {
		    			jqXHR.abort(this.statusText);
		    		}

		    		// apply buffered calls
		    		$.each(this._calls, function(methodName, argsStack) {
		    			if ($.isFunction(jqXHR[methodName]) && $.isArray(argsStack)) {
		    				for (var i = 0; i < argsStack.length; ++i) {
		    					jqXHR[methodName].apply(jqXHR, argsStack[i]);
		    				}
		    			}
		    		});

		    		this._jqXHR = jqXHR;
	    		}

	    		return this._jqXHR;
	    	},

	    	// returns original jqXHR object if it exists or writes to collected method to _calls and returns itself
	    	_call : function(methodName, args) {
	    		if (this._jqXHR !== null) {
	    			if ($.isFunction(this._jqXHR[methodName])) {
		    			return this._jqXHR[methodName].apply(this._jqXHR, args);

	    			}

	    			return this._jqXHR;
	    		}

	    		this._calls[methodName] = this._calls[methodName] || [];
	    		this._calls[methodName].push(args);

	    		return this;
	    	},

	    	// returns original jqXHR object if it exists or writes to collected method to _calls and returns itself
	    	abort : function(statusText) {
	    		if (this._jqXHR !== null) {
	    			var _return = this._jqXHR.abort.apply(this._jqXHR, arguments) || this._jqXHR;
 	    			if (_return) {
		    			var props = ['readyState', 'status', 'statusText'];

		    			for (var i = 0; i < props.length; ++i) {
		    				var prop = props[i];
		    				this[prop] = _return[prop];
		    			}
	    			}

	    			return _return;
	    		}

	    		this.statusText = statusText || 'abort';
	    		this.status     = 0;
	    		this.readyState = 0;
	    		this._aborted   = true;

	    		return this;
	    	},

	    	state : function() {
	    		if (this._jqXHR !== null) {
	    			return this._jqXHR.state.apply(this._jqXHR, arguments);
	    		}
	    		return 'pending';
	    	}
	    });

		var slice = Array.prototype.slice;

	    // each method returns self object
	    var _chainMethods = ['setRequestHeader', 'overrideMimeType', 'statusCode', 'done', 'fail', 'progress', 'complete', 'success', 'error', 'always' ];

	    $.each(_chainMethods, function(i, methodName) {
	    	proto[methodName] = function() {
	    		return this._call(methodName, slice.call(arguments)) || this._jqXHR;
	    	};
	    });

    	var _nullMethods = ['getResponseHeader', 'getAllResponseHeaders'];

    	$.each(_nullMethods, function(i, methodName) {
    		proto[methodName] = function() {
		        // apply original method if _jqXHR exists
		        if (this._jqXHR !== null) {
		        	return this._jqXHR[methodName].apply(this, arguments);
		        }

		        // return null if original method does not exists
		        return null;
    		};
    	});

    	var _promiseMethods = ['pipe', 'then', 'promise'];

	    $.each(_promiseMethods, function(i, methodName) {
	    	proto[methodName] = function() {
	    		return this._deferred[methodName].apply(this._deferred, arguments);
	    	};
	    });

    	return Request;
	})();


	var Queue = (function() {
		var _params = {}, _queueCounter = 0;

		function _runNext(queue, request) {
			var started = _getStarted(queue);

			if (request) {
				var removeIndex = started.indexOf(request);
			    if (removeIndex !== -1) {
			    	started.splice(removeIndex, 1);
			    }
			}

			if (_getRunning(queue)) {
				var pending   = _getPending(queue);
				var bandwidth = _getBandwidth(queue);

			    while (started.length < bandwidth) {
			    	var nextRequest = pending.shift();
			    	if (nextRequest) {
			    		started.push(nextRequest);
			    		nextRequest.always($.proxy(_runNext, null, queue, nextRequest)).run();
			    	} else {
			    		break;
			    	}
			    }
			}
		}

		function _ajax(queue, request) {
			var started = _getStarted(queue);
			if (started.length < _getBandwidth(queue)) {
				started.push(request);
		        request.always($.proxy(_runNext, null, queue, request)).run();
		    } else {
		        _getPending(queue).push(request)
		    }
		}

	    function _getParams(queue) {
	    	return _params[queue.id] || (_params[queue.id] = {});
	    }

	    function _getParam(queue, name) {
	    	return _getParams(queue)[name];
	    }

	    function _getStarted(queue) {
	    	return _getParams(queue).started || (_getParams(queue).started = []);
	    }

	    function _getPending(queue) {
	    	return _getParams(queue).pending || (_getParams(queue).pending = []);
	    }

	    function _setBandwidth(queue, bandwidth) {
	    	if ((bandwidth = parseInt(bandwidth || 1, 10)) < 1) {
	    		throw "Bandwidth can\'t be less then 1";
	    	}

	    	_getParams(queue).bandwidth = bandwidth;
	    	_runNext(queue);
	    }

	    function _getBandwidth(queue, bandwidth) {
	    	return _getParams(queue).bandwidth;
	    }

	    function _setRunning(queue, running) {
	    	_getParams(queue).running = (running === true);
	    	_runNext(queue);
	    }

	    function _getRunning(queue) {
	    	return _getParams(queue).running;
	    }

	    function Queue(bandwidth, active) {
	    	if (typeof bandwidth !== 'undefined' && !$.isNumeric(bandwidth)) {
	    		throw "number expected";
	    	}

	    	this.id = ++_queueCounter;

	    	_setBandwidth(this, bandwidth);
	    	_setRunning(this, !(active === false));
	    };

	    var proto = Queue.prototype;

	    $.extend(proto, {
	    	ajax : function(url, settings) {
	    		var request = new Request(url, settings);
	    		_ajax(this, request);
	    		return request;
	    	},

	    	getJSON : function ( url, data, callback ) {
	    		return this.get( url, data, callback, "json" );
	    	},

	    	getBandwidth : function() {
	    		return _getBandwidth(this);
	    	},

	    	hasBandwidth : function() {
	    		return _getRunning(queue) && _getStarted(queue).length < _getBandwidth(queue);
	    	},

	    	start : function() {
	    		_setRunning(this, true);
	    		return this;
	    	},

	    	stop : function() {
	    		_setRunning(this, false);
	    		return this;
	    	},

	    	active : function() {
	    		return _getRunning(this) ;
	    	},

	    	clear : function(cancel) {
    			var pending = _getPending(this);
    			if (pending.length > 0) {
    				pending.splice(0, pending.length);
    			}

    			if (cancel) {
	    			var started = _getStarted(this);
	    			if (started.length > 0) {
		    			var requests = started.splice(0, started.length);

		    			for (var i = 0; i < requests.length; ++i) {
		    				requests[i].abort(typeof cancel === "string" ? cancel : 'Cancelled');
		    			}
	    			}
    			}

	    		return this;
	    	}
	    });

	    $.each(['get', 'post'], function(i, method) {
	    	proto[method] = function( url, data, callback, type ) {
		        // shift arguments if data argument was omitted
		        if ($.isFunction(data)) {
		        	type = type || callback;
		        	callback = data;
		        	data = undefined;
		        }

		        return this.ajax({
		        	url		: url,
		        	type	: method,
		        	dataType: type,
		        	data	: data,
		        	succes	: callback
		        });
	    	};
	    });

	    return Queue;
	})();


	if (typeof $.ajaxq !== 'undefined') {
		throw "Namespace $.ajaxq is Already busy.";
	}

	var _queue = new Queue();

	$.ajaxq = function(url, settions) {
		return _queue.ajax.apply(_queue, arguments);
	};

	$.each(['get', 'post', 'getJSON'], function(i, methodName) {
		$.ajaxq[methodName] = function() {
			return _queue[methodName].apply(_queue, arguments);
		};
	});

	$.ajaxq.Queue = function(bandwidth, active) {
		return new Queue(bandwidth, active);
	};

	$.ajaxq.Request = function(url, settings) {
		return new Request(url, settings);
	};

})(jQuery);