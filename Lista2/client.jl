using Sockets
include("minmax.jl")


function main(ARGS)

    if(length(ARGS) < 4)
        println("ERROR: WRONG NUMBER OF ARGUMENTS PROVIEDED")
        exit(0)
    end
    ip::IPv4 = IPv4(ARGS[1])
    port = parse(Int64,ARGS[2])
    playerID::String = ARGS[3]
    depth::Int64 = parse(Int64, ARGS[4])
    if depth > 10
        println("MAXIMUM DEPTH LIMIT EXCEEDED")
        exit(0)
    end
    enemyID::Int64 = 0

    if parse(Int64, playerID) == 1

        enemyID = 2     

    else

        enemyID = 1

    end

    connection = connect(ip, port)
    msg::String = String(readavailable(connection))
    code = parse(Int64, msg)
    println("MSG: ", code)

    if(code != 700)
        println("SERVER SIDE ERROR")
        exit(0)
    end

    write(connection, playerID)

    myID::Int64 = parse(Int64, ARGS[3])
    board::Matrix{Int64} = zeros(5,5)
    table::Dict{Int64,Int64} = Dict()
    currHash::Int64 = 0

    while isopen(connection)
        msg = String(readavailable(connection))
        if !isempty(msg)
            println("SERVER MSG: ", msg)
            if(parse(Int64, msg) > 55 && parse(Int64, msg) != 600)
                println("GAME FINISHED! RESULT: ", msg)
                exit(0)
            end
            if parse(Int64, msg) == 600
                # currHash = myID*(3^(13))
                currHash = 0
                # board[3, 3] = myID
                # println("MY MOVE: 33")
                # write(connection, string(3)*string(3))
                myMove = minmax(board, table, depth, true, myID, enemyID, currHash)

                board[myMove[2][1], myMove[2][2]] = myID
                currHash += myID*(3^(((myMove[2][1]-1)*5)+myMove[2][2]))
                
                println("MY MOVE: ", string(myMove[2][1])*string(myMove[2][2]))
                println("MY EVALUATION: ", myMove[1])
                write(connection, string(myMove[2][1])*string(myMove[2][2]))
            else
                enemyMoveRow::Int64 = parse(Int64, msg[1])
                enemyMoveColumn::Int64 = parse(Int64, msg[2])

                board[enemyMoveRow, enemyMoveColumn] = enemyID
                #println(board)
                currHash += enemyID*(3^(((enemyMoveRow-1)*5)+enemyMoveColumn))

                myMove = minmax(board, table, depth, true, myID, enemyID, currHash)

                board[myMove[2][1], myMove[2][2]] = myID
                currHash += myID*(3^(((myMove[2][1]-1)*5)+myMove[2][2]))

                println("MY MOVE: ", string(myMove[2][1])*string(myMove[2][2]))
                println("MY EVALUATION: ", myMove[1])
                write(connection, string(myMove[2][1])*string(myMove[2][2]))
            end
        end
    end

end



main(ARGS)