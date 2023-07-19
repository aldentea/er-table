require 'sqlite3'

class Database
    def initialize(filename)
        @db = SQLite3::Database.new(filename)
        @players = @db.execute("SELECT player_id, name from player").to_h

        @sessions = @db.execute("SELECT session_id, player_id0, player_id1, result, length, place from session where length > 0")

        @games = @db.execute("SELECT session_id, game_number, game_id, score_0, score_1, result from game")
        @winners = @db.execute("SELECT game_id, player_id from gamestat where actual_result > 0").to_h
        @winner1 = @db.execute("SELECT game_id from gamestat where actual_result < 0").flatten
    end

    def scorecard(destination)
        @sessions.each do |session|
            player0 = @players[session[1]]
            player1 = @players[session[2]]
            games = @games.select{ |g| g[0] == session[0]}
            # games[0]のスコアは0-0なので出す必要はない。
            score_transition = games[1..-1].map do |game|   
                [game[3], game[4]]
            end

            last_game = games.last
            # 最終結果【旧仕様】
            #if last_game
            #    if @winners[last_game[2]] == session[1]
            #        score_transition.push([last_game[3] + last_game[5], last_game[4]])
            #    elsif @winners[last_game[2]] == session[2]
            #        score_transition.push([last_game[3], last_game[4] + last_game[5]])
            #    end
            #end

            # 最終結果【新仕様】
            if last_game
                if last_game[5] > 0
                    score_transition.push([last_game[3] + last_game[5], last_game[4]])
                elsif last_game[5] < 0
                    score_transition.push([last_game[3], last_game[4] - last_game[5]])
                end
            end

            destination.puts(player0)
            destination.puts(player1)
            destination.puts(" #{session[4]} point match")
            score_transition.each do |st|
                destination.puts(st.join(' '))
            end
            destination.puts    # 末尾に空行

        end
    end

end

db = Database.new("./aldentea2023.db")

File.open("./score-transition_aldentea2023.txt", 'w') { |file|
    db.scorecard(file)
}
