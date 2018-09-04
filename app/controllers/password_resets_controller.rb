class PasswordResetsController < ApplicationController
  before_action :get_user, only: [:edit, :update] #パスワード再設定用のeditアクション
  before_action :valid_user, only: [:edit, :update] #パスワード再設定用のeditアクション
  before_action :check_expiration, only: [:edit, :update]
  
  def new
  end
  
  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "Email sent with password reset instructions"
      redirect_to root_url
    else
      flash.now[:danger] = "Email address not found"
      render "new"
    end
  end

  def edit
  end
  
  def update
    if params[:user][:password].empty?  # (3)への対応
      @user.errors.add(:password, :blank)
      render 'edit'
    elsif @user.update_attributes(user_params)  # (4)への対応
      log_in @user
      @user.update_attribute(:reset_digest, nil) #成功したらreset_digestをnilにする
      flash[:success] = "Password has been reset."
      redirect_to @user
    else
      render 'edit' # (2)への対応
    end
  end
  
  private
  
  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end
  
  def get_user
    @user = User.find_by(email: params[:email])
  end
  
  def valid_user #正しいユーザーか確認する
    unless (@user && @user.activated? && @user.authenticated?(:reset, params[:id]))
    redirect_to root_url
    end
  end
  
  def check_expiration
    if @user.password_reset_expired?
      flash[:danger] = "Password reset has expired."
      redirect_to new_password_reset_url
    end
  end
end
