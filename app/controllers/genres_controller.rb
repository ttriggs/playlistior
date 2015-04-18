class GenresController < ApplicationController
  def show
    binding.pry
    @genre = Genre.where(id: params[:id])
    @playlists = Playlist.where(genre_id: @genre)
  end
end
