// Generated by CoffeeScript 1.6.3
(function() {
  this.Accelerometer = (function() {
    function Accelerometer(opts) {
      this.options = opts;
      this.el = document.getElementById('output');
    }

    Accelerometer.prototype.output = function(msg) {
      return this.el.innerHTML = msg;
    };

    Accelerometer.prototype.start = function() {
      this.output("Starting accelerometer");
      if (!navigator) {
        this.output("No navigator");
        return;
      }
      if (!navigator.accelerometer) {
        this.output("No accelerometer");
        return;
      }
      return this.watchID = navigator.accelerometer.watchAcceleration(this.onSuccess, this.onError, {
        frequency: 1
      });
    };

    Accelerometer.prototype.stop = function() {
      if (!this.watchID) {
        return;
      }
      navigator.accelerometer.clearWatch(this.watchID);
      this.output("Stopped accelerometer");
      return this.watchID = null;
    };

    Accelerometer.prototype.onSuccess = function(acc) {
      return this.output("Acceleration: " + acc.x + "," + acc.y + "," + acc.z);
    };

    Accelerometer.prototype.onError = function(err) {
      return this.output('Error: ' + err);
    };

    return Accelerometer;

  })();

}).call(this);
