teamApp = angular.module('teamApp', [])
  .config(["$httpProvider", function($httpProvider) {
    $httpProvider.defaults.headers.common['X-CSRF-Token'] =
      $('meta[name=csrf-token]').attr('content')
  }])
  .controller('membershipCtrl', [
    '$scope', '$http', '$location', 'teamInitializer', function(
      $scope, $http, $location, teamInitializer) {
      this.location = $location.absUrl();
      this.host = $location.url();
      this.userProfileURL = teamInitializer.userProfileURL;
      this.metricsURL = teamInitializer.metricsURL.replace(/_$/, '');
      this.eventPageURL = teamInitializer.eventPageURL.replace(/_$/, '');
      this.teamMembers = teamInitializer.teamMembers;
      this.currentUser = teamInitializer.currentUser;
      this.team = teamInitializer.team;
      this.flash = '';
      // Diverse
      this.newlyCreatedEvents = [];
      this.flashMessageElementId = 'membership-flash';
      this.createNewEventElementId = 'new-event-box';
      // New event
      this.newEvent = {
        name: '',
        description: '',
        annotation: '',
        team_id: this.team.id,
        metricTypes: [],
      };
      // Events
      this.events = teamInitializer.events;
      // Events pagination
      this.pageNum = 1;
      this.nextPageNum = this.pageNum + 1;
      this.previousPageNum = this.pageNum - 1;
      this.pagesTotal = teamInitializer.eventPagesTotal;
      // Events search
      this.eventsSearchQuery = null;
      this.eventsSearchURL = teamInitializer.eventsSearchURL;
      this.eventsSearchActive = false;
      // Presets
      this.eventPresets = teamInitializer.eventPresets;

      this.removeTeamMember = function(teamMember) {
        var self = this;
        for (var i = 0; i < self.teamMembers.length; i++) {
          if (self.teamMembers[i].name == teamMember.name) {
            self.teamMembers.splice(i, 1);
          }
        }
      };

      this.addTeamMember = function(teamMember) {
        var self = this;
        self.teamMembers.push(teamMember);
      };

      this.updateButtonText = function() {
        var self = this;
        if (teamInitializer.userIsTeamMember) {
          self.buttonText = 'Leave';
        } else {
          self.buttonText = 'Join';
        }
      };
      this.updateButtonText();

      this.toggleMembership = function() {
        var self = this;
        if (teamInitializer.userIsTeamMember) {
          $http.post(self.location + '/leave', null)
            .success(function(data, status, headers, config) {
              if (data == 'Success') {
                teamInitializer.userIsTeamMember = false;
                self.removeTeamMember(self.currentUser);
                self.updateButtonText();
              }
            })
            .error(function(data, status, headers, config) {
              // Ignore it.
            });
        } else {
          $http.post(self.location + '/join', null)
            .success(function(data, status, headers, config) {
              if (data == 'Success') {
                teamInitializer.userIsTeamMember = true;
                self.addTeamMember(self.currentUser);
                self.updateButtonText();
              }
            })
            .error(function(data, status, headers, config) {
              // Ignore it.
            });
        }
      };

      // New event
      this.addMetricType = function() {
        var self = this;
        var metricType = {
          name: '',
          description: '',
        };
        self.newEvent.metricTypes.push(metricType)
      };

      this.addFirstMetricType = function() {
        var self = this;
        if (self.newEvent.metricTypes.length == 0) {
          self.addMetricType();
        }
      };

      this.clearMetricTypes = function() {
        var self = this;
        self.newEvent.metricTypes = [];
      };

      this.clearNewEvent = function() {
        var self = this;
        self.newEvent.name = '';
        self.newEvent.description = '';
        self.newEvent.annotation = '';
        self.clearMetricTypes();
      };

      this.removeMetricType = function(metric) {
        var self = this;
        var index = self.newEvent.metricTypes.indexOf(metric);
        self.newEvent.metricTypes.splice(index, 1);
      };

      this.scrollToElementWithId = function(id) {
        var self = this;
        document.getElementById(id).scrollIntoView(true);
        window.scrollBy(0, -40);
      }

      this.createNewEvent = function() {
        var self = this;
        $http.post(self.location + '/event/new', self.newEvent)
          .success(function(data, status, headers, config) {
            if (data.message == 'Success') {
              // Set the events flash message.
              self.flash = '"' + self.newEvent.name +
                '" has been created.';

              // Add a copy of the new event to the list of newly created
              // events.
              self.newlyCreatedEvents.push(angular.copy(data.newEvent));

              // If the pagination is on the first page, prepend the new
              // event to the new event to the event list.
              if (self.pageNum == 1) {
                self.events.unshift(data.newEvent);
              }

              // Scroll to the membership flash message element.
              self.scrollToElementWithId(self.createNewEventElementId);

              // Clear the event so another new one can be created.
              self.clearNewEvent();
            } else {
              self.flash = data.message;

              // Scroll to the membership flash message element.
              self.scrollToElementWithId(self.flashMessageElementId);
            }
          })
          .error(function(data, status, headers, config) {
            self.flash = data.message;

            // Scroll to the membership flash message element.
            self.scrollToElementWithId(self.flashMessageElementId);
          })
      }


      // Events pagination

      this.nextPage = function() {
        var self = this;
        $http.get(self.location + '/' + self.nextPageNum)
          .success(function(data, status, headers, config) {
            self.pageNum = data.page;
            self.nextPageNum = data.page + 1;
            self.previousPageNum = data.page - 1;
            self.events = data.events;
            self.pagesTotal = data.pagesTotal;
          })
          .error(function(data, status, headers, config) {
            // Ignore it.
          });
      };

      this.previousPage = function() {
        var self = this;
        $http.get(self.location + '/' + self.previousPageNum)
          .success(function(data, status, headers, config) {
            self.pageNum = data.page;
            self.nextPageNum = data.page + 1;
            self.previousPageNum = data.page - 1;
            self.events = data.events;
            self.pagesTotal = data.pagesTotal;
          })
          .error(function(data, status, headers, config) {
            // Ignore it.
          })
      };


      // Event search

      this.searchEvents = function() {
        var self = this;
        $http.get(self.eventsSearchURL + '?q=' +
                  encodeURIComponent(self.eventsSearchQuery))
          .success(function(data, status, headers, config) {
            self.events = data
            self.eventsSearchActive = true;
          })
          .error(function(data, status, headers, config) {
            // Ignore it.
          });
      };

      this.clearEventsSearch = function() {
        var self = this;
        // Clear the search query and disable the events search mode.
        self.eventsSearchQuery = null;
        self.eventsSearchActive = false;

        // Clear the search results and show the first pagination page
        // instead.
        self.pageNum = 2;
        self.previousPage();
      };


      // Metric type presets

      this.clearMetricTypes = function() {
        var self = this;
        self.newEvent.metricTypes = [];
      };

      this.usePreset = function(presetName) {
        var self = this;
        var eventPreset = self.eventPresets[presetName];
        var keys = Object.keys(eventPreset);
        // Clear the list of metric types.
        self.clearMetricTypes();

        // Add the presett.
        for (var i = 0; i < keys.length; i++) {
          var name = keys[i];
          var metricType = {
            name: name,
            description: eventPreset[name],
          };
          self.newEvent.metricTypes.push(metricType)
        }
      };
    }]);
