var I18n = I18n || {
	cache: null,
	
	t: function(key, vars, locale) {
		if (!I18n.cache) {
			I18n.cache = JSON.parse(document.getElementById('lingua-franca-translations').innerHTML);
		}
		vars = vars || {}
		var sub_keys = key.split('.');
		var result = I18n.cache[locale || I18n.locale()];
		window._result = result;
		forEach(sub_keys, function(sub_key) {
			result = result[sub_key];
		});
		window.__result = result;
		if (vars.count !== undefined && typeof result === "object") {
			if (vars.count === 0 && result.zero !== undefined) {
				result = result.zero;
			} else if (vars.count === 1 && result.one !== undefined) {
				result = result.one;
			} else {
				result = result.other;
			}
		}
		window.___result = result;
		forEach(Object.keys(vars), function(var_key) {
			result = result.split("%{" + var_key + "}").join(vars[var_key]);
		});
		return result;
	},

	locale: function(element) {
		return (element || document.getElementsByTagName('HTML')[0]).getAttribute('lang') || 'en';
	}
};
