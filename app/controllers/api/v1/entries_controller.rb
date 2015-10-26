class Api::V1::EntriesController < ApplicationController
  def index
    entries = {title: "title"}
    render json: entries
  end
end
