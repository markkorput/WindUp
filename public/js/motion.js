// Generated by CoffeeScript 1.6.3
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  this.Motion = (function() {
    function Motion(opts) {
      this.update = __bind(this.update, this);
      var folder,
        _this = this;
      this.options = opts || {};
      this.outputel = document.getElementById('output');
      if (this.outputel && this.options.log === true) {
        this.outputel.setAttribute('style', 'display:block;');
      }
      this.levelBase = 900 + Math.random() * 100;
      this.level = this.levelBase;
      this.decaySpeed = -25 - Math.random() * 5;
      this.rotSpeed = 0.9 + Math.random() * 0.2;
      this.orienter = new Orienter();
      this.pitcher = new Pitcher();
      this.radius = 50;
      this.twoEl = document.getElementById('motion-anim');
      this.two = new Two({
        fullscreen: true
      }).appendTo(this.twoEl);
      this.circle = this.two.makeCircle(0, 0, this.radius);
      this.circle.fill = '#FF8000';
      this.circle.stroke = 'orangered';
      this.circle.linewidth = 5;
      this.c = this.two.makeCircle(0, -this.radius - 30, 20);
      this.c.fill = '#0080FF';
      this.c.stroke = 'blue';
      this.c.linewidth = 3;
      this.rotator = this.two.makeGroup(this.c);
      this.scaler = this.two.makeGroup(this.circle, this.rotator);
      this.scaler.translation.set(this.two.width / 2, this.two.height / 2);
      this.gui = new dat.GUI();
      folder = this.gui.addFolder('Params');
      folder.open();
      folder.add({
        audio: true
      }, 'audio').onChange(function(val) {
        if (val) {
          return _this.pitched.start();
        } else {
          return _this.pitcher.stop();
        }
      });
      folder.add({
        rotation: 0
      }, 'rotation', -2000, 2000).onChange(function(val) {
        return _this.gui_rotation = val;
      });
      folder.add({
        ResetRot: function() {
          _this.gui_rotation = void 0;
          return data.rotation = 0;
        }
      }, 'ResetRot');
      folder.add({
        Volume: 0.07
      }, 'Volume', 0, 0.3).onChange(function(val) {
        return _this.pitcher.setVolume(val);
      });
      folder.add({
        DecaySpeed: this.decaySpeed
      }, 'DecaySpeed', -100, 100).onChange(function(val) {
        return _this.decaySpeed = val;
      });
      folder.add({
        RotSpeed: this.rotSpeed
      }, 'RotSpeed', -5, 5).onChange(function(val) {
        return _this.rotSpeed = val;
      });
      console.log(this.two);
      console.log(this.circle);
      console.log(this.gui);
      this.starter = document.getElementById('starter');
      this.starter.addEventListener("click", function() {
        return _this.start();
      });
      this.starter.addEventListener("touchstart", function() {
        return _this.start();
      });
    }

    Motion.prototype.output = function(msg) {
      this.msgs || (this.msgs = []);
      this.msgs.unshift(msg);
      if (this.msgs.length > 10) {
        this.msgs.pop();
      }
      if (this.outputel && this.options.log === true) {
        return this.outputel.innerHTML = this.msgs.join('\n');
      }
    };

    Motion.prototype.start = function() {
      this.startTime = new Date().getTime() * 0.001;
      if (this.starter) {
        this.starter.parentNode.removeChild(this.starter);
        this.starter = void 0;
      }
      this.orienter.start();
      this.pitcher.start();
      this.two.bind('update', this.update);
      return this.two.play();
    };

    Motion.prototype.update = function(frameCount) {
      var decay, deltaRot, deltaTime, rot, thisFrameRot, thisFrameTime;
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
      this.level = Math.abs(Math.max(0.0, this.level + decay) + rot);
      this.rotator.rotation = thisFrameRot / 180 * Math.PI;
      this.scaler.scale = this.level / 270;
      this.pitcher.apply(Math.min(1.0, this.level / 1260));
      if (this.level < 90) {
        this.pitcher.setFade(1.0 - this.level / 90);
      } else {
        this.pitcher.setFade(0.0);
      }
      return this.output('Lvl: ' + this.level + ' / Rot: ' + thisFrameRot);
    };

    return Motion;

  })();

}).call(this);
