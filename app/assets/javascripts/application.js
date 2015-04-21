// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require foundation
//= require_tree .
//= require twitter/typeahead
//= require twitter/typeahead/bloodhound


$(function(){ $(document).foundation(); });

// Instantiate the Bloodhound suggestion engine
var artists = new Bloodhound({
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name'),
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    prefetch: {
        url: 'assets/js/artists.json',
        filter: function (artists) {
            return $.map(artists, function (artist) {
                return {
                    name: artist
                };
            });
        }
    }
});

// Initialize the Bloodhound suggestion engine
artists.initialize();

// Instantiate the Typeahead UI
$('.typeahead').typeahead(null, {
    displayKey: 'name',
    source: artists.ttAdapter()
});


$(document).ready(function() {
// Inline popups
  $(".playlist-popup").on("click", function(e){
    $(this).magnificPopup({
      items: {
        src: '#camelot-popup',
        type: 'inline'
      },
      removalDelay: 400, //delay removal by X to allow out-animation
      callbacks: {

        beforeOpen: function() {
           this.st.mainClass = this.st.el.attr('data-effect');
        }
      },
      midClick: true // allow opening popup on middle mouse click. Always set it to true if you don't provide alternative source.
    }).magnificPopup('open');
  });
});

