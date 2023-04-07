# frozen_string_literal: true

class MoviesController < ApplicationController
  def index
    response = TMDB.client.get_movies(params[:page])
    body = response['body']
    @movies = body['results'] || []
    @total_pages = body['total_pages']
    @paginate_obj = Kaminari.paginate_array(@movies).page(params[:page])
  end

  def favorite_toggle
    options = {
      media_type: 'movie',
      media_id: params[:movie_id],
      favorite: params[:favorite] == 'true'
    }

    response = TMDB.client.favorite(options)
    @movie = response['body']

    redirect_to favorite_list_path, notice: response.dig('body', 'status_message')
  end

  def favorite_list
    response = TMDB.client.favorite_list
    @fav_movies = response.dig('body', 'results')

    return unless params[:title].present?

    @fav_movies_title = @fav_movies.map { |movie| movie['original_title'] } if @fav_movies.present?
    response = TMDB.client.search(params[:title])
    @movies = response.dig('body', 'results')
  end
end
