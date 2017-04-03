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
    var padding = 10;
    for (var i = 0; i < nodes.length; i++) {
        var rect = getDimensions(nodes[i]);
        var highlighter = highlighters[i];
        if (rect) {
            highlighter.style.display = 'block';
            highlighter.style.transform = 'translate(' + (rect.left - padding) + 'px, ' + (rect.top + scrollPos - padding) + 'px)';
            highlighter.style.height = rect.height + (padding * 2) + 'px';
            highlighter.style.width = rect.width + (padding * 2) + 'px';
            // repaint
            highlighter.style.display = 'none';
            setTimeout(function() { highlighter.style.display = 'block'; }, 10);
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
        highlighter.innerHTML = '<svg width="100%" height="100%" viewBox="0 0 100 100" preserveAspectRatio="none"><rect x="0" y="0" width="100" height="100"/></svg>';
        document.body.appendChild(highlighter);
        highlighters.push(highlighter);
    }

    setTimeout(function() {
        var node = positionHighlighters();
        if (node) {
            node.scrollIntoView(false);
        }
    }, 1000);
    delayedPositionHighlighters = function() { setTimeout(positionHighlighters, 1000); };
    window.addEventListener('resize', positionHighlighters, true);
    document.addEventListener('click', delayedPositionHighlighters, true);
    var imgs = document.getElementsByTagName('img');
    for (var i = 0; i < imgs.length; i++) {
        imgs[i].addEventListener('load', delayedPositionHighlighters, false);
    }
}, false);
