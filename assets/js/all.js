/*! all.js v1.0 */
;(function($, window) {

  $(window.document).ready(function() { 

    //navber active
		var path = window.location.pathname;
		var $navs = $('#navbar-main').find('.js_nav a');
		for (var j = 0, len = $navs.length; j < len; j++) {
			var $nav = $($navs[j]);
			if (path.indexOf($nav.attr('href')) > -1) {
				$nav.parent('li').addClass('active');
			}
		}

		$('.list-group > a').hover(
			function() {
				$(this).addClass('active');
			},
			function() {
				$(this).removeClass('active');
			}
		);

		var $backToTop = $('#back-to-top');
		$backToTop.hide();

		var $window = $(window);
		var documentHeight = $(document).height();
		var windowHeight = $window.height();
		var footerHeight = $('.footer').height();

		$window.on('scroll', function() {
			var scrollTop = $window.scrollTop();
			var scrollPosition = windowHeight + scrollTop;
			if (scrollTop > 100 && (documentHeight - scrollPosition) > footerHeight) {
				$backToTop.fadeIn();
			}
			else {
				$backToTop.fadeOut();
			}
		});
		$backToTop.on('click', function() {
			$('body,html').animate({
				scrollTop: 0
			}, 500);
			return false;
		});

  });

})(jQuery, window);
