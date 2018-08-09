class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper #sessionsヘルパーをどのコントローラからでも呼び出し可能にするためにincludeしてる
end
