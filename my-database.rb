require 'sqlite3'


class MyDatabase
    def initialize(filename, username, opponent = false)
        @db = SQLite3::Database.new(filename)
        user = @db.execute("SELECT player_id from player where name = '#{username}'")
        if user.empty?
            raise "I don't know the user whose name is #{username}."
        end
        my_id = user.first.first

        if opponent
            # 自分がplayer1
            @sessions0 = @db.execute("SELECT session_id, result, length, place from session where player_id1 = #{my_id} and length > 0")
            # 自分がplayer0
            @sessions1 = @db.execute("SELECT session_id, result, length, place from session where player_id0 = #{my_id} and length > 0")

            # 自分がplayer1のgame
            @games0 = @db.execute("SELECT session_id, game_number, game_id, score_0, score_1, crawford, result from game where player_id1 = #{my_id}")
            # 自分がplayer0のgame
            @games1 = @db.execute("SELECT session_id, game_number, game_id, score_1, score_0, crawford, result from game where player_id0 = #{my_id}")
            @gamestats = @db.execute("SELECT game_id, chequer_error_total_normalised, unforced_moves, chequer_error_per_move_normalised, cube_error_total_normalised, close_cube_decisions, cube_error_per_move_normalised, overall_error_total_normalised, overall_error_per_move_normalised, error_missed_doubles_below_cp_normalised, error_missed_doubles_above_cp_normalised, error_wrong_doubles_below_dp_normalised, error_wrong_doubles_above_tg_normalised, error_wrong_takes_normalised, error_wrong_passes_normalised from gamestat where player_id != #{my_id}").to_h { |row| [row[0], row] }

        else
            # 自分がplayer0
            @sessions0 = @db.execute("SELECT session_id, result, length, place from session where player_id0 = #{my_id} and length > 0")
            # 自分がplayer1
            @sessions1 = @db.execute("SELECT session_id, result, length, place from session where player_id1 = #{my_id} and length > 0")

            # 自分がplayer0のgame
            @games0 = @db.execute("SELECT session_id, game_number, game_id, score_0, score_1, crawford, result from game where player_id0 = #{my_id}")
            # 自分がplayer1のgame
            @games1 = @db.execute("SELECT session_id, game_number, game_id, score_1, score_0, crawford, result from game where player_id1 = #{my_id}")
            @gamestats = @db.execute("SELECT game_id, chequer_error_total_normalised, unforced_moves, chequer_error_per_move_normalised, cube_error_total_normalised, close_cube_decisions, cube_error_per_move_normalised, overall_error_total_normalised, overall_error_per_move_normalised, error_missed_doubles_below_cp_normalised, error_missed_doubles_above_cp_normalised, error_wrong_doubles_below_dp_normalised, error_wrong_doubles_above_tg_normalised, error_wrong_takes_normalised, error_wrong_passes_normalised from gamestat where player_id = #{my_id}").to_h { |row| [row[0], row] }
        end
    end

    def er_data(my_away, your_away)
        m_error = 0.0
        m_decision = 0
        c_error = 0.0
        c_decision = 0

        m_double_below_cp = 0.0
        m_double_above_cp = 0.0
        w_double_below_dp = 0.0
        w_double_above_tg = 0.0
        deep_take = 0.0
        early_pass = 0.0

        @sessions0.each do |match|
            #puts "*** Match #{match[0]}"
            length = match[2]
            @games0.select{ |g| g[0] == match[0]}.each do |game|
                my_flag = (my_away == 0) && (game[5] == 0) && (length - game[3] == 1)
                my_flag |= (my_away == 1) && (game[5] == 1) && (length - game[3] == 1)
                my_flag |= (my_away > 1) && (length - game[3] == my_away)
                your_flag = (your_away == 0) && (game[5] == 0) && (length - game[4] == 1)
                your_flag |= (your_away == 1) && (game[5] == 1) && (length - game[4] == 1)
                your_flag |= (your_away > 1) && (length - game[4] == your_away)
                if my_flag && your_flag
                    #puts "*** Match #{match[0]}"
                    #puts "#{['','*'][game[5]]}#{game[1]}, #{game[2]}, #{length - game[3]}, #{length - game[4]}, #{game[6]}"
                    st = @gamestats[game[2]]
                    #p st
                    #puts "#{sprintf('%8.5f', st[1])} / #{st[2]} = #{sprintf('%8.2f', st[3] * 1000)} | #{sprintf('%8.5f', st[4])} / #{st[5]} = #{sprintf('%8.2f', st[6] * 1000)} | #{sprintf('%8.5f', st[7])}, #{sprintf('%8.2f', st[8] * 1000)}"
                    m_error += st[1]
                    m_decision += st[2]
                    c_error += st[4]
                    c_decision += st[5]
                    m_double_below_cp += st[9]
                    m_double_above_cp += st[10]
                    w_double_below_dp += st[11]
                    w_double_above_tg += st[12]
                    deep_take += st[13]
                    early_pass += st[14]
                end
            end
        end

        @sessions1.each do |match|
            #puts "*** Match #{match[0]}"
            length = match[2]
            @games1.select{ |g| g[0] == match[0]}.each do |game|
                my_flag = (my_away == 0) && (game[5] == 0) && (length - game[3] == 1)
                my_flag |= (my_away == 1) && (game[5] == 1) && (length - game[3] == 1)
                my_flag |= (my_away > 1) && (length - game[3] == my_away)
                your_flag = (your_away == 0) && (game[5] == 0) && (length - game[4] == 1)
                your_flag |= (your_away == 1) && (game[5] == 1) && (length - game[4] == 1)
                your_flag |= (your_away > 1) && (length - game[4] == your_away)
                if my_flag && your_flag
                    #puts "*** Match #{match[0]}"
                    #puts "#{['','*'][game[5]]}#{game[1]}, #{game[2]}, #{length - game[3]}, #{length - game[4]}, #{game[6]}"
                    st = @gamestats[game[2]]
                    #p st
                    #puts "#{sprintf('%8.5f', st[1])} / #{st[2]} = #{sprintf('%8.2f', st[3] * 1000)} | #{sprintf('%8.5f', st[4])} / #{st[5]} = #{sprintf('%8.2f', st[6] * 1000)} | #{sprintf('%8.5f', st[7])}, #{sprintf('%8.2f', st[8] * 1000)}"
                    m_error += st[1]
                    m_decision += st[2]
                    c_error += st[4]
                    c_decision += st[5]
                    m_double_below_cp += st[9]
                    m_double_above_cp += st[10]
                    w_double_below_dp += st[11]
                    w_double_above_tg += st[12]
                    deep_take += st[13]
                    early_pass += st[14]
                end
            end
        end

        #puts "#{my_away}-#{your_away}    #{sprintf('%10.5f', m_error)} / #{m_decision} = #{sprintf('%8.2f', m_error / m_decision * 1000)} | #{sprintf('%10.5f', c_error)} / #{c_decision} = #{sprintf('%8.2f', c_error / c_decision * 1000)} | #{sprintf('%10.5f', m_error + c_error)} / #{m_decision + c_decision} = #{sprintf('%8.2f', (m_error + c_error) / (m_decision + c_decision) * 1000)}"
        {
            :my_away => my_away,
            :your_away => your_away,
            :m_error => m_error,
            :m_decisions => m_decision,
            :c_error => c_error,
            :c_decisions => c_decision,
            :m_double_below_cp => m_double_below_cp,
            :m_double_above_cp => m_double_above_cp,
            :w_double_below_dp => w_double_below_dp,
            :w_double_above_tg => w_double_above_tg,
            :deep_take => deep_take,
            :early_pass => early_pass
        }
    end
end
