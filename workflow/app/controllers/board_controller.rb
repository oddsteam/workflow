class BoardController < ApplicationController
    def index()
        @my_boards = Board.where(user_id: 1)
    end

    def create()
        board_key = generate_unique_board_key
        board_title = params[:title]
        @board = Board.new(
            board_params.merge(
                key: board_key,
                title: board_title,
                user_id: 1
            )
        )
        if @board.save
            # Auto create To do, Doing, Done swimlane
            Swimlane.new(
                board_id: @board[:id],
                title: "To do",
                ordering: 1
            ).save
            Swimlane.new(
                board_id: @board[:id],
                title: "Doing",
                ordering: 2
            ).save
            Swimlane.new(
                board_id: @board[:id],
                title: "Done",
                ordering: 3
            ).save

            redirect_to board_path(@board.key)
        else
            render_internal_server_error
        end
    end

    def show()
        board_key = params[:key]
        @board = Board.includes(swimlanes: :items)
                    .find_by(key: board_key)
        if !@board.present?
            render_not_found
        end
    end

    def rename()
        board_key = params[:key]
        @board = Board.find_by(key: board_key)
        if @board.present?
            post_data = JSON.parse(request.body.read)

            new_board_title = post_data['new']
            Board.where(key: board_key).update(title: new_board_title)

            @board = Board.find_by(key: board_key)
            if @board.present?
                respond_to do |format|
                    format.turbo_stream {
                        render turbo_stream: [
                            turbo_stream
                                .replace("board_#{@board.id}_title",
                                partial: "shared/board_title",
                                locals: { board: @board }),
                        ]
                    }
                    format.html { render file: "#{Rails.root}/public/500.html", layout: false, status: :internal_server_error }
                    format.any  { head :internal_server_error }
                end
            else
                Rails.logger.debug("board is updated but cannot be refreshed")
                render_not_found
            end
        end
    end

    private

    def board_params
        params.permit(
            :key,
            :user_id,
            :title,
        )
    end

    def generate_unique_board_key
        loop do
            key = SecureRandom.alphanumeric(16)
            break key unless Board.exists?(key: key)
        end
    end

    def render_internal_server_error
        respond_to do |format|
            format.html { render file: "#{Rails.root}/public/500.html", layout: false, status: :internal_server_error }
            format.any  { head :internal_server_error }
        end
    end

    def render_not_found
        respond_to do |format|
            format.html { render file: "#{Rails.root}/public/404.html", layout: false, status: :not_found }
            format.any  { head :not_found }
        end
    end
end
