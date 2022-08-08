require "rails_helper"

RSpec.describe UsersController, type: :controller do
  describe "new" do
    context "new" do
      it "should redirect the already signed_in user to the root" do
        user = create(:user, :regular_user)
        session[:user_id] = user.id
        session[:expires_at] = Time.zone.now + 10_000
        get :new
        expect(response).to redirect_to root_path
      end

      it "should give a 200" do
        get :new
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET /resend_confirmation" do
    context "send confirmation" do
      it "should send confirmation" do
        user = create(:user, :regular_user_not_confirmed)
        get :resend_confirmation, params: { user: { email: user.email } }
        expect(ActionMailer::Base.deliveries.count).to eq(1)
        expect(ActionMailer::Base.deliveries.first.to.first).to eq(user.email)
      end
    end
  end

  describe "GET /confirm" do
    context "confirm" do
      it "should confirm the user" do
        user = create(:user, :regular_user_not_confirmed)
        @hash = Rails.application.message_verifier(:user).generate(user.id)
        get :confirm, params: { token: @hash }
        expect(response).to redirect_to root_path
        expect(flash[:notice]).to eq(
          "The email has been confirmed, you can now fully use your Makerepo Account !"
        )
        expect(User.find(user.id).confirmed?).to be_truthy
        expect(ActionMailer::Base.deliveries.count).to eq(1)
        expect(ActionMailer::Base.deliveries.first.to.first).to eq(user.email)
      end

      it "should not confirm the user" do
        user = create(:user, :regular_user_not_confirmed)
        get :confirm, params: { token: "abc" }
        expect(response).to redirect_to root_path
        expect(flash[:alert]).to eq(
          "Something went wrong. Try to access the page again or send us an email at uottawa.makerepo@gmail.com"
        )
        expect(User.find(user.id).confirmed?).to be_falsey
      end
    end
  end

  describe "GET /confirm_edited_email" do
    context "confirm_edited_email" do
      it "should confirm the email" do
        user = create(:user, :regular_user)
        old_email = user.email
        session[:user_id] = user.id
        session[:expires_at] = Time.zone.now + 10_000
        @user_hash = Rails.application.message_verifier(:user).generate(user.id)
        @email_hash =
          Rails.application.message_verifier(:email).generate("bob@bob.ca")
        get :confirm_edited_email,
            params: {
              email_token: @email_hash,
              user_token: @user_hash
            }
        expect(response).to redirect_to root_path
        expect(ActionMailer::Base.deliveries.count).to eq(1)
        expect(ActionMailer::Base.deliveries.first.to.first).to eq(old_email)
        expect(User.last.email).to eq("bob@bob.ca")
        expect(flash[:notice]).to eq(
          "The email has been updated to bob@bob.ca !"
        )
      end

      it "should not confirm the user" do
        user = create(:user, :regular_user_not_confirmed)
        old_email = user.email
        session[:user_id] = user.id
        session[:expires_at] = Time.zone.now + 10_000
        @email_hash =
          Rails.application.message_verifier(:email).generate("bob@bob.ca")
        get :confirm_edited_email,
            params: {
              email_token: @email_hash,
              user_token: ""
            }
        expect(response).to redirect_to root_path
        expect(flash[:alert]).to eq(
          "Something went wrong. Try to access the page again or send us an email at uottawa.makerepo@gmail.com"
        )
        expect(User.last.email).to eq(old_email)
      end
    end
  end

  describe "POST /flag" do
    context "flag" do
      it "should flag user" do
        admin = create(:user, :admin)
        session[:user_id] = admin.id
        session[:expires_at] = Time.zone.now + 10_000
        user = create(:user, :regular_user)
        post :flag,
             params: {
               flagged_user: user.id,
               flag: "flag",
               flag_message: "abc"
             }
        expect(response).to redirect_to user_path(user.username)
        expect(User.last.flagged?).to be_truthy
        expect(User.last.flag_message).to eq("; abc")
      end

      it "should unflag user" do
        admin = create(:user, :admin)
        session[:user_id] = admin.id
        session[:expires_at] = Time.zone.now + 10_000
        user = create(:user, :regular_user, flagged: true, flag_message: "abc")
        post :unflag, params: { flagged_user: user.id }
        expect(response).to redirect_to user_path(user.username)
        expect(User.last.flagged?).to be_falsey
        expect(User.last.flag_message).to eq(nil)
      end

      it "should redirect user" do
        user = create(:user, :regular_user)
        session[:user_id] = user.id
        session[:expires_at] = Time.zone.now + 10_000
        post :flag, params: { flagged_user: user.id, flag: "flag" }
        expect(response).to redirect_to user_path(user.username)
      end
    end
  end

  describe "PUT /remove_flag" do
    context "logged as admin" do
      it "should remove flag user" do
        admin = create(:user, :admin)
        session[:user_id] = admin.id
        session[:expires_at] = Time.zone.now + 10_000
        user =
          create(:user, :regular_user, flag_message: "; abc", flagged: true)
        put :remove_flag, params: { repo_user_id: user.id, flag_msg: "abc" }
        expect(response).to redirect_to user_path(user.username)
        expect(User.last.flagged?).to be_falsey
        expect(User.last.flag_message).to eq("")
      end
    end

    context "logged as regular user" do
      it "should redirect user" do
        user = create(:user, :regular_user, flag_message: "abc", flagged: true)
        session[:user_id] = user.id
        session[:expires_at] = Time.zone.now + 10_000
        put :remove_flag, params: { repo_user_id: user.id, flag_msg: "abc" }
        expect(response).to redirect_to user_path(user.username)
      end
    end
  end

  describe "GET /new" do
    context "new" do
      it "should give a 200" do
        get :new
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "POST /create" do
    context "create user" do
      it "should create the user" do
        user_params =
          FactoryBot.attributes_for(
            :user,
            :regular_user,
            password: "asa32A353#"
          )
        expect { post :create, params: { user: user_params } }.to change(
          User,
          :count
        ).by(1)
        expect(response).to redirect_to root_path
        expect(flash[:notice]).to eq(
          "Account has been created, please look in your emails to confirm your email address."
        )
      end

      it "should create the user with avatar" do
        user_params =
          FactoryBot.attributes_for(
            :user,
            :regular_user_with_avatar,
            password: "asa32A353#"
          )
        expect { post :create, params: { user: user_params } }.to change(
          User,
          :count
        ).by(1)
        expect(response).to redirect_to root_path
        expect(flash[:notice]).to eq(
          "Account has been created, please look in your emails to confirm your email address."
        )
      end

      it "should create the user with avatar" do
        user_params =
          FactoryBot.attributes_for(
            :user,
            :regular_user,
            username: "abcdefghijklmnopqrstuvwxyz"
          )
        expect { post :create, params: { user: user_params } }.to change(
          User,
          :count
        ).by(0)
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "remove_avatar" do
    context "remove avatar" do
      it "should remove the avatar and display the default avatar" do
        user = create(:user, :regular_user_with_avatar)
        session[:user_id] = user.id
        session[:expires_at] = Time.zone.now + 10_000
        get :remove_avatar
        expect(response).to redirect_to settings_profile_path
        user = User.find(user.id)
        expect(user.display_avatar).to eq("default-avatar.png")
      end

      it "should remove nothing and not give an error" do
        user = create(:user, :regular_user)
        session[:user_id] = user.id
        session[:expires_at] = Time.zone.now + 10_000
        get :remove_avatar
        expect(response).to redirect_to settings_profile_path
        expect(user.display_avatar).to eq("default-avatar.png")
      end
    end
  end

  describe "update" do
    context "update" do
      before(:each) do
        user = create(:user, :regular_user)
        session[:user_id] = user.id
        session[:expires_at] = Time.zone.now + 10_000
      end

      it "should update the profile" do
        patch :update,
              params: {
                username: User.last.username,
                user: {
                  name: "John Doe"
                }
              }
        expect(response).to redirect_to settings_profile_path
        expect(flash[:notice]).to eq("Profile updated successfully.")
      end

      it "should update the profile to a student" do
        patch :update,
              params: {
                username: User.last.username,
                user: {
                  name: "John Doe",
                  identity: "undergrad",
                  program: "BASc in Software Engineering",
                  faculty: "Engineering",
                  year_of_study: 1,
                  student_id: 300_123_456
                }
              }
        expect(response).to redirect_to settings_profile_path
        expect(User.last.identity).to eq("undergrad")
        expect(flash[:notice]).to eq("Profile updated successfully.")
      end

      it "should not update the profile to a student" do
        patch :update,
              params: {
                username: User.last.username,
                user: {
                  name: "John Doe",
                  identity: "undergrad"
                }
              }
        expect(response).to redirect_to settings_profile_path
        expect(User.last.identity).to eq("community_member")
        expect(flash[:alert]).to eq("Could not save changes.")
      end

      it "should fail to update the profile" do
        patch :update,
              params: {
                username: User.last.username,
                user: {
                  name: ""
                }
              }
        expect(response).to redirect_to settings_profile_path
        expect(flash[:alert]).to eq("Could not save changes.")
      end
    end
  end

  describe "change_password" do
    context 'change user\'s password' do
      before(:each) do
        user = create(:user, :regular_user)
        session[:user_id] = user.id
        session[:expires_at] = Time.zone.now + 10_000
      end

      it "should change the password" do
        @oldpass = User.last.password
        patch :change_password,
              params: {
                username: User.last.username,
                user: {
                  old_password: "asa32A353#",
                  password: "Password2",
                  password_confirmation: "Password2"
                }
              }
        @newpass = User.find(User.last.id).password
        expect(@oldpass).not_to be(@newpass)
        expect(ActionMailer::Base.deliveries.count).to eq(1)
        expect(response).to redirect_to settings_admin_path
        expect(flash[:notice]).to eq(
          "Password changed successfully, an email will be sent to confirm."
        )
      end

      it 'shouldn\'t change password (Wrong password)' do
        patch :change_password,
              params: {
                username: User.last.username,
                user: {
                  old_password: "Password1",
                  password: "Password2",
                  password_confirmation: "Password2"
                }
              }
        expect(ActionMailer::Base.deliveries.count).to eq(0)
        expect(response).to have_http_status(:success)
        expect(flash[:alert]).to eq("Incorrect old password.")
      end

      it 'shouldn\'t change password (Confirmation doesn\'t match)' do
        @oldpass = User.last.password
        patch :change_password,
              params: {
                username: User.last.username,
                user: {
                  old_password: "asa32A353#",
                  password: "Password2",
                  password_confirmation: "Password3"
                }
              }
        @newpass = User.find(User.last.id).password
        expect(ActionMailer::Base.deliveries.count).to eq(0)
        expect(@oldpass).not_to be(@newpass)
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET /change_email" do
    context 'change user\'s email' do
      before(:each) do
        user = create(:user, :regular_user)
        session[:user_id] = user.id
        session[:expires_at] = Time.zone.now + 10_000
      end

      it "should send confirmation email" do
        get :change_email,
            params: {
              new_email: "bobbb@bobbb.ca",
              confirm_new_email: "bobbb@bobbb.ca"
            }
        expect(response).to redirect_to settings_admin_path
        expect(flash[:notice]).to eq(
          "A confirmation email has been sent to the new email"
        )
        expect(ActionMailer::Base.deliveries.first.to.first).to eq(
          "bobbb@bobbb.ca"
        )
        expect(ActionMailer::Base.deliveries.count).to eq(1)
      end

      it 'shouldn\'t change password (email already used)' do
        get :change_email,
            params: {
              new_email: User.last.email,
              confirm_new_email: User.last.email
            }
        expect(response).to redirect_to settings_admin_path
        expect(flash[:alert]).to eq(
          "This email is already used by a MakerRepo Account."
        )
      end

      it 'shouldn\'t change password (Confirmation doesn\'t match)' do
        get :change_email,
            params: {
              new_email: "bobbb@bobbb.ca",
              confirm_new_email: "bobbb1@bobbb.ca"
            }
        expect(response).to redirect_to settings_admin_path
        expect(flash[:alert]).to eq(
          "This confirmation email isn't matching the new email"
        )
      end
    end
  end

  describe "change_programs" do
    context "Repo user" do
      it "should not change programs" do
        user = create(:user, :regular_user)
        session[:user_id] = user.id
        session[:expires_at] = Time.zone.now + 10_000
        expect {
          post :change_programs, params: { user_id: user.id, volunteer: 1 }
        }.to change(Program, :count).by(0)
        expect(response).to redirect_to root_path
        expect(flash[:alert]).to eq(
          "An error occurred: A user must me selected; You need to be staff/admin to change the programs."
        )
      end
    end

    context "Admin" do
      it "should change programs" do
        user = create(:user, :admin)
        session[:user_id] = user.id
        session[:expires_at] = Time.zone.now + 10_000
        expect {
          post :change_programs, params: { user_id: user.id, volunteer: 1 }
        }.to change(Program, :count).by(1)
        expect(response).to redirect_to user_path(user.username)
        expect(flash[:notice]).to eq(
          "The programs for #{user.name} has been updated!"
        )
      end
    end
  end

  describe "show" do
    context "repo user" do
      before(:each) do
        user = create(:user, :regular_user)
        session[:user_id] = user.id
        session[:expires_at] = Time.zone.now + 10_000
      end

      it "should return the right repo user (own page)" do
        get :show, params: { username: User.last.username }
        expect(@controller.instance_variable_get(:@repo_user).id).to eq(
          User.last.id
        )
      end

      it "should return the right repo user (someone elses)" do
        other_user = create(:user, :regular_user)
        get :show, params: { username: other_user.username }
        expect(@controller.instance_variable_get(:@repo_user).id).to eq(
          other_user.id
        )
      end
    end

    describe "repos" do
      before(:each) do
        user = create(:user, :regular_user)
        session[:user_id] = user.id
        session[:expires_at] = Time.zone.now + 10_000
      end

      it "should get all repos" do
        create(:repository)
        Repository.last.users << User.last
        create(:repository, :private)
        Repository.last.users << User.last
        get :show, params: { username: User.last.username }
        expect(@controller.instance_variable_get(:@repositories).count).to eq(2)
      end

      it "should get only public repos" do
        other_user = create(:user, :regular_user)
        create(:repository)
        Repository.last.users << User.find(other_user.id)
        create(:repository, :private)
        Repository.last.users << User.find(other_user.id)
        get :show, params: { username: other_user.username }
        expect(@controller.instance_variable_get(:@repositories).count).to eq(1)
      end
    end

    describe "badge url" do
      before(:each) do
        user = create(:user, :regular_user)
        session[:user_id] = user.id
        session[:expires_at] = Time.zone.now + 10_000
      end

      it "should return the share link" do
        get :show, params: { username: User.last.username }
        expect(@controller.instance_variable_get(:@acclaim_badge_url)).to eq(
          "https://www.youracclaim.com/earner/earned/share/"
        )
      end

      it "should return the public link" do
        other_user = create(:user, :regular_user)
        get :show, params: { username: other_user.username }
        expect(@controller.instance_variable_get(:@acclaim_badge_url)).to eq(
          "https://www.youracclaim.com/badges/"
        )
      end
    end
  end

  describe "likes" do
    context "likes" do
      it "should display 2 likes" do
        user = create(:user, :regular_user)
        session[:user_id] = user.id
        session[:expires_at] = Time.zone.now + 10_000
        repo1 = create(:repository)
        repo2 = create(:repository, :private)
        Like.create(user_id: user.id, repository_id: repo1.id)
        Like.create(user_id: user.id, repository_id: repo2.id)
        get :likes, params: { username: user.username }
        expect(response).to have_http_status(:success)
        expect(@controller.instance_variable_get(:@repositories).count).to eq(2)
      end
    end
  end

  describe "destroy" do
    context "destroy" do
      it "should delete the user" do
        user = create(:user, :regular_user)
        session[:user_id] = user.id
        session[:expires_at] = Time.zone.now + 10_000
        delete :destroy, params: { username: user.username }
        expect(response).to redirect_to root_path
        expect { User.find(user.id) }.to raise_exception(
          ActiveRecord::RecordNotFound
        )
      end
    end
  end

  describe "vote" do
    context "votes" do
      before(:each) do
        user = create(:user, :regular_user)
        session[:user_id] = user.id
        session[:expires_at] = Time.zone.now + 10_000
      end

      it "should up vote the comment" do
        comment = create(:comment)
        create(:comment)
        post :vote,
             params: {
               comment_id: comment.id,
               downvote: "f",
               voted: false
             },
             format: "json"
        expect(Comment.find(comment.id).user.reputation).to eq(2)
        expect(Comment.find(comment.id).upvote).to eq(1)
      end

      it "should up down vote the comment" do
        comment = create(:comment)
        create(:comment)
        post :vote,
             params: {
               comment_id: comment.id,
               downvote: "t",
               voted: false
             },
             format: "json"
        expect(Comment.find(comment.id).user.reputation).to eq(-2)
        expect(Comment.find(comment.id).upvote).to eq(-1)
      end
    end

    context "voted" do
      it "should up downvote an upvoted comment the comment" do
        user = create(:user, :regular_user)
        session[:user_id] = user.id
        session[:expires_at] = Time.zone.now + 10_000
        comment = create(:comment)
        create(:comment)
        Upvote.create(user_id: user.id, comment_id: comment.id, downvote: false)
        post :vote,
             params: {
               comment_id: comment.id,
               downvote: "t",
               voted: true
             },
             format: "json"
        expect(Comment.find(comment.id).upvote).to eq(-1)
      end

      it "should up downvote an downvoted comment the comment" do
        user = create(:user, :regular_user)
        session[:user_id] = user.id
        session[:expires_at] = Time.zone.now + 10_000
        comment = create(:comment)
        create(:comment)
        Upvote.create(user_id: user.id, comment_id: comment.id, downvote: true)
        post :vote,
             params: {
               comment_id: comment.id,
               downvote: "t",
               voted: true
             },
             format: "json"
        expect(Comment.find(comment.id).upvote).to eq(0)
      end

      it "should up downvote an voted comment the comment" do
        user = create(:user, :regular_user)
        session[:user_id] = user.id
        session[:expires_at] = Time.zone.now + 10_000
        create(:repository)
        comment = create(:comment)
        create(:comment)
        post :vote,
             params: {
               comment_id: comment.id,
               downvote: "t",
               voted: true
             },
             format: "json"
        expect(response).to have_http_status(500)
      end
    end
  end
end
