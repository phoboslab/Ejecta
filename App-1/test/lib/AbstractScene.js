
;(function(scope, undefined) {
'use strict';

	scope.AbstractScene = {

		init : function(game) {
			throw new Error(" ** MUST ** Implement me. ");
		},

		beforeRun : function(game) {
			throw new Error(" Implement or Remove me. ");
		},

		update : function(timeStep) {
			throw new Error(" ** MUST ** Implement me. ");
		},

		render : function(context, timeStep) {
			throw new Error(" ** MUST ** Implement me. ");
		},

		handleInput : function(game) {
			throw new Error(" Implement or Remove me. ");
		},

		destructor : function(game) {
			throw new Error(" Implement or Remove me. ");
		}

	}

}(this));

