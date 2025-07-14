(function ($) {

    "use strict";

    var fullHeight = function () {
        $('.js-fullheight').css('height', $(window).height());
        $(window).resize(function () {
            $('.js-fullheight').css('height', $(window).height());
        });
    };
    fullHeight();

    $('#sidebarCollapse').on('click', function () {
        $('#sidebar').toggleClass('active');
    });

    $('.dropdown-toggle').on('click', function (e) {
        e.preventDefault();
        $(this).next('.collapse').toggle();
    });

})(jQuery);

$(document).ready(function () {
    $('[data-toggle="tooltip"]').tooltip();
});
