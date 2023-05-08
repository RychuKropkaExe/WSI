using Sockets
include("minmax.jl")


function main(ARGS)
    if(length(ARGS) < 3)
        println("ERROR: WRONG NUMBER OF ARGUMENTS PROVIEDED")
        exit(0)
    end
    ip::IPv4 = IPv4(ARGS[1])
    port = parse(Int64,ARGS[2])
    playerID::String = ARGS[3]
    connection = connect(ip, port)
    msg::String = String(readavailable(connection))
    code = parse(Int64, msg)
    println("MSG: ", code)
    if(code != 700)
        println("SERVER SIDE ERROR")
        exit(0)
    end

    write(connection, playerID)

    board::Matrix{Int64} = zeros(5,5)
    table::Dict{Int64,Int64} = Dict()

    while isopen(connection)
        msg = String(readavailable(connection))
        if !isempty(msg)
            println("SERVER MSG: ", msg)
            if(parse(Int64, msg) > 55 && parse(Int64, msg) != 600)
                println("GAME FINISHED! RESULT: ", msg)
                exit(0)
            end

            myMove::String = minmax(board, table, parse(Int64, msg))

            write(connection, myMove)
        end
    end
end



main(ARGS)