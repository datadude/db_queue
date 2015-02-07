require File.join(File.dirname(__FILE__),'../test_environment')
class TestMailer < Minitest::Test
  describe TestUserMailer do
    before do
      TestUserMailer.mail_user('bogus@bogus.com',"Thank-you for your purchase of a bogus article",'Bogus').deliver
    end
    it 'should mail a user with the correct subject' do
       assert_equal(ActionMailer::Base.deliveries[0].subject,'Thank-you for your purchase of a bogus article')
    end
    it 'should mail a user with the correct email' do
      assert_equal(ActionMailer::Base.deliveries[0].to,['bogus@bogus.com'])
    end
    it 'should mail a user with the rending the correct template' do
      assert_match(/<h1>Hello Bogus <\/h1>/,ActionMailer::Base.deliveries[0].body.encoded)
    end
  end

end