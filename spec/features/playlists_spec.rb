require 'rails_helper'

feature 'view playlists' do
  let(:playlist) { MockPlaylist.create(30) }
  before(:each) do
    page.set_rack_session(user_id: playlist.user_id)
    page.set_rack_session(token: TokenFaker.get_fake_token)
  end

  context 'get #show page' do
    scenario 'view content playlist' do
      visit playlist_path(playlist)
      expect(page).to have_content("Inspired by #{playlist.seed_artist.titleize}")
      expect(page).to have_content("This harmonic playlist visualized")
      expect(page).to have_button("Extend")
      expect(page).to have_link("Delete")
    end
  end

  context 'get #index page' do
    scenario 'see #index of playlists' do
      visit playlists_path
      expect(page).to have_link(playlist.seed_artist.titleize)
    end

    scenario 'see search by genre button' do
      visit playlists_path
      expect(page).to have_link("Search by Genre »")
      click_on("Search by Genre »", match: :first)
      expect(page).to have_link("Rock")
      click_on("Rock", match: :first)
      expect(page).to have_link(playlist.seed_artist.titleize)
    end
  end
end

feature 'delete playlists' do
  let(:playlist) { MockPlaylist.create(30) }
  before(:each) do
    page.set_rack_session(user_id: playlist.user_id)
    page.set_rack_session(token: TokenFaker.get_fake_token)
  end
  context 'on playlist #show' do
    scenario 'I can delete my playlist' do
      VCR.use_cassette('spotify_service_unfollow_playlist_from_spotify', ) do
        visit playlist_path(playlist)
        click_on("Delete")
        expect(page).to have_content("Playlist Deleted")
      end
    end

    scenario 'I cannot modify other users playlist' do
      user = FactoryGirl.create(:user)
      page.set_rack_session(user_id: user.id)
      visit playlist_path(playlist)
      expect(page).to have_button("Follow")
      expect(page).to_not have_button("Extend")
      expect(page).to_not have_link("Delete")
    end
  end
end

feature 'create/extend playlists' do
  before(:each) do
    @uri_without_key = VCR.request_matchers.uri_without_param(:api_key,   :genre,
                                                              :min_tempo, :track_id,
                                                              :bucket,    :min_danceability,
                                                              :artist_min_familiarity,
                                                              :limit, :results, :song_type,
                                                              :type, :position)
    @match_params = { allow_playback_repeats:  true, match_requests_on: [:method, @uri_without_key] }
  end
  context 'on playlists #index' do
    scenario 'I can create a new fresh playlist' do
      user = FactoryGirl.create(:user, spotify_id: "TestUser123",
                                       session_token: "session_token")
      page.set_rack_session(user_id: user.id)
      page.set_rack_session(token: TokenFaker.get_fake_token)
      VCR.use_cassette('spotify_service_add_tracks_to_playlist',  @match_params) do
        VCR.use_cassette('echonest_service_stitch_in_audio_summaries', @match_params) do
        VCR.use_cassette('echonest_service_songs_by_genre', @match_params) do
        VCR.use_cassette('spotify_service_create_playlist') do
        VCR.use_cassette('echonest_service_get_demo_song_data', @match_params) do
        VCR.use_cassette('echonest_service_get_artist_info', @match_params) do

          visit playlists_path
          fill_in "playlist", with: "Beck"
          click_on "Create Playlist"

          expect(page).to have_content("Playlist generated (updates may appear first in Spotify app :)")
          expect(page).to have_content("Inspired by Beck")
          expect(page).to have_content("This harmonic playlist visualized")
          expect(page).to have_button("Extend")
          expect(page).to have_link("Delete")
        end
        end
        end
        end
        end
      end
    end
  end
  context 'on #show page' do
    scenario 'successfully extend playlist' do
      playlist = MockPlaylist.create(Playlist::SONGS_LIMIT)
      playlist.update(uri_array: "[]")
      page.set_rack_session(user_id: playlist.user_id)
      page.set_rack_session(token: TokenFaker.get_fake_token)
      VCR.use_cassette('spotify_service_add_tracks_to_playlist',  @match_params) do
        VCR.use_cassette('echonest_service_get_demo_song_data', @match_params) do
          VCR.use_cassette('echonest_service_get_artist_info', @match_params) do
            visit playlist_path(playlist)
            click_on("Extend")
            expect(page).to have_content("Playlist generated (updates may appear first in Spotify app :)")
          end
        end
      end
    end
  end
  context 'on #show page I cannot extend my playlist indefinitely' do
    scenario 'no new tracks saved to playlist, so I see error' do
      playlist = MockPlaylist.create(Playlist::SONGS_LIMIT)
      page.set_rack_session(user_id: playlist.user_id)
      page.set_rack_session(token: TokenFaker.get_fake_token)
      VCR.use_cassette('spotify_service_add_tracks_to_playlist',  @match_params) do
        VCR.use_cassette('echonest_service_get_demo_song_data', @match_params) do
          VCR.use_cassette('echonest_service_get_artist_info', @match_params) do
            visit playlist_path(playlist)
            click_on("Extend")
            expect(page).to have_content("Sorry no more tracks found for this playlist")
          end
        end
      end
    end
  end
end

feature 'cannot create invalid playlist' do
  before(:each) do
    OmniauthMock.setup_login
  end
  context 'on #show submit blank seed artist' do
    scenario 'get error for seed artist' do
      visit "/playlists"
      click_on "Create Playlist"
      expect(page).to have_content("Seed artist can't be blank")
      expect(current_path).to eq(playlists_path)
    end
  end
end
