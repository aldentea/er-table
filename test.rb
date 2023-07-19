require_relative 'my-database'

data = MyDatabase.new('./aldentea2022.db', 'aldentea', false)

File.open('er-table_test.csv', 'w') { |file| 


    0.upto(7) do |my_away|
        0.upto(7) do |your_away|
            er_data = data.er_data(my_away, your_away)
            m_er = er_data[:m_error] / er_data[:m_decisions] * 1000
            c_er = er_data[:c_error] / er_data[:c_decisions] * 1000
            overall_error = er_data[:m_error] + er_data[:c_error]
            overall_decisions = er_data[:m_decisions] + er_data[:c_decisions]
            overall_er = overall_error / overall_decisions * 1000
            #puts "#{my_away}-#{your_away}    #{sprintf('%10.5f', er_data[:m_error])} / #{er_data[:m_decisions]} = #{sprintf('%8.2f', m_er)} | #{sprintf('%10.5f', er_data[:c_error])} / #{er_data[:c_decisions]} = #{sprintf('%8.2f', c_er)} | #{sprintf('%10.5f', overall_error)} / #{overall_decisions} = #{sprintf('%8.2f', overall_er)}"
            file.puts "#{my_away}, #{your_away}, #{sprintf('%10.5f', er_data[:m_error])}, #{er_data[:m_decisions]}, #{sprintf('%8.2f', m_er)}, #{sprintf('%10.5f', er_data[:c_error])}, #{er_data[:c_decisions]}, #{sprintf('%8.2f', c_er)}, #{sprintf('%10.5f', overall_error)}, #{overall_decisions}, #{sprintf('%8.2f', overall_er)}, #{sprintf('%10.5f', er_data[:m_double_below_cp])}, #{sprintf('%10.5f', er_data[:m_double_above_cp])}, #{sprintf('%10.5f', er_data[:w_double_below_dp])}, #{sprintf('%10.5f', er_data[:w_double_above_tg])}, #{sprintf('%10.5f', er_data[:deep_take])}, #{sprintf('%10.5f', er_data[:early_pass])}"
        end
    end
}