module MailerMacros

  def last_email
    ActionMailer::Base.deliveries.last
  end

  def last_email_text
    ActionMailer::Base.deliveries.last.body.raw_source
  end

  # for multi-part e-mails, first need to select the correct part

  def last_multipart_raw(index)
    ActionMailer::Base.deliveries.last.parts[index].body.raw_source
  end

  def reset_email
    ActionMailer::Base.deliveries = []
  end
end

RSpec.configure do |config|
  config.include(MailerMacros)
  config.before(:each) { reset_email }
end
