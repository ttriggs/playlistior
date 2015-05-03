require 'rails_helper'

feature 'Gather artist info from Echonest API' do
  context '.setup_artist_info' do
    scenario 'returns artist data with valid seed artist' do
      response = ApiWrap.setup_artist_info("Beck")
      artist_params = response[:params]
      expect(response[:artist_name]).to eq("Beck")
      expect(response[:genres].class).to eq(Array)
      expect(artist_params[:familiarity].class).to eq(Float)
      expect(artist_params[:tempo].class).to eq(Float)
      expect(artist_params[:danceability].class).to eq(Float)
    end

    scenario 'returns error if seed artist not found' do
      response = ApiWrap.setup_artist_info("B309nofnsk")
      expect(response[:errors]).to eq("Sorry couldn't find information for this artist")
    end

    scenario 'returns error if seed artist is blank' do
      response = ApiWrap.setup_artist_info("")
      expect(response[:errors]).to eq("Seed artist can't be blank")
    end
  end
end

feature 'ApiWrap.get_new_tracklist' do
  let(:playlist) { MockPlaylist.create(1) }
  context 'get tacks for new playlist' do
    scenario 'supplied valid playlist' do
      response = ApiWrap.get_new_tracklist(playlist, 10)
      expect(response.length).to eq(10)
      response.each do |song|
        audio_summary = song.audio_summary.attrs
        track = song.tracks.first
        expect(song.title.class).to eq(String)
        expect(song.tracks.class).to eq(Array)
        expect(track.foreign_id).to include("spotify:track")
        expect(audio_summary["key"].class).to eq(Fixnum)
        expect(audio_summary["mode"].class).to eq(Fixnum)
        expect(audio_summary["tempo"].class).to eq(Float)
        expect(audio_summary["time_signature"].class).to eq(Fixnum)
        expect(audio_summary["energy"].class).to eq(Float)
        expect(audio_summary["liveness"].class).to eq(Float)
        expect(audio_summary["danceability"].class).to eq(Float)
      end
    end
  end
end
