using Plots
pyplot()

using DataFrames
using CSV
using Statistics
using StatsBase
using Distributions


function myrand(d)
    x = floor(Int,rand(d))
    (x>0) ? x : myrand(d)
end


Nc=700
# simp = [myrand(Pareto(1.8,3.1)) for _ in 1:Nc] # shingrix
# simp = [myrand(Pareto(1.5,2.0)) for _ in 1:Nc] # varivax
# simp = [myrand(Pareto(1.1,2.0)) for _ in 1:Nc] # hpv
simp = [myrand(Pareto(0.8,1.3)) for _ in 1:Nc] # hpv
# simp = [myrand(Pareto(1.3,0.4)) for _ in 1:Nc] # pfizer
# simp = [myrand(Pareto(1.3,0.4)) for _ in 1:Nc] # moderna

plot(sort(simp))



# plot(pdf.(Pareto(0.8,1.3), 0:0.01:5))
# xx = 0:0.01:5
xx = 1:0.01:5
plot(xx, pdf(Pareto(0.8,1.0), xx))


x = (1:50000) ./ 500
plot(x, exp.(-x), yaxis=:log, ylim=(0.1,1))
plot!(x, x.^-2, yaxis=:log, ylim=(0.1,1))


plot(x, exp.(-x), xaxis=:log, yaxis=:log, ylim=(0.1,1))
plot!(x, x.^-2, xaxis=:log, yaxis=:log, ylim=(0.1,1))
