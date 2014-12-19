// Generated by CoffeeScript 1.6.3
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  this.Motion = (function() {
    function Motion(opts) {
      this.update = __bind(this.update, this);
      var clr,
        _this = this;
      this.options = opts || {};
      this.outputel = document.getElementById('output');
      if (this.outputel && this.options.log === true) {
        this.outputel.setAttribute('style', 'display:block;');
      }
      this.minLevel = 0;
      this.maxLevel = 1500;
      this.levelBase = (this.maxLevel + this.minLevel) / 2;
      this.level = this.levelBase;
      this.levelGainer = 0.5;
      this.decaySpeed = 20 + Math.random() * 10;
      if (Math.random() > 0.5) {
        this.decaySpeed = this.decaySpeed * -1;
      }
      this.rotSpeed = 0.9 + Math.random() * 0.2;
      this.gainSineSpeed = 0;
      this.mode = 'steady';
      console.log('decay speed:', this.decaySpeed);
      this.orienter = new Orienter();
      this.pitcher = new Pitcher();
      this.radius = 1000;
      this.twoEl = document.getElementById('motion-anim');
      this.two = new Two({
        fullscreen: true
      }).appendTo(this.twoEl);
      this.baseR = parseInt(100 + Math.random() * 120);
      this.baseG = parseInt(100 + Math.random() * 100);
      this.baseB = parseInt(100 + Math.random() * 80);
      this.rFactor = 15 + Math.random() * 60;
      this.gFactor = 15 + Math.random() * 80;
      this.bFactor = 15 + Math.random() * 100;
      this.circle = this.two.makeCircle(0, 0, this.radius);
      clr = 'rgb(' + this.baseR + ',' + this.baseG + ',' + this.baseG + ')';
      this.circle.fill = clr;
      this.circle.noStroke();
      this.c = this.two.makeCircle(0, this.two.height / 3, 20);
      this.c.fill = 'white';
      this.c.noStroke();
      this.rotator = this.two.makeGroup(this.c);
      this.scaler = this.two.makeGroup(this.circle, this.rotator);
      this.scaler.translation.set(this.two.width / 2, this.two.height / 2);
      this.starter = document.getElementById('starter');
      this.restarter = document.getElementById('restarter');
      this.starter.addEventListener("click", function() {
        return _this.start();
      });
      this.starter.addEventListener("touchstart", function() {
        return _this.start();
      });
    }

    Motion.prototype.output = function(msg) {
      if (!this.outputel || this.options.log !== true) {
        return;
      }
      this.msgs || (this.msgs = []);
      this.msgs.unshift(msg);
      if (this.msgs.length > 5) {
        this.msgs.pop();
      }
      return this.outputel.innerHTML = this.msgs.join('\n');
    };

    Motion.prototype.start = function() {
      var _this = this;
      if (!this.pitcher || !this.pitcher.bufferList) {
        console.log('not ready');
        return;
      }
      this.startTime = new Date().getTime() * 0.001;
      if (this.starter) {
        this.starter.parentNode.removeChild(this.starter);
        this.starter = void 0;
      }
      if (this.restarter) {
        this.restarter.setAttribute('style', 'display:block;');
        this.restarter.addEventListener("click", function() {
          return _this.restart();
        });
        this.restarter.addEventListener("touchstart", function() {
          return _this.restart();
        });
      }
      this.orienter.start();
      this.pitcher.start();
      this.two.bind('update', this.update);
      return this.two.play();
    };

    Motion.prototype.restart = function() {
      this.level = this.levelBase;
      this.pitcher.start();
      this.pitcher.setVolume(0.4);
      this.rotSpeed = 0.9 + Math.random() * 0.2;
      this.decaySpeed = 30 + Math.random() * 10;
      if (Math.random() > 0.5) {
        return this.decaySpeed = this.decaySpeed * -1;
      }
    };

    Motion.prototype.update = function(frameCount) {
      var apply, b, clr, decay, deltaLevel, deltaRot, deltaTime, factor, g, gain, maxDeltaLevel, r, rot, thisFrameRot, thisFrameTime, _ref;
      thisFrameTime = new Date().getTime() * 0.001;
      deltaTime = thisFrameTime - (this.lastFrameTime || thisFrameTime);
      this.lastFrameTime = thisFrameTime;
      thisFrameRot = this.gui_rotation || this.orienter.cumulative;
      deltaRot = thisFrameRot - (this.lastFrameRot || 0);
      this.lastFrameRot = thisFrameRot;
      decay = this.decaySpeed * deltaTime;
      rot = this.rotSpeed * deltaRot;
      if (this.level < 0.2) {
        decay = 0;
        if (rot < 0) {
          rot = -rot;
          this.rotSpeed *= -1;
        }
      }
      if (deltaRot > 20) {
        decay = 0;
      } else {
        decay = decay * Math.abs(deltaRot) / 20;
      }
      this.level = Math.min(Math.abs(Math.max(this.minLevel, this.level + decay) + rot), this.maxLevel);
      deltaLevel = this.level - this.levelBase;
      this.rotator.rotation = thisFrameRot;
      maxDeltaLevel = this.maxLevel - this.levelBase;
      factor = this.level / maxDeltaLevel + Math.sin(thisFrameTime * 10 + this.level * 0.0001) * 0.2;
      r = parseInt(this.baseR + factor * this.rFactor);
      g = parseInt(this.baseG + factor * this.bFactor);
      b = parseInt(this.baseB + factor * this.gFactor);
      clr = 'rgb(' + r + ',' + g + ',' + b + ')';
      this.circle.fill = clr;
      if (this.gainSineSpeed < 10) {
        gain = 1.0;
      } else {
        gain = Math.sin(thisFrameTime * this.gainSineSpeed);
      }
      if (this.mode === 'steady') {
        apply = 1 + deltaLevel / maxDeltaLevel;
      } else {
        if (deltaRot < 0.1) {
          gain = 0.0;
        }
        apply = Math.max(2.0, Math.min(0.2, deltaRot * 0.01));
      }
      this.pitcher.apply(apply);
      if (this.level < 90) {
        gain = Math.min(gain, this.level / 90);
      }
      this.pitcher.setGain((_ref = gain > 0.1) != null ? _ref : {
        1.0: 0.0
      });
      if (frameCount % 15 === 0) {
        return this.output('Lvl: ' + this.level + ' / Rot: ' + thisFrameRot);
      }
    };

    return Motion;

  })();

}).call(this);
