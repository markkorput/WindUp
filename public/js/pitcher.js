// Generated by CoffeeScript 1.6.3
(function() {
  this.Pitcher = (function() {
    function Pitcher(opts) {
      this.options = opts || {};
      this.sound = new Howl({
        urls: ['audio/horror-drone.wav'],
        loop: true,
        volume: 0.5,
        sprite: {
          piece1: [3000, 1000]
        }
      });
    }

    Pitcher.prototype.start = function() {
      console.log('Starting audio');
      return this.sound.play('piece1');
    };

    return Pitcher;

  })();

}).call(this);