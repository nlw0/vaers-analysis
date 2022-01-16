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
    cc = Float64.(cc[2,:])
end
allcc = distbyname.(vaxnames)


axisargs = Dict(:loglog => (:xaxis=>:log, :yaxis=>:log),
                :semilogy => (:xaxis=>nothing, :yaxis=>:log),
                :normal => (:xaxis=>nothing, :yaxis=>nothing)
                )
                
plotstyle = :loglog
# plotstyle = :semilogy
# plotstyle = :normal

function plotfit(vn, cc, myexp, mypareto, ρ)
    ct = sort(cc)
    NN = length(cc)

    x = 1:0.1:ct[end]

    # simp = sort(rand(myexp, NN))
    # plot!(simp, (NN+1 .- (1:NN))/NN, xaxis=:log, yaxis=:log, m=3, label="Exponential sim.")

    plot(ct, (NN+1 .- (1:NN))/NN, yaxis=:log, m=3, label=vn, legend=:bottomleft, msw=0, ylim=(1/(NN*1.1), 1.0))
    plot!(x, max.(1e-15, 1 .- cdf.(myexp, x)), l=3, label="Exponential model"; axisargs[plotstyle]...)
    plot!(x, max.(1e-15, 1 .- cdf.(mypareto, x)), l=3, label="Pareto model"; axisargs[plotstyle]...)
    plot!(x, max.(1e-15, 1 .- (ρ[1]*cdf.(mypareto, x) .+ ρ[2]*cdf.(myexp, x))), l=3, label="Mixture model"; axisargs[plotstyle]...)
end

allρ = [
    [0.985, 0.015],
    [0.985, 0.015],
    [0.985, 0.015],
    [0.02, 0.98],
    [0.02, 0.98],
    [0.02, 0.98]
]

pp = map(zip(vaxnames,allcc,allρ)) do (vn,cc,ρ)
    ct = sort(cc)
    myexp = fit_mle(Exponential{Float64}, Float64.(if length(cc) > 1000 ct[end*970÷1000:end] else ct[end*500÷1000:end] end ))
    mypareto = fit_mle(Pareto{Float64}, Float64.(if length(cc) > 1000 ct[1:end*970÷1000] else ct[end÷4:end*500÷1000] end ))
    plotfit(vn, cc, myexp, mypareto, ρ)
end
plot(pp..., size=(1920,1080))



function EMstep(mypareto, myexp, mm, data)
    qq = [pdf.(mypareto, data) pdf.(myexp, data)] .* mm'
    ww = qq ./ sum(qq, dims=2)

    spl1 = sample(data, fweights(ww[:,1]), length(data))
    spl2 = sample(data, fweights(ww[:,2]), length(data))
    
    newpareto = fit_mle(Pareto{Float64}, spl1)
    newexp = fit_mle(Exponential{Float64}, spl2)
    newmm = sum(ww, dims=1)[:] / sum(ww)
    newpareto, newexp, newmm
end


vn=vaxnames[2]
cc = allcc[2]
ct = sort(cc)
@show mypareto = fit_mle(Pareto{Float64}, Float64.(if length(cc) > 1000 ct[1:end*970÷1000] else ct[end÷4:end÷2] end ))
@show myexp = fit_mle(Exponential{Float64}, Float64.(if length(cc) > 1000 ct[end*970÷1000:end] else ct[end÷2:end] end ))

# qq = [pdf.(mypareto, ct)  pdf.(myexp, ct)]
# ww = qq ./ sum(qq, dims=2)
# mean(ww, dims=1)
# spl1 = sample(ct, fweights(ww[:,1]), length(ct)*10)
# spl2 = sample(ct, fweights(ww[:,2]), length(ct)*10)
# fit_mle(Pareto{Float64}, spl1)
# fit_mle(Exponential{Float64}, spl2)
mm = [0.985, 0.015]
mypareto, myexp, mm = EMstep(myexp, mypareto, mm, cc)

plotfit(vn, cc, myexp, mypareto, mm)
