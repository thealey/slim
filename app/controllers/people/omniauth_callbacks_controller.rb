class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    # You need to implement the method below in your model
    @person = Person.find_for_google_oauth(env["omniauth.auth"], current_user)

    if @person.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Google"
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.google_data"] = env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end
end
