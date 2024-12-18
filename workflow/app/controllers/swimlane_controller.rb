class SwimlaneController < ApplicationController
    def move
        # Example payload
        # {
        #   "draggedItemID":"0",
        #   "sourceListID":"root",
        #   "sourceOrder":[null,"1","0","2"],
        #   "sourceIndex":1,
        #   "destinationListID":"root",
        #   "destinationOrder":[null,"1","0","2"],
        #   "destinationIndex":2
        # }
        board_key = params[:key]
        @board = Board.includes(:swimlanes)
                    .find_by(key: board_key)
        if @board.present?
            post_data = JSON.parse(request.body.read)

            swimlane_id = post_data['draggedItemID']
            new_ordering = post_data['destinationIndex'] + 1 # Index starting from zero, ordering is index + 1
            source_ordering = post_data['sourceIndex'] + 1
            if valid_move?(swimlane_id, @board, new_ordering)
                begin
                    ActiveRecord::Base.transaction do
                        if source_ordering < new_ordering
                            query = "UPDATE swimlanes SET ordering = ordering - 1 WHERE ? < ordering and ordering <= ?"
                            sanitized_query = ActiveRecord::Base.sanitize_sql_array([query, source_ordering, new_ordering])
                            ActiveRecord::Base.connection.execute(sanitized_query)
                        else
                            query = "UPDATE swimlanes SET ordering = ordering + 1 WHERE ? <= ordering and ordering < ?"
                            sanitized_query = ActiveRecord::Base.sanitize_sql_array([query, new_ordering, source_ordering])
                            ActiveRecord::Base.connection.execute(sanitized_query)
                        end

                        # Insert to the slot
                        Swimlane.where(id: swimlane_id).update(ordering: new_ordering)
                    end
                rescue => e
                    # something went wrong, transaction rolled back
                    Rails.logger.error(e)
                    raise ActiveRecord::Rollback
                    render_internal_server_error
                end

                begin
                    ActiveRecord::Base.transaction do
                        query = <<~SQL
                            UPDATE swimlanes
                            SET ordering = p.row_number
                            FROM (SELECT id, ROW_NUMBER() OVER (ORDER BY ordering) AS row_number FROM swimlanes WHERE swimlanes.board_id = ?) AS p
                            WHERE swimlanes.id = p.id;
                        SQL
                        sanitized_query = ActiveRecord::Base.sanitize_sql_array([query, @board.id])
                        ActiveRecord::Base.connection.execute(sanitized_query)
                    end
                rescue => e
                    # something went wrong, transaction rolled back
                    Rails.logger.error(e)
                    raise ActiveRecord::Rollback
                    render_internal_server_error
                end

                # reload board
                @board = Board.includes(swimlanes: :items)
                    .find_by(key: board_key)
                if @board.present?
                    respond_to do |format|
                        format.turbo_stream { render turbo_stream: turbo_stream.replace('board_entries', partial: 'shared/board_entries', locals: { board: @board }) }
                        format.html { render file: "#{Rails.root}/public/500.html", layout: false, status: :internal_server_error }
                        format.any  { head :internal_server_error }
                    end
                else
                    Rails.logger.debug("board is updated but cannot be refreshed")
                    render_not_found
                end
            else
                render_forbidden
            end
        else
            Rails.logger.debug("board is not updated because board is not found")
            render_not_found
        end
    end

    private

    def valid_move?(swimlane_id, board, new_ordering)
        # Validate operation : valid item?
        if new_ordering < 0
            Rails.logger.debug("Negative ordering detected")
            return false
        end

        @swimlane = Swimlane.where(board_id: board.id, id: swimlane_id)
        if !@swimlane.present?
            Rails.logger.debug("Moving swimlane does not present in the board")
            return false
        end
        
        return true
    end

    def render_forbidden
        respond_to do |format|
            format.any  { head :forbidden }
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
