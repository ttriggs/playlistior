var playlist_api_url=playlist_api_url||"";$.getJSON(playlist_api_url,function(a){$(function(){$("#chart-container").highcharts(a)})});