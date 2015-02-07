
ActionMailer::Base.smtp_settings = {
    :address              => "localhost",
    :port                 => 25

}

ActionMailer::Base.view_paths = '../views'

class TestUserMailer < ActionMailer::Base
  default :from => "readings@astrology.com"

  def mail_user(email,subject,firstname)
    @firstname=firstname
    @subject=subject
    mail(to: email, subject: subject) do |format|
      format.html
    end
  end
end