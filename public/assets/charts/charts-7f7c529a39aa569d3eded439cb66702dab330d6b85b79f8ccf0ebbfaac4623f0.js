var playlist_api_url=playlist_api_url||"";$.getJSON(playlist_api_url,{type:"energy"},function(t){$(function(){$("#chart-container").highcharts(t)})}),$("#energy, #tempo, #danceability, #liveness").click(function(t){t.preventDefault(),$(".button-group li a").removeClass("success"),$(this).addClass("success"),$.getJSON(playlist_api_url,{quality:this.id},function(t){$(function(){$("#chart-container").highcharts(t)})})});