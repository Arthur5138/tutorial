class SessionsController < ApplicationController
  
  def new
  end
  
  def create
    @user = User.find_by(email: params[:session][:email].downcase) #loginページから送られたemail情報からモデルからuserを取得する
    if @user && @user.authenticate(params[:session][:password]) #1個目のuserでuserが存在しつつ、かつパスワードの真偽値がtrueならuserを返す
    log_in @user #sessionsHelperのログインメソッドにuserを渡してログインしている。
    #remember user #sessions_helperに定義されてるrememberメソッド。remember_digestに記憶トークンを保存する。
    params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
    redirect_to @user #userと書いてuser_url(user)を自動変換してくれてる。
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end

  end
  
  def destroy
    log_out if logged_in? #current_userが存在する時だけ
    redirect_to root_url
  end
end
