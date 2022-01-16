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



headers = ["Year", "Zip File", "VAERS DATA", "VAERS Symptoms", "VAERS Vaccine"]

fsize = [
    2021 	172.13 	637.22 	77.13 	56.86
    2020 	11.32 	42.23 	4.57 	4.50
    2019 	11.22 	41.38 	4.70 	4.45
    2018 	10.31 	39.95 	4.61 	4.47
    2017 	7.24 	27.44 	3.49 	3.77
    2016 	7.33 	30.37 	3.89 	4.30
    2015 	6.96 	27.33 	3.82 	4.03
    2014 	5.55 	19.67 	3.07 	3.35
    2013 	5.18 	16.22 	2.77 	3.06
    2012 	4.79 	14.43 	2.61 	2.89
    2011 	4.53 	13.17 	2.52 	2.88
    2010 	5.43 	15.69 	3.1 	3.64
    2009 	6.69 	18.70 	3.15 	3.73
    2008 	6.39 	19.47 	2.8 	3.42
    2007 	5.56 	17.44 	2.47 	3.21
    2006 	3.27 	9.78 	1.38 	2.11
    2005 	2.84 	8.35 	1.2 	1.93
    2004 	2.82 	8.67 	1.16 	1.90
    2003 	2.98 	8.19 	1.23 	2.05
    2002 	2.59 	7.49 	1.03 	1.74
    2001 	2.18 	6.25 	0.99 	1.67
    2000 	1.95 	5.54 	1.00 	1.53
    1999 	1.33 	3.49 	0.94 	1.32
    1998 	1.05 	2.81 	0.74 	1.07
    1997 	1.16 	3.13 	0.80 	1.14
    1996 	1.12 	3.03 	0.78 	1.16
    1995 	1.11 	2.89 	0.73 	1.17
    1994 	1.08 	2.89 	0.73 	1.22
    1993 	1.06 	2.88 	0.74 	1.15
    1992 	1.06 	2.82 	0.71 	1.18
    1991 	1.01 	2.82 	0.62 	1.08
    1990 	0.21 	0.58 	0.13 	0.19
]

# plot(fsize[:,1], fsize[:,5], m=3,l=2, title="VAERS vaccines file size",label="")
bar(fsize[:,1], fsize[:,5], m=3,l=2, title="VAERS vaccines file size",label="",ylabel="CSV file size [MB]")


dd = CSV.read("/home/user/DATA/VAERS/2021VAERSVAX.csv", DataFrame)
name = "HPV (GARDASIL 9)"
sel = [x.VAX_NAME == "COVID19 (COVID19 (PFIZER-BIONTECH))" && !ismissing(x.VAX_LOT) for x in eachrow(dd)]
sel = [x.VAX_NAME == "COVID19 (COVID19 (MODERNA))" && !ismissing(x.VAX_LOT) for x in eachrow(dd)]
sel = [x.VAX_NAME == "COVID19 (COVID19 (JANSSEN))" && !ismissing(x.VAX_LOT) for x in eachrow(dd)]
sel = [x.VAX_NAME == "COVID19 (COVID19 (UNKNOWN))" && !ismissing(x.VAX_LOT) for x in eachrow(dd)]
sel = [x.VAX_NAME == "ZOSTER (SHINGRIX)" && !ismissing(x.VAX_LOT) && (uppercase(x.VAX_LOT) ∉ ["UNKNOWN", "UNK", "58160082311"]) && !(length(x.VAX_LOT)>=5&&x.VAX_LOT[1:5]=="58160") for x in eachrow(dd)]
sel = [x.VAX_NAME == "HPV (GARDASIL 9)" && !ismissing(x.VAX_LOT) && uppercase(x.VAX_LOT) ∉ ["UNKNOWN", "UNK", "58160082311"] for x in eachrow(dd)]
sel = [x.VAX_NAME == "VARICELLA (VARIVAX)" && !ismissing(x.VAX_LOT) && uppercase(x.VAX_LOT) ∉ ["UNKNOWN", "UNK", "58160082311"] for x in eachrow(dd)]


name = "COVID19 (COVID19 (PFIZER-BIONTECH))"
name = "COVID19 (COVID19 (MODERNA))"
name = "COVID19 (COVID19 (JANSSEN))"
name = "HPV (GARDASIL 9)"
name = "ZOSTER (SHINGRIX)"
name = "VARICELLA (VARIVAX)"


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



plot(bar(ccj[1,:], ccj[2,:],label="Janssen"), bar(ccm[1,:], ccm[2,:],label="Moderna"), bar(ccp[1,:], ccp[2,:],label="Pfizer"), bar(ccz[1,:], ccz[2,:],label="Shingrix"))
bar(ccz[1,:], ccz[2,:],label="Varivax")

plot(sort(cc[2,:]), m=3)
# print(cc[1,:])


Nm = size(ccm,2)
Np = size(ccp,2)
Nj = size(ccj,2)
# plot((1:Np) / Np, cumsum(sort(ccp[2, :], rev=true)) / sum(ccp[2, :]), m=2, label="Pfizer", ylabel="Fraction of cases", xlabel="Fraction of batches",xlim=(0,0.2), ylim=(0,1.1), title="VAERS stats for Pfizer - $(size(ccp,2)) batches, $(sum(ccp[2,:])) cases")
# plot!([(1:Np)[end*15÷1000] / Np], [cumsum(sort(ccp[2, :], rev=true))[end*15÷1000] / sum(ccp[2, :])], m=5, color=:red, label="1.5% of batches = 91% of cases")
# plot!([(1:Np)[end*10÷1000] / Np], [cumsum(sort(ccp[2, :], rev=true))[end*10÷1000] / sum(ccp[2, :])], m=5, color=:green, label="1% of batches = 81% of cases")

plot((1:Np), cumsum(sort(ccp[2, :]/1000, rev=true)), m=2, label="Pfizer", ylabel="Number of cases (thousands)", xlabel="Number of batches",xlim=(0,0.2*Np), ylim=(0,1.1 * sum(ccp[2,:]/1000)), title="VAERS stats for Pfizer - $(size(ccp,2)) batches, $(sum(ccp[2,:])) cases")
plot!([(1:Np)[end*15÷1000] ], [cumsum(sort(ccp[2, :]/1000, rev=true))[end*15÷1000]], m=5, color=:red, label="1.5% of batches = 91% of cases")
plot!([(1:Np)[end*10÷1000] ], [cumsum(sort(ccp[2, :]/1000, rev=true))[end*10÷1000]], m=5, color=:green, label="1% of batches = 81% of cases")
plot!(size=(800,800))
savefig("vaers-pfizer.png")


plot((1:Nm), cumsum(sort(ccm[2, :]/1000, rev=true)), m=2, label="Moderna", ylabel="Number of cases (thousands)", xlabel="Number of batches",xlim=(0,0.2*Nm), ylim=(0,1.1 * sum(ccm[2,:]/1000)), title="VAERS stats for Moderna - $(size(ccm,2)) batches, $(sum(ccm[2,:])) cases")
plot!([(1:Nm)[end*15÷1000] ], [cumsum(sort(ccm[2, :]/1000, rev=true))[end*15÷1000]], m=5, color=:red, label="1.5% of batches = 86% of cases")
plot!([(1:Nm)[end*10÷1000] ], [cumsum(sort(ccm[2, :]/1000, rev=true))[end*10÷1000]], m=5, color=:green, label="1% of batches = 77% of cases")
plot!(size=(800,800))
savefig("vaers-moderna.png")


plot((1:Nj), cumsum(sort(ccj[2, :]/1000, rev=true)), m=2, label="Jenssen", ylabel="Number of cases (thousands)", xlabel="Number of batches",xlim=(0,0.2*Nj), ylim=(0,1.1 * sum(ccj[2,:]/1000)), title="VAERS stats for Janssen - $(size(ccj,2)) batches, $(sum(ccj[2,:])) cases")
plot!([(1:Nj)[end*15÷1000] ], [cumsum(sort(ccj[2, :]/1000, rev=true))[end*15÷1000]], m=5, color=:red, label="1.5% vof batches = 88% of cases")
plot!([(1:Nj)[end*10÷1000] ], [cumsum(sort(ccj[2, :]/1000, rev=true))[end*10÷1000]], m=5, color=:green, label="1% of batches = 76% of cases")
plot!(size=(800,800))
savefig("vaers-janssen.png")

N = size(cc, 2)
# name = "Shingrix"
name = "Varivax"
# name = "Gardasil"
# cc = ccz[:,sortperm(ccz[2,:],rev=true)]
q1 = sum(sort(cc[2, :], rev=true)[1:end*100÷1000]) / sum(cc[2, :])
q2 = sum(sort(cc[2, :], rev=true)[1:end*20÷100]) / sum(cc[2, :])
# q1 = sum(sort(cc[2, :], rev=true)[1:end*15÷1000]) / sum(cc[2, :])
# q2 = sum(sort(cc[2, :], rev=true)[1:end*10÷1000]) / sum(cc[2, :])
plot((1:N), cumsum(sort(cc[2, :]/1000, rev=true)), m=2, label=name, ylabel="Number of cases (thousands)", xlabel="Number of batches",xlim=(0,N), ylim=(0,1.1 * sum(cc[2,:]/1000)), title="VAERS stats for $name - $(size(cc,2)) batches, $(sum(cc[2,:])) cases")
plot!([(1:N)[end*10÷100] ], [cumsum(sort(cc[2, :]/1000, rev=true))[end*10÷100]], m=5, color=:red, label="10% of batches = $(round(Int,q1*100))% of cases")
plot!([(1:N)[end*20÷100] ], [cumsum(sort(cc[2, :]/1000, rev=true))[end*20÷100]], m=5, color=:red, label="20% of batches = $(round(Int,q2*100))% of cases")
# plot!([(1:N)[end*15÷1000] ], [cumsum(sort(cc[2, :]/1000, rev=true))[end*15÷1000]], m=5, color=:red, label="1.5% of batches = $(round(Int,q1*100))% of cases")
# plot!([(1:N)[end*10÷1000] ], [cumsum(sort(cc[2, :]/1000, rev=true))[end*10÷1000]], m=5, color=:green, label="1% of batches = $(round(Int,q2*100))% of cases")
plot!(size=(800,800))
# savefig("vaers-$(lowercase.(name)).png")



sum(sort(ccp[2, :], rev=true)[1:end*20÷1000]) / sum(ccp[2, :])
sum(sort(ccp[2, :], rev=true)[1:end*15÷1000]) / sum(ccp[2, :])
sum(sort(ccp[2, :], rev=true)[1:end*10÷1000]) / sum(ccp[2, :])

sum(sort(ccm[2, :], rev=true)[1:end*20÷1000]) / sum(ccm[2, :])
sum(sort(ccm[2, :], rev=true)[1:end*15÷1000]) / sum(ccm[2, :])
sum(sort(ccm[2, :], rev=true)[1:end*10÷1000]) / sum(ccm[2, :])

sum(sort(ccj[2, :], rev=true)[1:end*20÷1000]) / sum(ccj[2, :])
sum(sort(ccj[2, :], rev=true)[1:end*15÷1000]) / sum(ccj[2, :])
sum(sort(ccj[2, :], rev=true)[1:end*10÷1000]) / sum(ccj[2, :])

sum(sort(ccz[2, :], rev=true)[1:end*20÷1000]) / sum(ccz[2, :])
sum(sort(ccz[2, :], rev=true)[1:end*15÷1000]) / sum(ccz[2, :])
sum(sort(ccz[2, :], rev=true)[1:end*10÷1000]) / sum(ccz[2, :])

# 1% of the batches are responsible for 80% of the cases


xx = sort(cc[2, :], rev=true)

ks = xx[1:end*15÷1000]
ps = xx[(end*15÷1000+1):end]
    
plot(ks,m=3)
plot(ps,m=3)
cc = cc[:,sortperm(cc[2,:],rev=true)]


plot(sort(ccp[2, :], rev=true)[1:250],m=2,msw=0.2, label="Pfizer", yaxis=:log)
plot!(sort(ccm[2, :], rev=true)[1:250],m=2,msw=0.2, title="Worst batches", label="Moderna")

plot(sort(ccp[2, :], rev=true)[251:end],m=2,msw=0.2, label="Pfizer", yaxis=:log)
plot!(sort(ccm[2, :], rev=true)[251:end],m=2,msw=0.2, title="Worst batches", label="Moderna")

plot(sort(ccp[2, :], rev=true),m=2,msw=0.2, label="Pfizer")
plot!(sort(ccm[2, :], rev=true),m=2,msw=0.2, title="Worst batches", label="Moderna")



ccz=ccj
ccz=ccm

Nc = size(cc,2)

# simp = [myrand(Pareto(1.8,3.1)) for _ in 1:Nc] # shingrix
# simp = [myrand(Pareto(1.5,2.0)) for _ in 1:Nc] # varivax
# simp = [myrand(Pareto(1.1,2.0)) for _ in 1:Nc] # hpv
simp = [myrand(Pareto(0.8,1.3)) for _ in 1:Nc] # hpv
# simp = [myrand(Pareto(1.3,0.4)) for _ in 1:Nc] # pfizer
# simp = [myrand(Pareto(1.3,0.4)) for _ in 1:Nc] # moderna
plot(sort(cc[2,:], rev=true),l=3, m=2)
plot!(sort(simp, rev=true),l=3,yaxis=:log, ylim=(0.6,30000), m=2,title="$name vs pareto")


# simp = rand(Poisson(mean(ccz[2,:])), size(ccz,2))
# simp = rand(Exponential(1/mean(ccz[2,:])), size(ccz,2))
# simp = rand(Exponential(median(ccz[2,:])/log(2)), size(ccz,2))
# simp = rand(Exponential(median(4*ccz[2,:])/log(2)), size(ccz,2))
# simp = floor.(Int, rand(Exponential(median(cc[2,:])/log(2)), round(Int,size(cc,2)*1.6)))

# simp = floor.(Int, rand(Exponential(mean(cc[2,:])*0.8), round(Int,size(cc,2)*1.5)))
# simp = floor.(Int, rand(Exponential(mean(cc[2,:])*0.8), round(Int,size(cc,2)*1.5)))
# simp = floor.(Int, rand(Exponential(mean(cc[2,:])*0.8), round(Int,size(cc,2))))
# simp = [myrand(Exponential(mean(cc[2,:])*0.9)) for _ in 1:Nc]
# simp = [myrand(Exponential(2.09*0.9)) for _ in 1:Nc]
# simp = [myrand(Exponential(4)) for _ in 1:Nc]





median([myrand(Pareto(2.1,0.2)) for _ in 1:Nc])

[(a,t,mean([myrand(Pareto(a, t)) for _ in 1:Nc])) for a in 0.5:0.1:2.5, t in 0.2:0.1:2.0]

# mean(sort(cc[2,:])[1:end*985÷1000])

# plot(cumsum(sort(cc[2,:], rev=true)),l=3)
# plot!(cumsum(sort(simp, rev=true)),l=3)


# plot(cumsum(sort(cc[2,:], rev=true)),cumsum(sort(simp, rev=true)),l=3, ratio = 1)
# plot!([0, sum(cc[2,:])],[0,sum(simp)], style=:dash, color=:black)

plot(sort(cc[2,:], rev=true),sort(simp, rev=true),l=3, ratio = 1,m=3)
plot!([minimum(cc[2,:]), maximum(cc[2,:])],[minimum(cc[2,:]), maximum(cc[2,:])], style=:dash, color=:black)

plot!(sort(simp))


# Nn = 7750
Nn = 24
bar(1:Nn, [count(x->x==n, ccz[2,:]) for n in 1:Nn], bar_width=0.4, title="Shingrix vs. Poisson distribution simulation", label="Shingrix")
bar!((1:20) .+ 0.4, [count(x->x==n, simp) for n in 1:20], bar_width=0.4, label="Exponential simulation")
# bar!((1:Nn) .+ 0.4, [count(x->round(Int,x)==n, simp) for n in 1:Nn], bar_width=0.4, label="Exponential simulation")



aa = hcat([[x...] for x in countmap(dd.VAX_NAME)]...)
aa = aa[:,sortperm(aa[2,:],rev=true)]
DataFrame(Name=aa[1,:], Count=aa[2,:])


ct = sort(cc[2,:])
NN = size(cc,2)
plot(ct, NN+1 .- (1:NN), xaxis=:log, yaxis=:log, m=3)
plot(ct, NN+1 .- (1:NN), m=3)

pp = map(zip(vaxnames,allcc)) do (vn,cc)
    ct = sort(cc)
    NN = length(cc)
    # qq = ct[end*11÷12]
    # simp = sort(ceil.(Int, rand(Exponential(qq/log(12)), round(Int,NN))))
    qq = ct[end*111÷112]
    # simp = sort([myrand(Pareto(1.5,2.0)) for _ in 1:NN]) # varivax
    # simp = sort([myrand(Pareto(1.5,2.5)) for _ in 1:NN]) # varivax
    # simp = sort(ceil.(Int, rand(Exponential(qq/log(112)), round(Int,NN))))
    simp = sort(rand(Exponential(qq/log(112)), round(Int,NN)))
    # qq = ct[end*4÷5]
    # simp = sort(ceil.(Int, rand(Exponential(qq/log(5/4)), round(Int,NN))))
    @show ct[end*111÷112]
    @show simp[end*111÷112]
    @show qq/log(112)
    # qq = ct[end*4÷5]
    # simp = floor.(Int, rand(Exponential(qq/log(5/4)), round(Int,NN)))
    # simp = floor.(Int, rand(Exponential(qq/log(2)), round(Int,NN)))
    # simp = floor.(Int, rand(Exponential(mean(cc)), round(Int,NN)))
    # plot(ct, (1:NN), m=3, label=vn)
    # plot(ct, NN+1 .- (1:NN), m=3)
    # plot(ct, NN+1 .- (1:NN), m=3)
    # plot(ct, NN+1 .- (1:NN), xaxis=:log, yaxis=:log, m=3, label=vn)
    # plot!(simp, NN+1 .- (1:NN), xaxis=:log, yaxis=:log, m=3, label="Exponential sim.")
    plot(ct, NN+1 .- (1:NN), yaxis=:log, m=3, label=vn)
    plot!(simp, NN+1 .- (1:NN), yaxis=:log, m=3, label="simulation")
    # plot(ct, NN+1 .- (1:NN), m=3, label=vn)
    # plot!(sort(simp), NN+1 .- (1:NN), m=3, label="simulation")
end
plot(pp...)



invlogcdf(Exponential(median(allcc[1])/log(333/332)), 0.5)



mean(rand(Exponential(123), 1111))
mean(median(rand(Exponential(123), 1111)) for it in 1:111)


mean(sort(rand(Exponential(123), 1111))[end*11÷12] for it in 1:111)


303 / log(12)
