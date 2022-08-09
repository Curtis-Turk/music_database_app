# file: app.rb
require 'sinatra'
require "sinatra/reloader"
require_relative 'lib/database_connection'
require_relative 'lib/album_repository'
require_relative 'lib/artist_repository'

DatabaseConnection.connect

class Application < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
    also_reload 'lib/album_repository'
    also_reload 'lib/artist_repository'
  end

  get '/' do
    return erb(:index)
  end

  get '/about' do
    return erb(:about)
  end

  get '/albums' do
    repo = AlbumRepository.new
    @albums = repo.all

    return erb(:all_albums)
  end

  get '/albums/:id' do
    repo = AlbumRepository.new
    @album = repo.find(params[:id])
    
    artist_repo = ArtistRepository.new

    @artist = artist_repo.find(@album.artist_id)

    return erb(:album) 
  end

  post '/albums' do
    repo = AlbumRepository.new
    album = Album.new

    album.title = params[:title]
    album.release_year = params[:release_year]
    album.artist_id = params[:artist_id]

    repo.create(album)
    album.title
    return
  end

  get '/artists/:id' do
    artist_repo = ArtistRepository.new
    @artist = artist_repo.find(params[:id])

    album_repository = AlbumRepository.new

    @artist_albums = []
    album_repository.all.each do |album|
      if album.artist_id == @artist.id
        @artist_albums << album
      end
    end

    return erb(:artist)
  end

  get '/artists' do
    artist_repo = ArtistRepository.new

    @artists = artist_repo.all

    return erb(:all_artists)
  end
end