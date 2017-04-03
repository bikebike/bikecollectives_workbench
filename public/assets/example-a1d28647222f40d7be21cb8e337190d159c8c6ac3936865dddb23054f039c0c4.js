document.addEventListener('DOMContentLoaded', function() {
    var key = window.location.hash.substr(1);
    var nodes = document.querySelectorAll('[lingua-franca-key="' + key + '"], [lingua-franca-attr$=":' + key + '"]');
    for (var i = 0; i < nodes.length; i++) {
        nodes[i].classList.add('lingua-franca-selected-key');
    }
}, false);
