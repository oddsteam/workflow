# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

if Rails.env.development?
    @kanban_board = Board.new(title: "Kanban", key: "kanban-123456", user_id: 1)
    @kanban_board.save

    @scrum_board = Board.new(title: "Scrum", key: "scrum-123456", user_id: 1)
    @scrum_board.save

    @initiative_lane = Swimlane.new(board_id: @kanban_board[:id], title: "Initiative", ordering: 1)
    @initiative_lane.save
    Swimlane.new(board_id: @kanban_board[:id], title: "To do", ordering: 2).save
    Swimlane.new(board_id: @kanban_board[:id], title: "Doing", ordering: 3).save
    Swimlane.new(board_id: @kanban_board[:id], title: "Done", ordering: 4).save

    @todo_lane = Swimlane.new(board_id: @scrum_board[:id], title: "To do", ordering: 1)
    @todo_lane.save
    Swimlane.new(board_id: @scrum_board[:id], title: "Doing", ordering: 2).save
    Swimlane.new(board_id: @scrum_board[:id], title: "Done", ordering: 3).save

    Item.new(title: "Test item 1", swimlane_id: @initiative_lane[:id], user_id: 1, ordering: 1).save
    Item.new(title: "Test item 2", swimlane_id: @initiative_lane[:id], user_id: 1, ordering: 2).save
    Item.new(title: "Test item 3", swimlane_id: @initiative_lane[:id], user_id: 1, ordering: 3).save
    Item.new(title: "Test item 4", swimlane_id: @initiative_lane[:id], user_id: 1, ordering: 4).save
    Item.new(title: "Test item 5", swimlane_id: @initiative_lane[:id], user_id: 1, ordering: 5).save
    Item.new(title: "Test item 6", swimlane_id: @initiative_lane[:id], user_id: 1, ordering: 6).save
    Item.new(title: "Test item 7", swimlane_id: @initiative_lane[:id], user_id: 1, ordering: 7).save
    Item.new(title: "Test item 8", swimlane_id: @initiative_lane[:id], user_id: 1, ordering: 8).save
    Item.new(title: "Test item 9", swimlane_id: @initiative_lane[:id], user_id: 1, ordering: 9).save
    Item.new(title: "Test item 10", swimlane_id: @initiative_lane[:id], user_id: 1, ordering: 10).save

    Item.new(title: "Test item 11", swimlane_id: @todo_lane[:id], user_id: 1, ordering: 1).save
    Item.new(title: "Test item 12", swimlane_id: @todo_lane[:id], user_id: 1, ordering: 2).save
    Item.new(title: "Test item 13", swimlane_id: @todo_lane[:id], user_id: 1, ordering: 3).save
    Item.new(title: "Test item 14", swimlane_id: @todo_lane[:id], user_id: 1, ordering: 4).save
    Item.new(title: "Test item 15", swimlane_id: @todo_lane[:id], user_id: 1, ordering: 5).save
end