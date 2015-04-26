var playlist_api_url = playlist_api_url || ""
$.getJSON(playlist_api_url, function (json) {
  $(function () {
    $('#chart-container').highcharts(json);
  });
});
