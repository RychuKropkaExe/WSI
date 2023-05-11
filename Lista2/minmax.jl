

function checkIfWinning(board::Matrix{Int64}, player::Int64)

    for i in 1:5

        for j in 1:2

            if j == 1

                if board[i, 1] == board[i, 2] == board[i, 3] == board[i, 4] == player
                   
                    return true
                    
                end

            else

                if board[i, 2] == board[i, 3] == board[i, 4] == board[i, 5] == player
                   
                    return true
                    
                end

            end

        end

    end

    for i in 1:5

        for j in 1:2

            if j == 1

                if board[1, i] == board[2, i] == board[3, i] == board[4, i] == player
                   
                    return true
                    
                end

            else

                if board[2, i] == board[3, i] == board[4, i] == board[5, i] == player
                   
                    return true
                    
                end

            end

        end

    end

    if board[1,1] == board[2,2] == board[3,3] == board[4,4] == player
        return true
    end 

    if board[5,5] == board[2,2] == board[3,3] == board[4,4] == player
        return true
    end

    if board[1,2] == board[2,3] == board[3,4] == board[4,5] == player
        return true
    end 

    if board[2,1] == board[3,2] == board[4,3] == board[5,4] == player
        return true
    end 

    if board[1,5] == board[2,4] == board[3,3] == board[4,2] == player
        return true
    end

    if board[2,4] == board[3,3] == board[4,2] == board[5,1] == player
        return true
    end

    if board[2,5] == board[3,4] == board[4,3] == board[5,2] == player
        return true
    end

    if board[1,4] == board[2,3] == board[3,2] == board[4,1] == player
        return true
    end

    return false

end

function checkIfLosing(board::Matrix{Int64}, player::Int64)
    for i in 1:5

        for j in 1:3

            if j == 1

                if board[i, 1] == board[i, 2] == board[i, 3]  == player
                   
                    return true
                    
                end

            elseif j == 2

                if board[i, 2] == board[i, 3] == board[i, 4]  == player
                   
                    return true
                    
                end
            else 
                if board[i, 3] == board[i, 4] == board[i, 5]  == player
                   
                    return true
                    
                end
            end

        end

    end

    for i in 1:5

        for j in 1:3

            if j == 1

                if board[1, i] == board[2, i] == board[3, i] == player
                   
                    return true
                    
                end

            elseif j == 2

                if board[2, i] == board[3, i] == board[4, i] == player
                   
                    return true
                    
                end

            else 

                if board[3, i] == board[4, i] == board[5, i] == player
                   
                    return true
                    
                end

            end

        end

    end

    losingPositions::Array{Array{Tuple{Int64,Int64}}} = [
        [(1,1),(2,2),(3,3)],
        [(2,2),(3,3),(4,4)],
        [(3,3),(4,4),(5,5)],
        [(2,1),(3,2),(4,3)],
        [(3,2),(4,3),(5,4)],
        [(3,1),(4,2),(5,3)],
        [(1,2),(2,3),(3,4)],
        [(2,3),(3,4),(4,5)],
        [(1,3),(2,4),(3,5)],
        #-------------------
        [(5,1),(4,2),(3,3)],
        [(4,2),(3,3),(2,4)],
        [(3,3),(2,4),(1,5)],
        [(4,1),(3,2),(2,3)],
        [(3,2),(2,3),(1,4)],
        [(3,1),(2,2),(1,3)],
        [(5,2),(4,3),(3,4)],
        [(4,3),(3,4),(2,5)],
        [(5,3),(4,4),(3,5)]
    ]

    for arr in losingPositions
        p1 = arr[1]
        p2 = arr[2]
        p3 = arr[3]

        if board[p1[1], p1[2]] == board[p2[1], p2[2]] == board[p3[1], p3[2]] == player
            return true
        end

    end

    return false
end


function eval(board, player)
    #return 0
    evaluation::Int64 = 0
    onePointers = [(1,1), (1,5), (5,1), (5,5)]
    threePointers = [(2,1), (3,1), (4,1), (2,5), (3,5), (4,5)]
    for xy in onePointers

        if board[xy[1],xy[2]] == player
            evaluation += 1
        end

    end

    for xy in threePointers

        if board[xy[1],xy[2]] == player
            evaluation += 1
        end

    end

    for i in 2:4

        for j in 2:4

            if board[i,j] == player
                evaluation += 5
            end

        end

    end

    if board[3,3] == player 
        evaluation += 15
    end

    return evaluation

end

table::Dict{Int64,Int64} = Dict()

function minmax(board::Matrix{Int64}, depth::Int64, maximizingPlayer::Bool,
                playerID::Int64, enemyID::Int64, currHash::Int64, alpha::Int64, beta::Int64)

    if depth == 0

        if maximizingPlayer
            e = eval(board, playerID)
        else
            e = -eval(board, enemyID)
        end
        
        return (e, (0,0))

    end
    bestMove::Tuple{Int64,Int64} = (0,0)
    if maximizingPlayer
        maxEval::Int64 = typemin(Int64)
        bestMove = (0,0)
        for i in 1:5

            for j in 1:5

                if  board[i,j] == 0

                    key::Int64 = currHash + playerID*(3^(((i-1)*5) + j))

                    eval::Int64 = get(table, key, 0) 

                    if eval == 0
                        newBoard = deepcopy(board)
                        newBoard[i,j] = playerID
                        if checkIfWinning(newBoard, playerID)
                            eval = 10000
                            table[key] = eval
                        elseif checkIfLosing(newBoard, playerID)
                            eval = -10000
                            table[key] = eval
                        else
                            result = minmax(newBoard, depth - 1, false, playerID, enemyID, key, alpha, beta)
                            eval = result[1]
                            table[key] = eval
                        end
                    end
                    #println("EVAL: $playerID = $eval")
                    if maxEval < eval
                        maxEval = eval
                        bestMove = (i,j)
                    end
                    alpha = max(alpha, eval)
                    if beta <= alpha
                        break
                    end
                end

            end

        end
        return (maxEval, bestMove)
    else
        minEval::Int64 = typemax(Int64)
        bestMove = (0,0)
        for i in 1:5

            for j in 1:5

                if  board[i,j] == 0

                    key::Int64 = currHash + enemyID*(3^(((i-1)*5) + j))

                    eval::Int64 = 0

                    if !haskey(table, key)
                        newBoard = deepcopy(board)
                        newBoard[i,j] = enemyID
                        if checkIfWinning(newBoard, enemyID)
                            eval = -10000
                            table[key] = eval
                        elseif checkIfLosing(newBoard, enemyID)
                            eval = 10000
                            table[key] = eval
                        else
                            result = minmax(newBoard, depth - 1, true, playerID, enemyID, key, alpha, beta)
                            eval = result[1]
                            table[key] = eval
                        end
                    else

                        eval = table[key]

                    end
                    #println("EVAL: $enemyID = $eval")
                    if minEval > eval
                        minEval = eval
                        bestMove = (i,j)
                    end
                    beta = min(beta, eval)
                    if beta <= alpha
                        break
                    end
                end

            end

        end
        return (minEval, bestMove)
    end

end