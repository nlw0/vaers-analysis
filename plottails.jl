using Plots
pyplot()

using DataFrames
using CSV
using Statistics
using StatsBase
using Distributions


dd = CSV.read("DATA/2021VAERSVAX.csv", DataFrame)
vaxnames = ["COVID19 (COVID19 (PFIZER-BIONTECH))", "COVID19 (COVID19 (MODERNA))", "COVID19 (COVID19 (JANSSEN))", "HPV (GARDASIL 9)", "ZOSTER (SHINGRIX)", "VARICELLA (VARIVAX)"]

function distbyname(name)
    sel = [x.VAX_NAME == name && !ismissing(x.VAX_LOT) && (strip(uppercase(filter(isascii, x.VAX_LOT))) ∉ ["UNKNOWN", "UNK"]) && !occursin("58160", filter(isascii, x.VAX_LOT)) for x in eachrow(dd)]
    # sel = [x.VAX_NAME == name && !ismissing(x.VAX_LOT) && occursin("5816008", x.VAX_LOT) for x in eachrow(dd)]
    coof = dd[sel,:]
    lots = map(coof.VAX_LOT) do st
        st = join(uppercase(x) for x in st if isascii(x) && x in ['a':'z';'A':'Z';'0':'9'])
        (length(st)>6 && st[1:6] == "PFIZER") ? st[7:end] : (length(st)>3 && st[1:3] == "LOT") ? st[4:end] : st
    end
    cc = hcat(sort([[a[1],a[2]] for a in countmap(lots)])...)
    # cc[1,sortperm(cc[2,:])]
    cc = cc[2,:]
end
allcc = distbyname.(vaxnames)


axisargs = Dict(:loglog => (:xaxis=>:log, :yaxis=>:log),
                :semilogy => (:xaxis=>nothing, :yaxis=>:log),
                :normal => (:xaxis=>nothing, :yaxis=>nothing)
                )
                
plotstyle = :normal

pp = map(zip(vaxnames,allcc)) do (vn,cc)
    ct = sort(cc)
    NN = length(cc)

    # @show myexp = fit_mle(Exponential{Float64}, Float64.(cc))
    # @show myexp = fit_mle(Exponential{Float64}, Float64.(ct[end*985÷1000:end]))
    
    @show myexp = fit_mle(Exponential{Float64}, Float64.(if length(cc) > 1000 ct[end*970÷1000:end] else ct end ))
    # @show mypareto = fit_mle(Pareto{Float64}, Float64.(cc[1:end÷2]))
    # @show mypareto = fit_mle(Pareto{Float64}, Float64.(if length(cc) > 1000 ct[1:end*970÷1000] else ct end ))
    @show mypareto = fit_mle(Pareto{Float64}, Float64.(if length(cc) > 1000 ct[1:end*900÷1000] else ct end ))
    x = 1:0.1:maximum(cc)

    # simp = sort(rand(myexp, NN))
    # plot!(simp, (NN+1 .- (1:NN))/NN, xaxis=:log, yaxis=:log, m=3, label="Exponential sim.")

    plot(ct, (NN+1 .- (1:NN))/NN, yaxis=:log, m=3, label=vn, legend=:bottomleft, msw=0, ylim=(1/(NN*1.1), 1.0))
    plot!(x, max.(1e-10, 1 .- cdf.(myexp, x)), l=3, label="Exponential fit"; axisargs[plotstyle]...)
    plot!(x, max.(1e-10, 1 .- cdf.(mypareto, x)), l=3, label="Pareto fit"; axisargs[plotstyle]...)

end
plot(pp...)
