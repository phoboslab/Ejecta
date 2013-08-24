
;(function(scope, undefined) {
'use strict';

	scope.ResourcePool = {
		cache: {},
		_count: 0,
		get: function(id, clone) {
			var res = this.cache[id] || null;
			if (clone && res != null) {
				res = res.cloneNode(true);
			}
			// id && console.log(id);
			return res;
		},
		add: function(id, res) {
			this.cache[id] = res;
			this._count++;
		},
		remove: function(id) {
			var res = this.cache[id];
			delete this.cache[id];
			if (scope.isDom(res)) {
				scope.removeDom(res);
			}
			this._count--;
		},
		clear: function() {
			for (var id in this.cache) {
				this.remove(id);
			}
			this.cache = {};
			this._count = 0;
		},
		size: function() {
			return this._count;
		}
	};
}(this));
