class UsersController < ApplicationController
  before_action :logged_in_user, only:[:edit, :update, :index, :destroy, :following, :followers]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:destroy]
  
  def new
    @user = User.new
  end
  
  def index
    #@users = User.paginate(page: params[:page])
    @users = User.where(activated: true).paginate(page: params[:page]) #whereでactivateがtrueのuserのみindexに表示させる。
  end
  
  def show
    @user = User.find(params[:id])
    redirect_to root_url and return unless @user.activated? #activateがtrue出ない場合はrootにダイレクト
    @microposts = @user.microposts.paginate(page: params[:page])
  end
  
  def create
    #@user = User.new(params[:user]) userオブジェクトにuserのパラムス全部を渡すのは危険,admin属性を入れられる危険性
    @user = User.new(user_params)
    if @user.save
      #log_in @user #Sessionヘルパーのlog_inメソッドを使用。ユーザー登録後に自動でログインできるようにしている
      #flash[:success] = "Welcome to the Sample App!"
      #redirect_to @user
      #UserMailer.account_activation(@user).deliver_now
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      render 'new'
    end
  end
  
  def edit
    #@user = User.find(params[:id]) 定義したcorrect_userメソッドでfindしている
  end
  
  def update
    #@user = User.find(params[:id]) 定義したcorrect_userメソッドでfindしている
    if @user.update_attributes(user_params) #user_paramsを渡してuserからの属性を制限している
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end
  
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end
  
  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.following.paginate(page: params[:page])
    render "show_follow"
  end
  
  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render "show_follow"
  end
  
  private
  
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation) #渡される属性を制限する。
  end
  
  def correct_user #正しいユーザーかどうか確認
   @user = User.find(params[:id])
   redirect_to(root_url) unless current_user?(@user)
  end
  
  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end
end
