require 'sqlite3'

db = SQLite3::Database.new "./aldentea2023.db"

sessions0 = db.execute("SELECT session_id, result, length, place from session where player_id0 = 2 and length > 0")
sessions1 = db.execute("SELECT session_id, result, length, place from session where player_id1 = 2 and length > 0")

games0 = db.execute("SELECT session_id, game_number, game_id, score_0, score_1, crawford, result from game where player_id0 = 2")
games1 = db.execute("SELECT session_id, game_number, game_id, score_0, score_1, crawford, result from game where player_id1 = 2")
gamestats = db.execute("SELECT game_id, chequer_error_total_normalised, unforced_moves, chequer_error_per_move_normalised, cube_error_total_normalised, close_cube_decisions, cube_error_per_move_normalised, overall_error_total_normalised, overall_error_per_move_normalised from gamestat where player_id = 2").to_h { |row| [row[0], row] }

m_error = 0.0
m_decision = 0
c_error = 0.0
c_decision = 0

sessions0.each do |match|
    #puts "*** Match #{match[0]}"
    length = match[2]
    games0.select{ |g| g[0] == match[0]}.each do |game|
        if (length - game[3] == 4) && (length - game[4] == 4)
            puts "*** Match #{match[0]}"
            puts "#{['','*'][game[5]]}#{game[1]}, #{game[2]}, #{length - game[3]}, #{length - game[4]}, #{game[6]}"
            st = gamestats[game[2]]
            #p st
            puts "#{sprintf('%8.5f', st[1])} / #{st[2]} = #{sprintf('%8.2f', st[3] * 1000)} | #{sprintf('%8.5f', st[4])} / #{st[5]} = #{sprintf('%8.2f', st[6] * 1000)} | #{sprintf('%8.5f', st[7])}, #{sprintf('%8.2f', st[8] * 1000)}"
            m_error += st[1]
            m_decision += st[2]
            c_error += st[4]
            c_decision += st[5]
        end
    end
end

puts "#{sprintf('%10.5f', m_error)} / #{m_decision} = #{sprintf('%8.2f', m_error / m_decision * 1000)} | #{sprintf('%10.5f', c_error)} / #{c_decision} = #{sprintf('%8.2f', c_error / c_decision * 1000)} | #{sprintf('%10.5f', m_error + c_error)} / #{m_decision + c_decision} = #{sprintf('%8.2f', (m_error + c_error) / (m_decision + c_decision) * 1000)}"


#sessions0.each do |match|
