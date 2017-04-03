function positionHighlighters() {
    console.log('reposition');
    var nodes = document.getElementsByClassName('lingua-franca-selected-key');
    var highlighters = document.getElementsByClassName('lingua-franca-highlighter');
    for (var i = 0; i < nodes.length; i++) {
        var rect = nodes[i].getBoundingClientRect();
        var highlighter = highlighters[i];
        highlighter.style.top = rect.top + 'px';
        highlighter.style.left = rect.left + 'px';
        highlighter.style.height = rect.height + 'px';
        highlighter.style.width = rect.width + 'px';
    }
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
        document.body.appendChild(highlighter);
        highlighters.push(highlighter);
    }

    positionHighlighters();
    window.addEventListener('resize', positionHighlighters, true);
}, false);
