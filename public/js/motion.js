// Generated by CoffeeScript 1.6.3
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  this.Motion = (function() {
    function Motion(opts) {
      this.update = __bind(this.update, this);
      var data, folder, item,
        _this = this;
      this.options = opts || {};
      this.outputel = document.getElementById('output');
      if (this.outputel && this.options.log === true) {
        this.outputel.setAttribute('style', 'display:block;');
      }
      this.decay = 0;
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
      data = new function() {
        this.rotation = 0;
        return this.audio = true;
      };
      folder = this.gui.addFolder('Params');
      folder.open();
      item = folder.add(data, 'audio');
      item.onChange(function(val) {
        return _this.pitcher.toggle();
      });
      item = folder.add(data, 'rotation', -1080, 1080);
      item.onChange(function(val) {
        return _this.gui_rotation = val;
      });
      item.listen();
      folder.add({
        ResetRot: function() {
          _this.gui_rotation = void 0;
          return data.rotation = 0;
        }
      }, 'ResetRot');
      folder.add({
        Volume: 0.07
      }, 'Volume', 0, 0.4).onChange(function(val) {
        return _this.pitcher.setVolume(val);
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
      var rot, value;
      this.decay = frameCount * 0.3;
      rot = this.gui_rotation || this.orienter.cumulative;
      this.output('Rot: ' + rot + ' (' + this.orienter.rotationIndex + ')');
      this.rotator.rotation = rot / 180 * Math.PI;
      value = Math.abs(rot);
      if (this.decay > value) {
        value = 0;
      } else {
        value -= this.decay;
      }
      this.scaler.scale = value / 270;
      this.pitcher.apply(Math.min(1.0, value / 1260));
      if (value < 90) {
        return this.pitcher.setFade(1.0 - value / 90);
      } else {
        return this.pitcher.setFade(0.0);
      }
    };

    return Motion;

  })();

}).call(this);
