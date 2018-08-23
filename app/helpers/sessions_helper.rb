module SessionsHelper
  
  #ログインメソッドの定義、渡されたuser_idでログインする。railsのsessionメソッドを使用してuser.idを代入して一時的に保存(ブラウザを終了したら消える)
  def log_in(user)
    session[:user_id] = user.id
  end
  
  #ユーザーセッションを永続的にする
  def remember(user)
    user.remember #ユーザーモデルのrememberメソッド
    cookies.permanent.signed[:user_id] = user.id #signedはuser_idを暗号化させてセキュリティを強化している。
    cookies.permanent[:remember_token] = user.remember_token
  end
  
  #def current_user  # 現在ログイン中のユーザーを返す (いる場合)
    #@current_user ||= User.find_by(id: session[:user_id])
    #上の1行は、@current_user = @current_user || User.find_by(id: session[:user_id]) を短くしたもの
  #end
  
  #記憶トークンcookiesに対応するユーザーを返す
  def current_user
    if (user_id = session[:user_id]) #session[:user_id]でidを復号化、そのidが存在したら
      @current_user ||= User.find_by(id: user_id) #@current_userがない場合、上記idでuser.find_byをしてuserを取得
    elsif (user_id = cookies.signed[:user_id]) #または、cookies.signed[:user_id]で復号化
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token]) #userモデルに定義したauthenticated?でremember_digestとcookies[:remember_token]を照合してtrueならuserを返す
        log_in user
        @current_user = user
      end
    end
  end
  
  def current_user?(user) #ログイン済みユーザーであればtrueを返す
    user == current_user
  end
  
  def logged_in?
    !current_user.nil?
  end
  
  # 永続的セッションを破棄する(DBのremember_digestをnil&クッキーを削除する)
  def forget(user)
    user.forget #ユーザーモデルのforgetメソッド remember_digestをnilにする
    cookies.delete(:user_id) #クッキーのuser_idを削除
    cookies.delete(:remember_token) #クッキーのremember_tokenを削除
  end
  
  def log_out  # 現在のユーザーをログアウトする
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end
  
  def redirect_back_or(default) #記憶したURL(もしくはデフォルト)にリダイレクト
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end
  
  def store_location #アクセスしたURLを記憶する
    session[:forwarding_url] = request.original_url if request.get? #:forwarding_urlに代入。request.original_urlでリクエストされたURLを取得
  end
end
