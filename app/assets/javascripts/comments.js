function updateTimes(selector) {
    var times = document.getElementsByTagName('time');
    for (var i = 0; i < times.length; i++) {
        var time = times[i], datetime = time.getAttribute('datetime');
        if (datetime) {
            time.innerHTML = moment(new Date(datetime)).fromNow();
        }
    }
}
document.addEventListener('DOMContentLoaded', function() {
    updateTimes();
}, false);
