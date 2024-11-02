class WorkspaceController < ApplicationController
    def index
        @my_boards = Board.where(user_id: 1)
    end
end
