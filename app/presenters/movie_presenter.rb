# frozen_string_literal: true

class MoviePresenter < ApplicationPresenter
  def initialize(movie)
    @movie = movie
  end

  def title
    @movie['original_title']
  end

  def overview
    @movie['overview']
  end

  def image
    [TMDB.config.dig('images', 'base_url'), '/w185', @movie['poster_path']].join
  end
end
