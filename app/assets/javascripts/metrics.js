metricsApp = angular.module('metricsApp', [])
  .config(['$httpProvider', function($httpProvider) {
    $httpProvider.defaults.headers.common['X-CSRF-Token'] =
      $('meta[name=csrf-token]').attr('content')
  }])
  .controller('metricsCtrl', [
    '$scope', '$http', 'metricsService', '$location', function(
      $scope, $http, metricsService, $location) {
      var self = this;
      this.organization = metricsService.organization;
      this.currentUser = metricsService.currentUser;
      this.metricTypes = metricsService.metricTypes;
      this.metricsSubmissionURL = metricsService.metricsSubmissionURL;
      this.eventURL = metricsService.eventURL;
      // Diverse
      this.flash = '';
      this.successfullySubmitted = false;
      this.metricCardIdPrefix = 'metric-card-';
      // Metrics
      this.metricSet = {
        metrics: [],
      }
      // Moving metrics
      this.moveModeActive = false;
      this.movementTarget = null;
      this.updateMetricRanks = function() {
        angular.forEach(self.metricSet.metrics, function(metric, i) {
          metric.rank = i;
        });
      };
      // Fast move list
      this.fastMoveModeActive = false;


      // Initialize
      angular.forEach(this.metricTypes, function(metricType, i) {
        self.metricSet.metrics.push(metricType);
        self.updateMetricRanks();
      });

      this.setMetricRank = function(metric, idx) {
        var self = this;
        metric.rank = idx;
      };


      // Moving

      this.enableMoveMode = function() {
        var self = this;
        self.moveModeActive = true;
      };

      this.disableMoveMode = function() {
        var self = this;
        self.moveModeActive = false;
      };

      this.toggleMoveMode = function() {
        var self = this;
        if (self.moveModeActive == true) {
          self.disableMoveMode();
        } else {
          self.enableMoveMode();
        }
      };

      this.startMovingMetric = function(metric) {
        var self = this;
        if (!self.moveModeActive) {
          self.movementTarget = metric;
          self.toggleMoveMode();

          // Scrooll the corresponding DOM element into view.
          element = document.getElementById(self.metricCardIdPrefix +
                                            metric.rank);
          angular.element(element).css('box-shadow', '0 0 15px 15px #7E7E7E');
          // Do not scroll until the scaling animation (applying the
          // corresponding class/CSS style) is completed.
          window.setTimeout(function() {
            element.scrollIntoView(true);
            window.scrollBy(0, -100);
          }, 350);
        }
      };

      this.clearMovementTarget = function() {
        var self = this;
        self.movementTarget = null;
      };

      this.cancelMovingMetric = function() {
        var self = this;
        // Scrooll the corresponding DOM element into view.
        element = document.getElementById(self.metricCardIdPrefix +
                                          self.movementTarget.rank);
        // Do not scroll until the scaling animation (applying the
        // corresponding class/CSS style) is completed.
        window.setTimeout(function() {
          element.scrollIntoView(true);
          window.scrollBy(0, -100);
          window.setTimeout(function() {
            angular.element(element).css('box-shadow', 'none');
          }, 350);
        }, 350);

        // Clean up.
        self.clearMovementTarget();
        self.moveModeActive = false;
      };

      this.isMovementTarget = function(metric) {
        var self = this;
        return metric === self.movementTarget ? true : false;
      };

      this.finalizeMovingMetric = function(targetIndex) {
        var self = this;
        if (self.movementTarget != null) {
          // Adjust target index for metric that are inserted after a
          // metric with a rank smaller than their own one.
          var targetIndex = targetIndex;
          if (self.movementTarget != null) {
            if (self.movementTarget.rank > targetIndex) {
              targetIndex = targetIndex + 1;
            }
            // Remove the metric from the old position.
            self.metricSet.metrics.splice(self.movementTarget.rank, 1);
            // Remove the metric in its new place.
            self.metricSet.metrics.splice(targetIndex, 0,
                                          self.movementTarget);
          }
          // Scrooll the corresponding DOM element into view.
          element = document.getElementById(self.metricCardIdPrefix +
                                            self.movementTarget.rank);
          // Do not scroll until the scaling animation (applying the
          // corresponding class/CSS style) is completed.
          window.setTimeout(function() {
            element.scrollIntoView(true);
            window.scrollBy(0, -100);
            window.setTimeout(function() {
              angular.element(element).css('box-shadow', 'none');
            }, 350);
          }, 350);

          // Finalize.
          self.toggleMoveMode();
          self.clearMovementTarget();
          self.updateMetricRanks();
        }
      };

      // Fast move mode

      this.enableFastMoveMode = function() {
        var self = this;
        self.fastMoveModeActive = true;
      };

      this.disableFastMoveMode = function() {
        var self = this;
        self.fastMoveModeActive = false;
      };

      this.toggleFastMoveMode = function() {
        var self = this;
        if (self.fastMoveModeActive == true) {
          self.disableFastMoveMode();
        } else {
          self.enableFastMoveMode();
        }
      };

      // Metric values

      this.setMetricValue = function(metric, value) {
        var self = this;
        metric.value = value;
      };

      this.determineMetricClass = function(metric) {
        var self = this;
        var metricClass = '';
        if (metric.value < 0) {
          metricClass  = 'negative-metric';
        } else if(metric.value == 0) {
          metricClass  = 'indifferent-metric';
        } else {
          metricClass  = 'positive-metric';
        }
        return metricClass;
      };

      // Ajax

      this.clearMetrics = function() {
        var self = this;
        self.metricSet.metrics = [];
      };

      this.sendMetrics = function() {
        var self = this;
        $http.post(self.metricsSubmissionURL, self.metricSet)
          .success(function(data, status, headers, config) {
            if (data == 'Success') {
              self.flash = 'Metrics have been saved.';
              element = document.getElementsByTagName('body')[0];
              angular.element(element).css('background-color',
                                           '#E3EBEE');
              window.setTimeout(function() {
                window.location.href = self.eventURL
                self.clearMetrics();
                self.successfullySubmitted = true;
              }, 150);
            } else {
              self.flash = 'Metics could not be saved.';
            }
          })
          .error(function(data, status, headers, config) {
            self.flash = data;
          })
      };
    }]);
