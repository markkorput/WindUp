// Generated by CoffeeScript 1.6.3
(function() {
  this.Pitcher = (function() {
    function Pitcher(opts) {
      var bufferLoader,
        _this = this;
      this.options = opts || {};
      this.track_urls = ['audio/125bpm-drums.wav', 'audio/125bpm-dj.wav', 'audio/125bpm-electro.wav'];
      this.volume = 0.4;
      this.freq = 700;
      this.gainMultiplier = 1.0;
      if (typeof webkitAudioContext !== "undefined") {
        this.context = new webkitAudioContext();
      } else if (typeof AudioContent !== "undefined") {
        this.context = new AudioContext();
      } else {
        console.log("AudioContext not supported");
        return;
      }
      this.gain = this.context.createGain();
      this.gain.gain.value = this.volume * this.gainMultiplier;
      this.gain.connect(this.context.destination);
      this.filter = this.context.createBiquadFilter();
      this.filter.connect(this.gain);
      this.filter.type = this.filter.LOWPASS;
      this.filter.frequency.value = 5000;
      this.filter.Q.value = 15;
      bufferLoader = new BufferLoader(this.context, this.track_urls, function(bufferList) {
        return _this.bufferList = bufferList;
      });
      bufferLoader.load();
    }

    Pitcher.prototype.apply = function(val) {
      if (this.source) {
        return this.source.playbackRate.value = val;
      }
    };

    Pitcher.prototype.start = function(trckidx) {
      var buffer;
      if (!this.context) {
        return;
      }
      if (!this.bufferList) {
        this.console.log('no buffer list');
        return;
      }
      this.stop();
      if (trckidx === void 0) {
        trckidx = parseInt(Math.random() * this.bufferList.length);
      }
      buffer = this.bufferList[trckidx];
      if (!buffer) {
        console.log('invalid buffer');
        return;
      }
      this.source = this.context.createBufferSource();
      this.source.buffer = buffer;
      this.source.loop = true;
      this.source.connect(this.filter);
      return this.source.start(this.context.currentTime);
    };

    Pitcher.prototype.stop = function() {
      if (this.source) {
        this.source.stop(this.context.currentTime);
        this.source.disconnect();
        return this.source = void 0;
      }
    };

    Pitcher.prototype.setVolume = function(vol) {
      this.volume = vol;
      if (this.gain) {
        return this.gain.gain.value = vol * (1.0 - this.fade);
      }
    };

    Pitcher.prototype.setGain = function(g) {
      this.gainMultiplier = Math.max(Math.min(g, 1.0), 0.0);
      if (this.gain) {
        return this.gain.gain.value = this.volume * this.gainMultiplier;
      }
    };

    return Pitcher;

  })();

}).call(this);
