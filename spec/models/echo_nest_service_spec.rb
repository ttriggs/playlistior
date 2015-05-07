require 'rails_helper'

describe EchoNestService do
  before(:each) do
    @uri_without_key = VCR.request_matchers.uri_without_param(:api_key,   :genre,
                                                              :min_tempo, :track_id,
                                                              :bucket,    :min_danceability,
                                                              :artist_min_familiarity,
                                                              :limit, :results, :song_type,
                                                              :type)
    @match_params = {allow_playback_repeats:  true, match_requests_on: [:method, @uri_without_key] }
  end

  describe "EchoNestService.get_artist_info" do
    context "get basic artist info" do
      it "returns familiarity songs & genres for artist" do
        VCR.use_cassette('echonest_service_get_artist_info', @match_params) do
          seed_artist = "Beck"
          expected_genres = ["alternative rock",
                             "permanent wave",
                             "indie christmas",
                             "lo-fi",
                             "indie rock",
                             "anti-folk",
                             "folk christmas"]
          response = EchoNestService.get_artist_info(seed_artist)
          expect(response[:artist_name]).to eq("Beck")
          expect(response[:familiarity]).to eq(0.799059)
          expect(response[:genres]).to eq(expected_genres)
        end
      end
    end
  end

  describe "EchoNestService.get_demo_song_data" do
    context "get sample song data from seed artist" do
      it "returns audio summary data for a song" do
        VCR.use_cassette('echonest_service_get_demo_song_data', @match_params) do
          seed_artist = "Beck"
          response = EchoNestService.get_demo_song_data(seed_artist)
          expect(response[:tempo]).to eq(85.404)
          expect(response[:danceability]).to eq(0.65534)
        end
      end
    end
  end

  describe "EchoNestService.songs_by_genre" do
    context "get sample song data from seed artist" do
      it "returns playlist of songs for a genre" do
        VCR.use_cassette('echonest_service_songs_by_genre', @match_params) do
          playlist = FactoryGirl.create(:playlist, seed_artist: "Beck")
          genre = "alternative rock"
          limit = 100
          response = EchoNestService.songs_by_genre(playlist, genre, limit)
          track = response.first
          expect(track.title).to eq("Algiers")
          expect(track.artist_name).to eq("The Afghan Whigs")
          expect(track.id).to eq("SOJPFIN144086486FB")
          expect(response.length).to eq(limit)
        end
      end
    end
  end

  describe "EchoNestService.stitch_in_audio_summaries" do
    context "get sample song data from seed artist" do
      it "adds audio summary data for a song" do
        VCR.use_cassette('echonest_service_stitch_in_audio_summaries', @match_params) do
          limit = 20
          all_playlists = MockTrack.get_mock_tracks(limit)
          response = EchoNestService.stitch_in_audio_summaries(all_playlists)
          track = response.first
          expect(track.title).to eq("1979")
          expect(track.artist_name).to eq("The Smashing Pumpkins")
          expect(track.id).to eq("SOBERAK12AF72A3C2C")
          expect(track.audio_summary["key"]).to eq(3)
          expect(response.length).to eq(limit)
        end
      end
    end
  end

  describe "EchoNestService.get_new_tracklist" do
    context "get full playlist for seed artist" do
      it "call echonest for playlist, then call for audio summaries" do
        VCR.use_cassette('echonest_service_stitch_in_audio_summaries', @match_params) do
          VCR.use_cassette('echonest_service_songs_by_genre', @match_params) do
            limit = 20
            target = limit
            factory_playlist = FactoryGirl.create(:playlist, seed_artist: "Beck")
            playlist = MockPlaylist.create(0, factory_playlist)
            response = EchoNestService.get_new_tracklist(playlist, limit, target)
            track = response.first
            expect(track.title).to eq("Lithium")
            expect(track.artist_name).to eq("Nirvana")
            expect(track.id).to eq("SOPHWBJ137709CB143")
            expect(track.audio_summary.to_hash["key"]).to eq(7)
          end
        end
      end
    end
  end
end
