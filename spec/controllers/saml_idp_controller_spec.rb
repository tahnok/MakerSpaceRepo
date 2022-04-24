require 'rails_helper'

RSpec.describe SamlIdpController, type: :controller do

  describe "POST /auth" do

    context "auth with saml" do

      it 'should not log in (wrong saml request)' do
        post :auth, params: {SAMLRequest: "abc"}
        expect(response).to have_http_status(403)
      end

      it 'should not log in (wrong password)' do
        user = create(:user, :regular_user)
        post :auth, params: {submit: "sign_in", username: user.email, password: "abc#", RelayState: "https://en.wiki.makerepo.com/wiki/Special:PluggableAuthLogin", SAMLRequest: "fZJvT8IwEMa/ytL328r+AQ1bghAjCeoC0xe+Md12SMPWzl4n+u0dm0YMCa+a3t3vnrunnSGvq4bNW7OXG3hvAY31WVcSWZ+ISaslUxwFMslrQGYKtp3fr5nnUNZoZVShKnKGXCc4ImgjlCTWahmT1zH1ozDMC+7zfAohp9NdMAlpmY85hRENIaT+JCoDvyTWM2jsyJh0jTocsYWVRMOl6ULU82wa2F6QjSLmRYyOXoi17LYRkpue2hvTIHPdmh9AQ6OcQtXuaWKXd8sTa/472kJJbGvQW9AfooCnzfoPBukcxUE4l01qVbYVOM2+Ge44nJ7NC+yjFxyx0h//boQshXy7bl0+FCG7y7LUTh+3GUlmJwnWW6GTC4GZe56eDS/90DVeLVNVieLLulW65ua67ikiSnvXlzKjuUQB0nSGVZU6LjRwAzExugXiJoPk//+UfAM="}
        expect(response).to have_http_status(200)
      end

      it 'should log in with password' do
        user = create(:user, :regular_user)
        post :auth, params: {submit: "sign_in", username: user.email, password: "asa32A353#", RelayState: "https://en.wiki.makerepo.com/wiki/Special:PluggableAuthLogin", SAMLRequest: "fZJvT8IwEMa/ytL328r+AQ1bghAjCeoC0xe+Md12SMPWzl4n+u0dm0YMCa+a3t3vnrunnSGvq4bNW7OXG3hvAY31WVcSWZ+ISaslUxwFMslrQGYKtp3fr5nnUNZoZVShKnKGXCc4ImgjlCTWahmT1zH1ozDMC+7zfAohp9NdMAlpmY85hRENIaT+JCoDvyTWM2jsyJh0jTocsYWVRMOl6ULU82wa2F6QjSLmRYyOXoi17LYRkpue2hvTIHPdmh9AQ6OcQtXuaWKXd8sTa/472kJJbGvQW9AfooCnzfoPBukcxUE4l01qVbYVOM2+Ge44nJ7NC+yjFxyx0h//boQshXy7bl0+FCG7y7LUTh+3GUlmJwnWW6GTC4GZe56eDS/90DVeLVNVieLLulW65ua67ikiSnvXlzKjuUQB0nSGVZU6LjRwAzExugXiJoPk//+UfAM="}
        expect(response).to have_http_status(200)
      end

      it 'should log in with password and otp' do
        user = create(:user, :otp)
        post :auth, params: {submit: "sign_in", username: user.email, password: "asa32A353#", RelayState: "https://en.wiki.makerepo.com/wiki/Special:PluggableAuthLogin", SAMLRequest: "fZJvT8IwEMa/ytL328r+AQ1bghAjCeoC0xe+Md12SMPWzl4n+u0dm0YMCa+a3t3vnrunnSGvq4bNW7OXG3hvAY31WVcSWZ+ISaslUxwFMslrQGYKtp3fr5nnUNZoZVShKnKGXCc4ImgjlCTWahmT1zH1ozDMC+7zfAohp9NdMAlpmY85hRENIaT+JCoDvyTWM2jsyJh0jTocsYWVRMOl6ULU82wa2F6QjSLmRYyOXoi17LYRkpue2hvTIHPdmh9AQ6OcQtXuaWKXd8sTa/472kJJbGvQW9AfooCnzfoPBukcxUE4l01qVbYVOM2+Ge44nJ7NC+yjFxyx0h//boQshXy7bl0+FCG7y7LUTh+3GUlmJwnWW6GTC4GZe56eDS/90DVeLVNVieLLulW65ua67ikiSnvXlzKjuUQB0nSGVZU6LjRwAzExugXiJoPk//+UfAM="}
        expect(response).to redirect_to login_otp_two_factor_auth_index_path(saml: true, RelayState: "https://en.wiki.makerepo.com/wiki/Special:PluggableAuthLogin", SAMLRequest: "fZJvT8IwEMa/ytL328r+AQ1bghAjCeoC0xe+Md12SMPWzl4n+u0dm0YMCa+a3t3vnrunnSGvq4bNW7OXG3hvAY31WVcSWZ+ISaslUxwFMslrQGYKtp3fr5nnUNZoZVShKnKGXCc4ImgjlCTWahmT1zH1ozDMC+7zfAohp9NdMAlpmY85hRENIaT+JCoDvyTWM2jsyJh0jTocsYWVRMOl6ULU82wa2F6QjSLmRYyOXoi17LYRkpue2hvTIHPdmh9AQ6OcQtXuaWKXd8sTa/472kJJbGvQW9AfooCnzfoPBukcxUE4l01qVbYVOM2+Ge44nJ7NC+yjFxyx0h//boQshXy7bl0+FCG7y7LUTh+3GUlmJwnWW6GTC4GZe56eDS/90DVeLVNVieLLulW65ua67ikiSnvXlzKjuUQB0nSGVZU6LjRwAzExugXiJoPk//+UfAM=")
      end

      # it 'should log in (already logged in)' do
      #   user = create(:user, :regular_user)
      #   session[:expires_at] = DateTime.tomorrow.end_of_day
      #   session[:user_id] = user.id
      #   post :auth, params: {submit: "current_user", authenticity_token: "sVnvrlI9nJPjV0owrvX1D02yXMI3hAdRi+qxDi/2nsQEN4FgwqubIqOAGDC0I+u4y4d0/NH8eJhkHZa/XL/32A==", RelayState: "https%3A%2F%2Fen.wiki.makerepo.com%2Fwiki%2FSpecial%3APluggableAuthLogin", SAMLRequest: "fZJRT8IwEMe%2FytL3bd2AQZpBghAjCSqB6YMv5ugOadja2etEv71j04gh4anp3f3uf%2FdvU4KyqMS0dnu9xvcayXmfZaFJtIkxq60WBkiR0FAiCSfFZnq%2FFHHARWWNM9IU7Ay5TgARWqeMZt5iPmavvd62l4CEKNkOcce5jAYwiEYJj4YxjGSUbxMYcY48Z94zWmrIMWsaNThRjQtNDrRrQjyOfd73434WDQUfif7whXnzZhulwbXU3rmKRBiWcECLlQmkKcPTxCE0yzNv%2BjvazGiqS7QbtB9K4tN6%2BQejDo7qoILLJqXJ6wKDal91d%2BrO2AdJbfSCY97qx78bpXOl365bt%2B2KSNxl2cpfPW4yNklPEqK1wk4uBNLwPJ12L%2F3QNF7MV6ZQ8su7NbYEd133FFG5v2tLhbOgSaF2jWFFYY4zi%2BBwzJytkYWTTvL%2Ff5p8Aw%3D%3D"}
      #   expect(response).to have_http_status(200)
      # end

    end

  end

end
