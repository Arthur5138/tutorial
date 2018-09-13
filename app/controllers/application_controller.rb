class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper #sessionsヘルパーをどのコントローラからでも呼び出し可能にするためにincludeしてる
  
  
   def logged_in_user 
    unless logged_in? #セッションヘルパー
     store_location #sessionヘルパーから。リクエストしたURLを記憶して:fowarding_urlに保存
     flash[:danger] = "Please log in"
     redirect_to login_url
    end
   end
end
