"""StructTables: a module for making tables of results for processing
using line based editors like awk, sed, and csvutils.
This package was motivated by the need to write a lot of boilerplate code
in order to produce tables that look like

size	error	resid
   20	1e-3	1.2e-4
   25	1e-4	2.2e-4
   30	1e-5	3.2e-4
   40	1e-6	4.2e-4
   50	1e-7	5.2e-4

These tables summarize the results of an experiment and are easy to process
in a shell script pipeline using line based tools.

In order to use this module you define a type or immutable type
such as the following.
type T
    size::Int
    error::Float64
    resid::Float64
end

Then run your experiment in the following format:
Where:
    - xs is a sequence of parameters/conditions/datasets
    - f(x) is a function that runs the simulation

results = T[]
for x in xs
    y = f(x)
    push!(results, T(y))
end
sttable(results)

Calling sttable(STDOUT, results) will print out the results to STDOUT
which you can redirect into a file or subsequent pipline element.
"""
module StructTables

export sttable, structwrite, fieldswrite

"""fieldswrite(io, t::T) print out the fieldnames of T as a header row"""
function fieldswrite(io, t)
    fs = fieldnames(t)
    for f in fs[1:end-1]
        print(io, "$f\t")
    end
    print(io, "$(fs[end])")
end

# this version of the code is simple but inefficient because the introspection and
# code gen is done on every call as you can see from the calls to fieldnames and eval.
# it is left as a reference implementation for the reader.
#
# function structwrite_dyn(io, t) 
#     T = typeof(t) 
#     fs = fieldnames(T) 
#     for f in fs 
#         print(io, eval(:($t.$f))); print(io, "\t") 
#     end 
# end 

"""structwrite(io, t::T) print out the fields of T as a table row
This uses `@generated` to do the introspection only once per type.
"""
@generated function structwrite(io, t)
    # julia does not guarantee that @generated functions are only @generated once.
    fs = fieldnames(t)
    format = ""
    d = :(t.$(fs[1]))
    q = :(println(io, $d, "\t"))
    for f in fs[2:end-1]
        d = :(t.$f)
        push!(q.args, d)
        push!(q.args, "\t")
    end
    d = :(t.$(fs[end]))
    push!(q.args, d)
    print("Printing $t as: ")
    println(q)
    return q
end

"""sttable(io, ts) write out all the rows of ts with a header"""
function sttable{T}(io, ts::AbstractArray{T})
    fieldswrite(io, ts[1]); println(io, "")
    for t in ts
        structwrite(io, t);
    end
end

end
