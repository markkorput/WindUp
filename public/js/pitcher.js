// Generated by CoffeeScript 1.6.3
(function() {
  this.Pitcher = (function() {
    function Pitcher(opts) {
      var default_url;
      this.options = opts || {};
      default_url = 'audio/horror-drone.wav';
      this.volume = 0.07;
      this.freq = 700;
      this.fade = 0.0;
      if (typeof webkitAudioContext !== "undefined") {
        this.context = new webkitAudioContext();
      } else if (typeof AudioContent !== "undefined") {
        this.context = new AudioContext();
      } else {
        console.log("AudioContext not supported");
        return;
      }
      this.gain = this.context.createGain();
      this.gain.gain.value = this.volume * (1.0 - this.fade);
      this.gain.connect(this.context.destination);
      console.log(this.context);
      console.log(this.gain);
    }

    Pitcher.prototype.apply = function(value) {
      this.freq = 300 + 800 * value;
      if (this.oscillator) {
        return this.oscillator.frequency.value = this.freq;
      }
    };

    Pitcher.prototype.start = function() {
      if (!this.context) {
        return;
      }
      this.oscillator = this.context.createOscillator();
      this.oscillator.type = 'square';
      this.oscillator.frequency.value = this.freq;
      this.oscillator.connect(this.gain);
      return this.oscillator.start(this.context.currentTime);
    };

    Pitcher.prototype.stop = function() {
      if (!this.oscillator) {
        return;
      }
      this.oscillator.stop(this.context.currentTime);
      return this.oscillator = void 0;
    };

    Pitcher.prototype.toggle = function() {
      if (this.oscillator) {
        return this.stop();
      } else {
        return this.start();
      }
    };

    Pitcher.prototype.setVolume = function(vol) {
      this.volume = vol;
      if (this.gain) {
        return this.gain.gain.value = vol * (1.0 - this.fade);
      }
    };

    Pitcher.prototype.setFade = function(fade) {
      this.fade = Math.max(Math.min(fade, 1.0), 0.0);
      if (this.gain) {
        return this.gain.gain.value = this.volume * (1.0 - this.fade);
      }
    };

    return Pitcher;

  })();

}).call(this);
