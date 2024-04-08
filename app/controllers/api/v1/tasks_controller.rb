module Api
    module V1
        class TasksController < ApplicationController
            before_action :authenticate_user
            skip_before_action :verify_authenticity_token
            def index
                tasks = current_user.tasks
                serialized_data = TasksSerializer.new(tasks).serialized_json
                json_data = JSON.parse(serialized_data)
                render json: json_data['data']
            end

            def show
                task_id = params[:id]
                task = nil
                begin
                    task = Task.find(task_id)
                rescue
                    render json: {error: 'Task Not Found'}, status: :not_found
                    return
                end
                
                if task.user_id != current_user.id
                    render json: {error: 'You are not Authorized to view this Task'}, status: :unauthorized
                else
                    TaskMailer.task_notification(task).deliver_now
                    render json: TasksSerializer.new(task).serialized_json, status: :ok
                end
            end

            def create
                task = Task.new(task_params)
                task.user_id = current_user.id

                begin
                    ActiveRecord::Base.transaction do
                        if task.save
                            status_response = create_status_fun(task.id, "TO-DO")
                            tags = params[:tags]
                            if tags
                                tags.each do |tag|
                                    create_tag_fun(task.id, tag[:tag])
                                end
                            end
                            if !response
                                Task.destroy(task.id)
                                render json: {error: 'Task Not Created'}, status: :unprocessable_entity
                            end
                            TaskMailer.task_notification(task).deliver_now
                            render json: TasksSerializer.new(task).serialized_json, status: :created
                        else
                            render json: {errors: task.errors}, status: :unprocessable_entity
                        end
                    end
                rescue
                    render json: {error: 'Task Not Created'}, status: :unprocessable_entity
                end
                
            end

            def update
                task = Task.find(params[:id])
                if task.user_id == current_user.id
                    if task.update(task_params)
                        update_tags(task, params[:tags])
                        render json: TasksSerializer.new(Task.find(params[:id])).serialized_json, status: :ok
                    else
                        render json: {error: 'Task Not Updated'}, status: :unprocessable_entity
                    end
                else
                    render json: {error: 'You are not Authorized to update this Task'}, status: :unauthorized
                end
            end
            
            def destroy
                task = Task.find(params[:id])
                if task.user_id == current_user.id
                    if task.destroy
                        render json: {message: 'Task Deleted'}, status: :ok
                    else
                        render json: {error: 'Task Not Deleted'}, status: :unprocessable_entity
                    end
                else
                    render json: {error: 'You are not Authorized to delete this Task'}, status: :unauthorized
                end
            end

            def create_status
                task = Task.find(params[:task_id])
                if task.user_id == current_user.id
                    if create_status_fun(params[:task_id], params[:status])
                        render json: {message: 'Status Created'}, status: :created
                    else
                        render json: {error: 'Status Not Created'}, status: :unprocessable_entity
                    end
                else
                    render json: {error: 'You are not Authorized to create status for this Task'}, status: :unauthorized
                end
            end



            private
            def task_params
                params.require(:task).permit(:title, :description, :due_date, :priority, :remainder, :attachment, :group)
            end

            def status_params
                params.require(:status).permit(:task_id, :status)
            end

            def create_status_fun(task_id, status)
                status = Status.new({task_id: task_id, status: status})
                if status.save
                    return true
                else
                    return false
                end
            end

            def find_latest_status(task_id)
                status = Status.where(task_id: task_id).order(created_at: :desc).first
                return status
            end

            def create_tag_fun(task_id, tag)
                tag = Tag.new({task_id: task_id, tag: tag})
                if tag.save
                    return true
                else
                    return false
                end
            end

            def update_tags(task, new_tags)
                existing_tags = task.tag
                existing_tags_list = existing_tags.map { |tag| tag.tag }
                new_tags_list = new_tags.map { |tag| tag[:tag] }
                tags_to_add = new_tags_list - existing_tags_list
                tags_to_delete = existing_tags_list - new_tags_list
                tags_to_add.each do |tag|
                    create_tag_fun(task.id, tag)
                end
                tags_to_delete.each do |tag|
                    Tag.find_by(task_id: task.id, tag: tag).destroy
                end
            end



        end
    end
end