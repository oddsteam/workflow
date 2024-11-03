class BoardController < ApplicationController
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
            redirect_to board_path(@board.key)
        else
            render_internal_server_error
        end
    end

    def show()
        board_key = params[:key]
        @board = Board.find_by(
            key: board_key
        )
        unless @board
            render_not_found
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
