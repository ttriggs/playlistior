class Playlist < ActiveRecord::Base
  has_many :genres, through: :styles
  has_many :styles, dependent: :destroy
  has_many :tracks, dependent: :destroy

  belongs_to :user

  def get_music_styles
    response = Echowrap.artist_search(results: 1,
                                      limit: true,
                                      name: seed_artist,
                                      bucket: ["id:spotify-WW", :genre])
    genres_array = response.first.to_hash[:genres].map(&:values).flatten
    genres_array.each do |genre_name|
      genre = Genre.find_by(name: genre_name)
      styles.find_or_create_by(playlist: self, genre: genre ) if genre
    end
  end

  def build_spotify_playlist
    if fresh_playlist?
      new_playlist = fetch_playlist
      self.name        = new_playlist["name"]
      self.spotify_id  = new_playlist["id"]
      self.link        = new_playlist["href"]
      self.user        = user
      self.seed_artist = seed_artist
      self.save! # to have playlist id ready for genre/style linking
      get_music_styles
      add_tracks
    end
  end

  def fresh_playlist?
    tracks.none?
  end

  def fetch_playlist
    response = create_empty_playlist
    if response["error"].present?
      failure(response["error"]["message"])
    else
      response
    end
  end

  def create_empty_playlist
    params = { json: true,
               body: { name: "Playlistior: #{seed_artist}",
                      "public" => false }.to_json,
               headers: {"Authorization" => "Bearer #{create_token}",
               "Content-Type" => "application/json"}
             }
    HTTParty.post("#{user.spotify_link}/playlists", params)
  end

  def add_tracks
binding.pry # build out track uri methods
    genres.first
  end

end
