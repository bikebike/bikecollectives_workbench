function LinguaFrancaHighlightExample(_data) {
	var getPosition = function(element) {
		var xPosition = 0;
		var yPosition = 0;

		while(element) {
			xPosition += (element.offsetLeft - element.scrollLeft + element.clientLeft);
			yPosition += (element.offsetTop - element.scrollTop + element.clientTop);
			element = element.offsetParent;
		}
		return { x: xPosition, y: yPosition };
	}

	var replaceTemplate = function(item, text) {
		if (typeof text === "undefined") {
			var meta = document.querySelector('meta[name="' + item + '"]');
			if (!meta) {
				return;
			}
			text = meta.getAttribute('content')
		}
		text = text.replace(/&gt;/g, '>').replace(/&lt;/g, '<').replace(/&quot;/g, '"');
		var elements = document.querySelectorAll('.lingua-franca-' + item);
		for (var i = 0; i < elements.length; i++) {
			elements[i].innerHTML = text;
		}
	}

	var pointer = document.getElementById('lingua-franca-pointer');
	var key = pointer.dataset.i18nExampleKey;

	replaceTemplate('title', document.title);
	replaceTemplate('email-from');
	replaceTemplate('email-to');
	replaceTemplate('description');

	var example = document.querySelectorAll('[data-i18n-key="' + key + '"]');
	if (example.length > 0) {
		example = example[example.length - 1];
		var rect = example.getBoundingClientRect();
		var parentRect = example.offsetParent.getBoundingClientRect();
		
		var position = getPosition(example);
		var size = {w: example.offsetWidth, h: example.offsetHeight};

		pointer.style.position = 'absolute';
		pointer.style.left = (position.x + (size.w / 2)) + 'px';

		if ((position.y + size.h) < (document.body.offsetHeight / 2)) {
			pointer.style.top = (position.y + size.h) + 'px';
			pointer.className = 'up';
		} else {
			pointer.style.top = position.y + 'px';
			pointer.className = 'down';
		}
		window.scroll(0, position.y - (window.innerHeight / 2));
	}
}

LinguaFrancaHighlightExample();
