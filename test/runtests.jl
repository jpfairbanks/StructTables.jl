using StructTables
using Base.Test

type Point{T}
    n::Int
    a::T
    b::T
end

# check that we can write to a file
iob = IOBuffer()
tab = [Point(i, i^2, i^3) for i in 1:10]
sttable(iob, tab)
fp = open("table.tsv", "w")
write(fp, takebuf_string(iob))
close(fp)

# use diff to check that the files match
# run(`diff table.tsv table.test.tsv`)
@test readlines("table.tsv") == readlines("table.test.tsv")

type Point4{T}
    n::Int
    a::T
    b::T
    c::T
end

structwrite(STDOUT, Point4(1,2,3,4))
tab = [Point4(i, i^2, i^3, 2i) for i in 1:10]
sttable(STDOUT, tab)
sttable(STDOUT, tab)
