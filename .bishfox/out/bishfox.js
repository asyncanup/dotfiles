// bishfox.js
window.addEventListener("keydown", function(event) {
  if (event.shiftKey || event.altKey) return;
  if (document.activeElement.tagName !== 'DIV') return;

  var maxAmount = 0;
  if (event.key === 'j') maxAmount = 15;
  else if (event.key === 'k') maxAmount = -15;
  else if (event.key === 'd') maxAmount =  50;
  else if (event.key === 'u') maxAmount = -50;

  bishfox.smoothScrollBy(0, maxAmount, 10);
});

var bishfox = {
  smoothScrollBy: function scrollBy(frame, maxAmount, maxFrames) {
    if (maxAmount === 0 || frame === maxFrames) return;

    frame += 1;
    var amount = bishfox.easeOut(frame / maxFrames) * maxAmount;
    document.scrollingElement.scrollBy(0, amount);
    window.requestAnimationFrame(function() {
      scrollBy(frame, maxAmount, maxFrames);
    });
  },
  easeOut: function (x) {
    return x === 1 ? 1 : 1 - Math.pow(2, -10 * x);
  }
};
