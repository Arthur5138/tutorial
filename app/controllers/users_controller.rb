class UsersController < ApplicationController
  def new
    @user = User.new
  end
  
  def show
    @user = User.find(params[:id])
  end
  
  def create
    #@user = User.new(params[:user]) userオブジェクトにuserのパラムス全部を渡すのは危険,admin属性を入れられる危険性
    @user = User.new(user_params)
    if @user.save
      log_in @user #Sessionヘルパーのlog_inメソッドを使用。ユーザー登録後に自動でログインできるようにしている
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      render 'new'
    end
  end
  
  private
  
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation) #渡される属性を制限する。
  end
end
