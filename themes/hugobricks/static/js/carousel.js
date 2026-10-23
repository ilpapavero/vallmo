document.querySelectorAll('.carousel').forEach(function (carousel) {
    var track = carousel.querySelector('.carousel-track');
    var toggle = carousel.querySelector('.carousel-toggle');
    var reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    var behavior = reducedMotion ? 'auto' : 'smooth';
    var paused = reducedMotion;
    var hovering = false;

    function step(direction) {
        // In RTL scrollLeft goes from 0 to negative values
        var sign = getComputedStyle(track).direction === 'rtl' ? -1 : 1;
        var position = Math.abs(track.scrollLeft);
        var itemWidth = track.querySelector('li').offsetWidth + parseFloat(getComputedStyle(track).columnGap);
        var atStart = position <= 5;
        var atEnd = position + track.clientWidth >= track.scrollWidth - 5;
        if (direction > 0 && atEnd) track.scrollTo({left: 0, behavior: behavior});
        else if (direction < 0 && atStart) track.scrollTo({left: sign * track.scrollWidth, behavior: behavior});
        else track.scrollBy({left: sign * direction * itemWidth, behavior: behavior});
    }

    function setPaused(value) {
        paused = value;
        toggle.classList.toggle('paused', paused);
        toggle.title = paused ? toggle.dataset.resume : toggle.dataset.pause;
        toggle.setAttribute('aria-label', toggle.title);
    }

    carousel.querySelector('.carousel-prev').addEventListener('click', function () { step(-1); });
    carousel.querySelector('.carousel-next').addEventListener('click', function () { step(1); });
    toggle.addEventListener('click', function () { setPaused(!paused); });
    carousel.addEventListener('pointerenter', function (e) { if (e.pointerType === 'mouse') hovering = true; });
    carousel.addEventListener('pointerleave', function () { hovering = false; });

    setPaused(paused);
    setInterval(function () {
        if (!paused && !hovering && !document.hidden) step(1);
    }, 4000);
});
