function getDimensions(node) {
    if (!node) {
        return null;
    }
    var rect = node.getBoundingClientRect();
    if (rect.width && rect.height) {
        return rect;
    }
    getDimensions(node.parentElement);
}

function positionHighlighters() {
    var nodes = document.getElementsByClassName('lingua-franca-selected-key');
    var highlighters = document.getElementsByClassName('lingua-franca-highlighter');
    var scrollPos = document.body.scrollTop;
    for (var i = 0; i < nodes.length; i++) {
        var rect = getDimensions(nodes[i]);
        var highlighter = highlighters[i];
        if (rect) {
            highlighter.style.display = 'block';
            highlighter.style.top = (rect.top + scrollPos) + 'px';
            highlighter.style.left = rect.left + 'px';
            highlighter.style.height = rect.height + 'px';
            highlighter.style.width = rect.width + 'px';
        }
    }
    return nodes[0];
}

document.addEventListener('DOMContentLoaded', function() {
    var key = window.location.hash.substr(1);
    var nodes = document.querySelectorAll('[lingua-franca-key="' + key + '"], [lingua-franca-attr$=":' + key + '"]');
    for (var i = 0; i < nodes.length; i++) {
        nodes[i].classList.add('lingua-franca-selected-key');
    }

    var nodes = document.getElementsByClassName('lingua-franca-selected-key');
    var highlighters = [];
    for (var i = 0; i < nodes.length; i++) {
        var highlighter = document.createElement('div');
        highlighter.className = 'lingua-franca-highlighter';
        highlighter.innerHTML = '<div></div>';
        document.body.appendChild(highlighter);
        highlighters.push(highlighter);
    }

    setTimeout(function() {
        var node = positionHighlighters();
        if (node) {
            node.scrollIntoView();
        }
    }, 1000);
    window.addEventListener('resize', positionHighlighters, true);
    document.addEventListener('click', function() { setTimeout(positionHighlighters, 1000); }, true);
}, false);
