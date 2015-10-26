class Api::V1::EntriesController < ApplicationController
  def index
    render json: Entry.all
  end
end
