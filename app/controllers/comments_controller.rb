class CommentsController < SessionsController
  before_action :current_user
  before_action :signed_in, except: [:index, :show]

  def create
    repository = Repository.find_by slug: params[:slug]
    comment = repository.comments.build(comment_params)
    comment.user_id = @user.id
  	comment.username = @user.username

  	if comment.save!
	  	render json: {
	  		username: comment.username,
	  		user_id: comment.id,
	  		user_url: user_path(@user.username),
	  		comment: comment.content,
        rep: comment.user.reputation,
	  		comment_id: comment.id,
	  		created_at: comment.created_at
	  	}
	  else
	  	redirect_to root_path
	  end
  end

  def destroy
    if comment = Comment.find_by(id: params[:id])
      if @user.admin? || comment.user == @user
        if comment.destroy
          flash[:notice] = "Comment deleted succesfully"
        end
      else
        flash[:alert] = "Something went wrong"
      end
    else
      flash[:alert] = "Something went wrong"
    end
    redirect_to repository_path(slug: comment.repository.slug, user_username: comment.repository.user_username)
  end

  private

    def comment_params
      params.permit(:content)
    end

end
