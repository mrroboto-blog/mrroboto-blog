(function () {
  if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;
  var c = document.getElementById('matrix-rain');
  if (!c) return;
  var ctx = c.getContext('2d');
  var glyphs = 'アイウエオカキクケコサシスセソ0123456789<>/{}$#'.split('');
  var size = 16, drops = [];
  function resize() {
    c.width = window.innerWidth; c.height = window.innerHeight;
    drops = new Array(Math.ceil(c.width / size)).fill(0).map(function () { return Math.random() * -50; });
  }
  resize(); window.addEventListener('resize', resize);
  setInterval(function () {
    ctx.fillStyle = 'rgba(5,6,5,0.08)'; ctx.fillRect(0, 0, c.width, c.height);
    ctx.fillStyle = '#00ff66'; ctx.font = size + 'px monospace';
    drops.forEach(function (y, i) {
      ctx.fillText(glyphs[Math.floor(Math.random() * glyphs.length)], i * size, y * size);
      drops[i] = (y * size > c.height && Math.random() > 0.975) ? 0 : y + 1;
    });
  }, 60);
})();
