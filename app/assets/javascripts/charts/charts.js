var playlist_api_url = playlist_api_url || ""

// show energy chart by default
$.getJSON(playlist_api_url, {type: "energy"}, function (json) {
  $(function () {
    $('#chart-container').highcharts(json);
  });
});

// on click, refresh chart
$("#energy, #tempo, #danceability, #liveness").click(function(e) {
  e.preventDefault();
  $(".button-group li a").removeClass("success");
  $(this).addClass("success");
  $.getJSON(playlist_api_url, {quality: this.id}, function (json) {
    $(function () {
      $('#chart-container').highcharts(json);
    });
  });
});
