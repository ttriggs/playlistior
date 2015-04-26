
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
