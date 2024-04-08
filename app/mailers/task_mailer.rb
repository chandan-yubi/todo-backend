class TaskMailer < ApplicationMailer
    def task_notification(task)
      @task = task
      mail(
        to: "thakurchandan4562@gmail.com",
        from: "chandanthakur5225@gmail.com",
        subject: "Result Test mail"
      )
    end
  end
  