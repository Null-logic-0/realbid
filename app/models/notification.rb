class Notification < ApplicationRecord
  belongs_to :user

  def broadcast
    Turbo::StreamsChannel.broadcast_append_to(
      user,
      target: "notifications",
      content: ApplicationController.render(
        partial: "notifications/notification",
        locals: { notification: self }
      )
    )
  end
end
