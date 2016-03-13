# StructTables
A module for making tables of results for processing
with line based editors like awk, sed, and csvutils.

This package was motivated by the need to write a lot of boilerplate code
in order to produce tables that look like

```
size	error	resid
   20	1e-3	1.2e-4
   25	1e-4	2.2e-4
   30	1e-5	3.2e-4
   40	1e-6	4.2e-4
   50	1e-7	5.2e-4
```

These tables summarize the results of an experiment and are easy to process
in a shell script pipeline using line based tools.

In order to use this module you define a type or immutable type
such as the following.

```julia
type T
    size::Int
    error::Float64
    resid::Float64
end
```

Then run your experiment in the following format where:

    - xs is a sequence of parameters/conditions/datasets
    - f(x) is a function that runs the simulation

```julia
results = T[]
for x in xs
    y = f(x)
    push!(results, T(y))
end
sttable(results)
```

Calling `sttable(STDOUT, results)` will print out the results to `STDOUT`
which you can redirect into a file or subsequent pipline element.

