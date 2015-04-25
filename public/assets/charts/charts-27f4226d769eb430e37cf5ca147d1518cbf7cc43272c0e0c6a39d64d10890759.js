

$.getJSON(playlist_api_url, function (json) {
  $(function () {
    $('#chart-container').highcharts(json);
  });
});

