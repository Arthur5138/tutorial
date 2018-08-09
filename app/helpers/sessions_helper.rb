module SessionsHelper
  
  #ログインメソッドの定義、渡されたuser_idでログインする。railsのsessionメソッドを使用してuser.idを代入して一時的に保存(ブラウザを終了したら消える)
  def log_in(user)
    session[:user_id] = user.id
  end
  
  def current_user  # 現在ログイン中のユーザーを返す (いる場合)
    @current_user ||= User.find_by(id: session[:user_id])
    #上の1行は、@current_user = @current_user || User.find_by(id: session[:user_id]) を短くしたもの
  end
  
  def logged_in?
    !current_user.nil?
  end
  
  def log_out  # 現在のユーザーをログアウトする
    session.delete(:user_id)
    @current_user = nil
  end
end
