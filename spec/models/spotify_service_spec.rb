require 'rails_helper'

describe SpotifyService do
  describe "spotify_service.create_playlist" do
    context "create playlist" do
      it "creates a new playlist on spotify, returns snapshot_id" do
        VCR.use_cassette('spotify_service_create_playlist') do
          uid = "TestUser123"
          token = 'token'
          response = SpotifyService.new(token).create_playlist(uid, "Playlistior: Beck")
          expect(response["owner"]["id"]).to eq("TestUser123")
          expect(response["snapshot_id"]).to eq("2ASU5a9Y2E4muiwja7SKDdGJMZSVGiOkv8xbwKuEuAEjz2ODJht8sxu3VRV7fPOT")
        end
      end
    end
  end

  describe "spotify_service.add_tracks" do
    context "after created, add tracks" do
      it "creates a new playlist on spotify, returns snapshot_id" do
        VCR.use_cassette('spotify_service_add_tracks_to_playlist') do
          playlist_url = "https://api.spotify.com/v1/users/TestUser123/playlists/3P95eDoSwbtMrJRF4lOAdn/tracks"
          track_ids = ["spotify:track:0UUmLyk9WUO3KNtDzARbO8", "spotify:track:4mfNiZl9qisxdLiLHIRa4n"]
          token = "token"
          response = SpotifyService.new(token).add_tracks(playlist_url, track_ids)
          expect(response["snapshot_id"]).to eq("J2/+ssQihXRHU7K8i9V7hCNFsOg+PvamjW7NCR3+UsFADn8RHQYCo2Si7912m++K")
        end
      end
    end
  end

  describe "spotify_service.unfollow_playlist" do
    context "to remove playlist from spotify" do
      it "unfollows/deletes playlist" do
        VCR.use_cassette('spotify_service_unfollow_playlist_from_spotify') do
          playlist_id = "3P95eDoSwbtMrJRF4lOAdn"
          user_id = "TestUser123"
          token = "token"
          response = SpotifyService.unfollow_playlist(playlist_id, user_id, token)
          expect(response.status).to eq(200)
        end
      end
    end
  end
end
