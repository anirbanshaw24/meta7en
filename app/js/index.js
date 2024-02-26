function takeScreenshot(el) {

	var screenshot = el.cloneNode(true);
	screenshot.style.pointerEvents = 'none';
	screenshot.style.overflow = 'hidden';
	screenshot.style.webkitUserSelect = 'none';
	screenshot.style.mozUserSelect = 'none';
	screenshot.style.msUserSelect = 'none';
	screenshot.style.oUserSelect = 'none';
	screenshot.style.userSelect = 'none';

	screenshot.dataset.scrollX = window.scrollX;
	screenshot.dataset.scrollY = window.scrollY;

	var blob = new Blob([screenshot.outerHTML], {
		type: 'text/html'
	});
	return blob;
}

function generate(el) {
	window.URL = window.URL || window.webkitURL;
	window.open(window.URL
		.createObjectURL(takeScreenshot(el)));
}

Shiny.addCustomMessageHandler('screenshot', function(selector) {
  // const el = document.querySelector(".code-with-copy");
  const el = document.querySelector(selector);
  takeScreenshot(el);
});
