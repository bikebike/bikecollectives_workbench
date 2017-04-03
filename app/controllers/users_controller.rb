class UsersController < ApplicationController
  protect_from_forgery with: :exception

  def index
    @requests = User.where(has_workbench_access: [nil, false])
                    .where.not(workbench_access_request_date: nil)
  end

  def edit
    @back = { text: 'Back to Users', link: users_path }
    @user = User.find(params[:id])
  end

  def find
    @user = User.find_user(params[:email])

    if @user.present?
      redirect_to edit_user_path(@user.id)
    else
      flash[:notice] = { message: "No user with the email address '#{params[:email]}' was found.", status: :warning }
      redirect_to :users
    end
  end

  def save
    if params[:email].blank?
      flash[:notice] = { message: "Users must have an email address", status: :error }
    else
      @user = User.find(params[:id])
      user = User.find_user(params[:email])
      if user && @user.id != user.id
        flash[:notice] = { message: "A user already exists with that email address", status: :error }
      else
        @user.email = params[:email]
        @user.firstname = params[:name].blank? ? nil : params[:name]
        @user.has_workbench_access = params[:has_workbench_access] == '1'
        @user.save
      end
    end
    redirect_to edit_user_path(@user.id)
  end
end
