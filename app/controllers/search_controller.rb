class SearchController < SessionsController
  before_action :current_user
  # before_action :signed_in
  require 'will_paginate/array'

  def explore
    @repositories = Repository.order([sort_order].to_h).page params[:page]
    @photos = photo_hash
  end

  def search
  	sort_arr = sort_order
  	repositories_by_attributes = Repository.where("lower(title) LIKE ?
                                                OR lower(description) LIKE ?
                                                OR lower(user_username) LIKE ?
                                                OR lower(category) LIKE ?",
                                  "%#{params[:q].downcase}%",
                                  "%#{params[:q].downcase}%",
                                  "%#{params[:q].downcase}%",
                                  "%#{params[:q].downcase}%")
    repositories_by_categories = []
    Category.where('lower(name) LIKE ?', params[:q].downcase).each do |cat|
      repositories_by_categories << cat.repository
	  end
    @repositories = repositories_by_attributes + repositories_by_categories
    @repositories = @repositories.uniq
    @repositories.paginate(:per_page=>12,:page=>params[:page]) do
      order_by sort_arr.first, sort_arr.last
    end
    @photos = photo_hash
  end

  def category
    sort_arr = sort_order
    repositories_by_category = Repository.where("category LIKE ?", "%#{params[:slug]}%")
    repositories_by_categories = []
    Category.all.each do |cat|
      @cat_name = cat.name.downcase.gsub!(/\W+/, '')
      @search_cat = params[:slug].downcase.gsub!(/\W+/, '')
      if @cat_name == @search_cat
        repositories_by_categories << cat.repository
      end
    end
    @repositories = repositories_by_category + repositories_by_categories
    @repositories = @repositories.uniq
    @repositories.paginate(:per_page=>12,:page=>params[:page]) do
      order_by sort_arr.first, sort_arr.last
    end
    @photos = photo_hash
  end

  def equipment
    sort_arr = sort_order
    @repositories = Repository.where("equipment LIKE ?", "%#{params[:slug]}%").paginate(:per_page=>12,:page=>params[:page]) do
      order_by sort_arr.first, sort_arr.last
    end

    @photos = photo_hash
  end


	private

	def sort_order
		case params[:sort]
    	when 'newest' then [:created_at, :desc]
    	when 'most_likes' then [:like, :desc]
    	when 'most_makes' then [:make, :desc]
    	when 'recently_updated' then [:updated_at, :desc]
    	else [:created_at, :desc]
    end
	end

  def photo_hash
    repository_ids = @repositories.map(&:id)
    photo_ids = Photo.where(repository_id: repository_ids).group(:repository_id).minimum(:id)
    photos = Photo.find(photo_ids.values)
    photos.inject({}) { |h,e| h.merge!(e.repository_id => e) }
  end

end
