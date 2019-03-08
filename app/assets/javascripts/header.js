$(document).on('ready page:load', function () {
    var nav = $('nav.navbar');
    var chevron = $('.down-indicator');
    var collapse = nav.find('.navbar-collapse');
    var background = $('<div class="background">');

    function doTransition(dark, animate) {
        if (typeof animate === 'undefined' || animate === true) {
            nav.addClass('transition');
        }

        if (dark) {
            nav.removeClass('navbar-light');
            background.removeClass('bg-light');
            nav.addClass('navbar-dark');
        } else {
            nav.removeClass('navbar-dark');
            nav.addClass('navbar-light');
            background.addClass('bg-light');
        }
    }

    if (!nav.hasClass('static_pages home')) {
        return;
    }

    nav.removeClass('bg-light');
    nav.addClass('bg-dark-gradient');
    nav.append(background);

    nav.on('transitionend webkitTransitionEnd oTransitionEnd otransitionend MSTransitionEnd', function () {
        nav.removeClass('transition');
    });

    collapse.on('show.bs.collapse hide.bs.collapse', function () {
        doTransition(nav.hasClass('static_pages home') && $(window).scrollTop() <= 10 && collapse.hasClass('show'));
    });

    $(window).on('scroll', function () {
        doTransition(nav.hasClass('static_pages home') && $(window).scrollTop() <= 10 && !collapse.hasClass('show'));

        if ($(window).scrollTop() <= 10) {
            chevron.css('opacity', 1);
        } else {
            chevron.css('opacity', 0);
        }
    });

    doTransition(true, false);
});
