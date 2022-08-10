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

  get '/albums/new' do
    return erb(:new_album)
  end
  
  get /\/albums\/([0-9]+)/ do
    repo = AlbumRepository.new
    @album = repo.find(params['captures'].first)
    
    artist_repo = ArtistRepository.new

    @artist = artist_repo.find(@album.artist_id)

    return erb(:album) 
  end
 
  post '/albums' do
    if invalid_parameters?
      status 400
      return ''
    end
    repo = AlbumRepository.new
    album = Album.new

    album.title = params[:title]
    album.release_year = params[:release_year]
    album.artist_id = params[:artist_id]

    repo.create(album)
    album.title
    return ""
  end

  get /\/artists\/([0-9]+)/ do
    artist_repo = ArtistRepository.new
    @artist = artist_repo.find(params['captures'].first)

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

def invalid_parameters?
  return (params[:title] == nil || params[:release_year] == nil || params[:artist_id] == nil)
end