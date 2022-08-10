require "spec_helper"
require "rack/test"
require_relative '../../app'

def reset_albums_table
  seed_sql = File.read('spec/seeds/albums_seeds.sql')
  connection = PG.connect({ host: '127.0.0.1', dbname: 'music_library_test' })
  connection.exec(seed_sql)
end

RSpec.describe Application do

  before(:each) do 
    reset_albums_table
  end
  # This is so we can use rack-test helper methods.
  include Rack::Test::Methods
  # We need to declare the `app` value by instantiating the Application
  # class so our tests work.
  let(:app) { Application.new }

  context "GET to /albums" do
    it "Returns 200 with the first album" do
      response = get("/albums")
      
      expect(response.status).to eq(200)
      expect(response.body).to include("Title: Doolittle")
      expect(response.body).to include("Released: 1989")
      expect(response.body).to include("Title: Surfer Rosa")
      expect(response.body).to include("Released: 1988")

      expect(response.body).to include('<a href="/albums/1">Click Here - Doolittle</a>')
      expect(response.body).to include('<a href="/albums/2">Click Here - Surfer Rosa</a>')
      expect(response.body).to include('<a href="/albums/3">Click Here - Waterloo</a>')
    end
  end

  context "POST to /albums" do
    it "Returns 200 and create an album" do
      response = post("/albums", title: "Voyage", release_year: "2022", artist_id: "2")

      expect(response.status).to eq(200)
      expect(response.body).to eq("")

      response = get("/albums")

      expect(response.body).to include("Voyage")

    end
  end

  context "GET /albums/new" do
    it "returns the form page" do
      response = get('/albums/new')

      expect(response.status).to eq(200)
      expect(response.body).to include('<h1>Create an Album</h1>')
      expect(response.body).to include('<form action="/albums" method="POST">')
      expect(response.body).to include("<input type='text' name='title'>")
      expect(response.body).to include("<input type='text' name='release_year'>")
      expect(response.body).to include("<input type='text' name='artist_id'>")
    end
  end
  
  context "POST /albums" do
    # xit 'returns a success page for an album' do
    #   response = post(
    #     '/albums',
    #     title: 'Indie Cindy',
    #     release_year: '2014',
    #     artist_id: '1'
    #   )
    #   expect(response.status).to eq(200)
    #   expect(response.body).to include('<h1>Indie Cindy has been added!</h1>')
    # end

    # xit 'returns a success page for a different album' do
    #   response = post(
    #     '/albums',
    #     title: 'Pastel Blues',
    #     release_year: '1965',
    #     artist_id: '4'
    #   )
    #   expect(response.status).to eq(200)
    #   expect(response.body).to include('<h1>Pastel Blues has been added!</h1>')
    # end

    it 'should validate parameters' do
      response = post(
        '/albums',
        invalid_title: 'Ok Computer',
        invalid_id: 123 
      )
      expect(response.status).to eq(400)
    end
    # xit 'returns 404 if parameters are invalid' do
    #   response = post(
    #     '/albums',
    #     title: 1,
    #     release_year: '',
    #     artist_id: '5'
    #   )
    #   expect(response.status).to eq(404)
    # end
  end

  context "GET to /artists/1" do
    it "Returns an artist in the index body" do
      response = get("/artists/1")

      expect(response.status).to eq(200)
      expect(response.body).to include("Pixies")
      expect(response.body).to include("Rock")
      expect(response.body).to include("Doolittle")
      expect(response.body).to include("Surfer Rosa")
      expect(response.body).to include("Bossanova")
    end
  end
  
  context "GET to /albums/2" do
    it "Returns an album in the index body" do
      response = get("/albums/2")

      expect(response.status).to eq(200)
      expect(response.body).to include("Surfer Rosa")
      expect(response.body).to include("release_year: 1988")
      expect(response.body).to include("artist: Pixies")

    end
  end

  context "GET to /artists" do
    it "Returns 200 with the first artists" do
      response = get("/artists")
      
      expect(response.status).to eq(200)
      expect(response.body).to include("Pixies")
      expect(response.body).to include("ABBA")
      expect(response.body).to include("Taylor Swift")

      expect(response.body).to include('<a href="/artists/1">Pixies</a>')
      expect(response.body).to include('<a href="/artists/2">ABBA</a>')
      expect(response.body).to include('<a href="/artists/3">Taylor Swift</a>')
    end
  end

  context "GET /artists/new" do
    it "returns the form page for a new artist" do
      response = get('/artists/new')

      expect(response.status).to eq(200)
      expect(response.body).to include('<h1>Create an Artist</h1>')
      expect(response.body).to include('<form action="/artists" method="POST">')
      expect(response.body).to include("<input type='text' name='name'>")
      expect(response.body).to include("<input type='text' name='genre'>")
    end
  end
  

end
