using DataStructures
using Random
mutable struct Game
    n::Int64
    tiles::Array{Array{Int64}}
    heuristic::Function
    blankPosition::Tuple{Int64, Int64}
    moves::Array{Tuple{Int64, Int64}}
    bannedMove::Tuple{Int64,Int64}
    steps::Int64
    value::Int64
end

function Base.isless(x::Game, y::Game)
    return x.value < y.value
end

function isSolvable(game::Game)

    len = game.n * game.n
    fold::Array{Int64} = []
    inversionCount::Int64 = 0
    blankIndex::Int64 = 0

    for i in 1:game.n
        append!(fold, game.tiles[i])
    end

    for i in 1:game.n
        for j in 1:game.n
            if game.tiles[i][j] == 0
                blankIndex = i
            end
        end
    end

    for i in 1:len
        for j in (i+1):len
            if fold[i] > fold[j] && fold[j] != 0 && fold[i] != 0
                inversionCount+=1
            end
        end
    end

    if game.n % 2 == 1 && inversionCount % 2 == 0
        return true
    end
    println(inversionCount)
    if game.n % 2 == 0 && blankIndex % 2 == 0 && inversionCount % 2 == 0
        return true
    elseif game.n % 2 == 0 && blankIndex % 2 == 1 && inversionCount % 2 == 1
        return true
    end
    return false

end


function Hamming(game::Game)

    distance::Int64 = 0

    for i in 1:game.n

        for j in 1:game.n
            
            if game.tiles[i][j] != ((i-1)*game.n)+j

                distance += 1

            end

        end

    end

    return distance - 1

end

function Manhattan(game::Game)

    distance::Int64 = 0

    for i in 1:game.n

        for j in 1:game.n
            
            if game.tiles[i][j] != ((i-1)*game.n)+j && game.tiles[i][j] != 0

                row::Int64 = abs(ceil(Int64, game.tiles[i][j]/game.n) - i)
                mod = game.tiles[i][j] % game.n
                column::Int64 = abs((mod == 0 ? 4 : mod) - j)
                distance += row + column

            end

        end

    end

    return distance

end


function printPuzzle(game::Game)

    for i in 1:game.n
        println(game.tiles[i])
    end

end


function puzzleSolver(game::Game)
    
    if !isSolvable(game)
        println("Impossible to sovle!")
        return game
    end

    n::Int64 = game.n

    heap::BinaryMinHeap{Game} = BinaryMinHeap{Game}()
    push!(heap, game)

    a::Game = game

    while(!isempty(heap))
        #println(heap)
        curState::Game = pop!(heap)
        a = curState
        hValue::Int64 = curState.heuristic(curState) + curState.steps

        if curState.steps == hValue
            return curState
        end

        bannedMove = curState.bannedMove

        newStateTiles::Array{Array{Int64}} = []

        i = curState.blankPosition[1]
        j = curState.blankPosition[2]

        if j - 1 != 0 && (i,j - 1) != bannedMove
            #println("HERE1 $bannedMove")
            newStateTiles = deepcopy(curState.tiles)

            newStateTiles[i][j-1],newStateTiles[i][j] = newStateTiles[i][j],newStateTiles[i][j-1]
            newMoves = deepcopy(curState.moves)
            push!(newMoves, (i, j-1))

            newState = Game(n,newStateTiles,game.heuristic,(i,j-1), newMoves,(i,j),curState.steps+1,0)
            newState.value = newState.heuristic(newState) + (curState.steps + 1)

            push!(heap,newState)

        end

        if j + 1 != (n+1) && (i,j + 1) != bannedMove
            #println("HERE2 $bannedMove")
            newStateTiles = deepcopy(curState.tiles)

            newStateTiles[i][j+1],newStateTiles[i][j] = newStateTiles[i][j],newStateTiles[i][j+1]
            newMoves = deepcopy(curState.moves)
            push!(newMoves, (i,j+1))

            newState = Game(n,newStateTiles,game.heuristic,(i,j+1), newMoves,(i,j),curState.steps+1,0)
            newState.value = newState.heuristic(newState) + (curState.steps + 1)

            push!(heap,newState)

        end


        if i - 1 != 0 && (i - 1, j) != bannedMove
            #println("HERE3 $bannedMove")
            newStateTiles = deepcopy(curState.tiles)

            newStateTiles[i - 1][j],newStateTiles[i][j] = newStateTiles[i][j],newStateTiles[i - 1][j]
            newMoves = deepcopy(curState.moves)
            push!(newMoves, (i-1,j))

            newState = Game(n,newStateTiles,game.heuristic,(i-1,j), newMoves,(i,j),curState.steps+1,0)
            newState.value = newState.heuristic(newState) + (curState.steps + 1)

            push!(heap,newState)

        end

        if i + 1 != (n+1) && (i + 1,j) != bannedMove
            #println("HERE4 $bannedMove")
            newStateTiles = deepcopy(curState.tiles)
            newStateTiles[i + 1][j],newStateTiles[i][j] = newStateTiles[i][j],newStateTiles[i + 1][j]
            newMoves = deepcopy(curState.moves)
            push!(newMoves, (i+1,j))

            newState = Game(n,newStateTiles,game.heuristic,(i+1,j), newMoves,(i,j),curState.steps+1,0)
            newState.value = newState.heuristic(newState) + (curState.steps + 1)

            push!(heap,newState)

        end
    end

end

function generateRandomPuzzle(n::Int64)
    k = (n*n) - 1 
    puzzle = collect(0:k)
    shuffle!(puzzle)

    for i in 1:(k+1)
        if puzzle[i] == 0
            puzzle[i], puzzle[k+1] = puzzle[k+1], puzzle[i]
        end
    end

    result = []

    for i in 1:n
        temp = []

        for j in (((i-1)*n)+1):(((i-1)*n)+n)
            push!(temp, puzzle[j])
        end

        push!(result, temp)

    end

    return result

end


function printSteps(game::Game)
    printPuzzle(game)
    count = 1
     for (i,j) in game.moves
        println("STEP: $count")
        count+=1
        bIndex1 = game.blankPosition[1]
        bIndex2 = game.blankPosition[2]
        game.tiles[bIndex1][bIndex2], game.tiles[i][j] = game.tiles[i][j], game.tiles[bIndex1][bIndex2]
        game.blankPosition = (i,j)

        printPuzzle(game)

     end
    
end

function main()
    n = 4
    blankPosition = (4,4)
    #puzzle = generateRandomPuzzle(n)
    puzzle = [[5,1,2,3],[9,7,4,11],[13,6,10,8],[14,15,12,0]]
    puzzleCopy = deepcopy(puzzle)
    #puzzle = [[1,2,3],[4,5,0],[7,8,6]]
    #puzzle2 = [[1,2,3,4], [5,6,7,8], [9,10, 0, 11], [13, 14, 15, 12]]
    # game = Game(3, puzzle, (1,1), [], (x->0), 0, 0)
    # game2 = Game(3, puzzle, (1,1), [], (x->0), 0, 10)
    #game = Game(4,puzzle2,Hamming, (3,3),[],0,0,0)
    game = Game(n,puzzle,Manhattan, blankPosition,[],(0,0),0,0)
    # printPuzzle(game)
    # println(game > game2)
    # println(isSolvable(game))
    # println(Hamming(game))
    # println(Manhattan(game))
    printPuzzle(game)
    #puzzleSolver(game)
    result = puzzleSolver(game)
    # println(result.moves)
    printPuzzle(result)
    result.tiles = puzzleCopy
    result.blankPosition = blankPosition
    println(result.moves)
    printSteps(result)

end

main()

#[5,1,2,3]
#[9,7,4,11]
#[13,6,10,8]
#[14,15,12,0]