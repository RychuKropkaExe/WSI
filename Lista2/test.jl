include("minmax.jl")

function main()

    v = [
        [0,0,0,0,0],
        [0,0,0,0,0],
        [0,0,0,0,0],
        [0,0,0,0,0],
        [0,0,0,0,0]
        ]

    v = hcat(v...)

    println(checkIfLosing(v))
end

main()