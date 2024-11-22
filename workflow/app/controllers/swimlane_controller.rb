class SwimlaneController < ApplicationController
    def move
        # Example payload
        # {
        #   "draggedItem":"0",
        #   "sourceList":"root",
        #   "sourceOrder":[null,"1","0","2"],
        #   "sourceIndex":1,
        #   "destinationList":"root",
        #   "destinationOrder":[null,"1","0","2"],
        #   "destinationIndex":2
        # }
        board_key = params[:key]
        @board = Board.includes(:swimlanes)
                    .find_by(key: board_key)
        if @board.present?
            post_data = JSON.parse(request.body.read)

            swimlane_id = post_data['draggedItemID']
            new_index = post_data['destinationIndex']
            source_index = post_data['sourceIndex']
            if valid_move?(swimlane_id, @board, new_index)
                begin
                    ActiveRecord::Base.transaction do
                        if source_index < new_index
                            # Shift lower part down
                            swimlane_index = source_index
                            @board.swimlanes.where("? < ordering and ordering <= ?", source_index, new_index).find_each do |swimlane|
                                Rails.logger.debug("ID #{swimlane}: #{swimlane.ordering} -> #{swimlane_index}")
                                swimlane.update!(ordering: swimlane_index)
                                swimlane_index += 1
                            end
                        else
                            # Shift upper part up
                            swimlane_index = new_index + 1
                            @board.swimlanes.where("? <= ordering and ordering < ?", new_index, source_index).find_each do |swimlane|
                                Rails.logger.debug("ID #{swimlane}: #{swimlane.ordering} -> #{swimlane_index}")
                                swimlane.update!(ordering: swimlane_index)
                                swimlane_index += 1
                            end
                        end

                        # Insert to the slot
                        Swimlane.where(id: swimlane_id).find_each do |swimlane|
                            Rails.logger.debug("ID #{swimlane}: #{swimlane.ordering} -> #{new_index}")
                            swimlane.update!(ordering: new_index)
                        end
                    end

                    # reload board
                    @board = Board.includes(swimlanes: :items)
                        .find_by(key: board_key)
                    if !@board.present?
                        respond_to do |format|
                            format.turbo_stream { render turbo_stream: turbo_stream.replace('board_entries', partial: 'shared/board_entries', locals: { board: @board }) }
                            format.html { render file: "#{Rails.root}/public/500.html", layout: false, status: :internal_server_error }
                            format.any  { head :internal_server_error }
                        end
                    else
                        render_not_found
                    end            
                rescue => e
                    # something went wrong, transaction rolled back
                    raise ActiveRecord::Rollback
                    render_internal_server_error
                end
            else
                render_forbidden
            end
        else
            render_not_found
        end
    end

    private

    def valid_move?(swimlane_id, board, new_index)
        # Validate operation : valid item?
        if new_index < 1
            return false
        end

        @swimlane = Swimlane.where(board_id: board.id, id: swimlane_id)
        if !@swimlane.present?
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
