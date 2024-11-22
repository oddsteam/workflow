class ItemController < ApplicationController
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

            item_id = post_data['draggedItemID']
            new_ordering = post_data['destinationIndex'] + 1 # Index starting from zero, ordering is index + 1
            source_ordering = post_data['sourceIndex'] + 1
            source_list_id = post_data['sourceListID']
            destination_list_id = post_data['destinationListID']
            if valid_move?(item_id, @board, source_list_id, destination_list_id, new_ordering)
                begin
                    ActiveRecord::Base.transaction do
                        if source_list_id == destination_list_id
                            if source_ordering < new_ordering
                                # move item to higher order position
                                query = "UPDATE items SET ordering = ordering - 1 WHERE ? < ordering and ordering <= ?"
                                sanitized_query = ActiveRecord::Base.sanitize_sql_array([query, source_ordering, new_ordering])
                                ActiveRecord::Base.connection.execute(sanitized_query)
                            else
                                # move item to lower order position
                                query = "UPDATE items SET ordering = ordering + 1 WHERE ? <= ordering and ordering < ?"
                                sanitized_query = ActiveRecord::Base.sanitize_sql_array([query, new_ordering, source_ordering])
                                ActiveRecord::Base.connection.execute(sanitized_query)
                            end

                            # Insert to the slot
                            Item.where(id: item_id).update(ordering: new_ordering)
                        else
                            # shift up higher order items in destination list for new incoming item
                            query = "UPDATE items SET ordering = ordering + 1 WHERE swimlane_id = ? AND ? <= ordering"
                            sanitized_query = ActiveRecord::Base.sanitize_sql_array([query, destination_list_id, new_ordering])
                            ActiveRecord::Base.connection.execute(sanitized_query)

                            # show down higher order items in source list to close gap
                            query = "UPDATE items SET ordering = ordering - 1 WHERE swimlane_id = ? AND ordering > ?"
                            sanitized_query = ActiveRecord::Base.sanitize_sql_array([query, source_list_id, source_ordering])
                            ActiveRecord::Base.connection.execute(sanitized_query)

                            # Move item into empty slot
                            Item.where(id: item_id).update(swimlane_id: destination_list_id, ordering: new_ordering)
                        end
                    end
                rescue => e
                    # something went wrong, transaction rolled back
                    Rails.logger.error(e)
                    raise ActiveRecord::Rollback
                    render_internal_server_error
                end

                # begin
                #     ActiveRecord::Base.transaction do
                #         query = <<~SQL
                #             UPDATE items
                #             SET ordering = p.row_number
                #             FROM (SELECT id, ROW_NUMBER() OVER (ORDER BY ordering) AS row_number FROM items WHERE items.swimlane_id = ?) AS p
                #             WHERE items.id = p.id;
                #         SQL
                #         sanitized_query = ActiveRecord::Base.sanitize_sql_array([query, source_list_id])
                #         ActiveRecord::Base.connection.execute(sanitized_query)

                #         query = <<~SQL
                #             UPDATE items
                #             SET ordering = p.row_number
                #             FROM (SELECT id, ROW_NUMBER() OVER (ORDER BY ordering) AS row_number FROM items WHERE items.swimlane_id = ?) AS p
                #             WHERE items.id = p.id;
                #         SQL
                #         sanitized_query = ActiveRecord::Base.sanitize_sql_array([query, destination_list_id])
                #         ActiveRecord::Base.connection.execute(sanitized_query)
                #     end
                # rescue => e
                #     # something went wrong, transaction rolled back
                #     Rails.logger.error(e)
                #     raise ActiveRecord::Rollback
                #     render_internal_server_error
                # end

                # reload board
                @board = Board.includes(swimlanes: :items)
                    .find_by(key: board_key)
                if @board.present?
                    source_swimlane = @board.swimlanes.where(id: source_list_id).first
                    destination_swimlane = @board.swimlanes.where(id: destination_list_id).first
                    respond_to do |format|
                        format.turbo_stream {
                            render turbo_stream: [
                                turbo_stream
                                    .replace("swimlane_#{source_list_id}_entries",
                                    partial: "shared/swimlane_entries",
                                    locals: { board: @board, swimlane: source_swimlane }),
                                turbo_stream
                                    .replace("swimlane_#{destination_list_id}_entries",
                                    partial: "shared/swimlane_entries",
                                    locals: { board: @board, swimlane: destination_swimlane }),
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
    end

    private

    def valid_move?(item_id, board, source_list_id, destination_list_id, new_ordering)
        # Validate operation : valid item?
        if new_ordering < 0
            Rails.logger.debug("Negative ordering detected")
            return false
        end

        @swimlane = Swimlane.where(board_id: board.id, id: source_list_id)
        if !@swimlane.present?
            Rails.logger.debug("Source swimlane does not present in the board")
            return false
        end

        @swimlane = Swimlane.where(board_id: board.id, id: destination_list_id)
        if !@swimlane.present?
            Rails.logger.debug("Destination swimlane does not present in the board")
            return false
        end

        @item = Item.where(swimlane_id: source_list_id, id: item_id)
        if !@item.present?
            Rails.logger.debug("Moving item does not present in the source swimlane")
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
