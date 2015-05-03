require 'rails_helper'

describe Api::V1::PlaylistsController do
  describe 'get #show' do
    let(:total_songs) { 30 }
    let(:playlist) { MockPlaylist.create(total_songs) }

    it "responds with new json for highcharts if none cached" do
      # total_songs = 30
      # playlist = MockPlaylist.create(total_songs)
      session[:user_id] = playlist.user_id
      session[:token] = TokenFaker.get_fake_token
      playlist.energy_json_cache = nil

      get :show, id: playlist.id

      chart_data = response.stream.instance_values["buf"].first
      major_song_count = JSON.parse(chart_data)["series"].first["data"].length
      minor_song_count = JSON.parse(chart_data)["series"].second["data"].length
      chart_songs = major_song_count + minor_song_count

      expect(response.status).to eq(200)
      expect(chart_data).to have_content("chart")
      expect(chart_data).to have_content("Major Songs")
      expect(chart_data).to have_content("Minor Songs")
      expect(chart_songs).to be(total_songs)
    end

    it "responds with cached json if exists" do
      playlist.energy_json_cache = MockChart.get_mock_chart
      session[:user_id] = playlist.user_id
      session[:token] = TokenFaker.get_fake_token

      get :show, id: playlist.id

      chart_data = response.stream.instance_values["buf"].first
      expect(JSON.parse(chart_data)).to eq(JSON.parse(playlist.energy_json_cache))
    end

  end
end
