(function() {
	'use strict';

	document.addEventListener('DOMContentLoaded', function() {
		var toggle = document.getElementById('sidebar-toggle');
		var sidebar = document.getElementById('sidebar');

		if (!toggle || !sidebar) return;

		toggle.addEventListener('click', function() {
			sidebar.classList.toggle('open');
		});

		// Close sidebar when clicking outside on mobile
		document.addEventListener('click', function(e) {
			if (window.innerWidth > 992) return;
			if (sidebar.classList.contains('open') &&
				!sidebar.contains(e.target) &&
				e.target !== toggle) {
				sidebar.classList.remove('open');
			}
		});

		// Close sidebar on ESC
		document.addEventListener('keydown', function(e) {
			if (e.key === 'Escape' && sidebar.classList.contains('open')) {
				sidebar.classList.remove('open');
			}
		});
	});
})();
