module FRED

using HTTP, JSON, Dates
using DataFrames

export get_fred_data, FREDConnection

Base.@kwdef struct FREDConnection
    host::String = "https://api.stlouisfed.org"
    api_key::String = ENV["FRED_API_KEY"]
end

function (fred::FREDConnection)(endpoint::String, series_id::String; kwargs...) 
    kwargs = [String(k) => _convert_fred_arg(v) for (k, v) in kwargs]
    url = fred.host * endpoint * "?series_id=" * series_id * "&api_key=" * fred.api_key * "&file_type=json"
    for (k, v) in kwargs
        url *= "&" * k * "=" * v
    end
    resp = HTTP.get(url)
    if resp.status != 200
        throw(HTTP.Exceptions.StatusError(
            resp.status,
            "GET",
            url,
            resp.body))
        #println("Error: ", String(resp.body))
        #return Dict()
    end

    data = JSON.parse(String(resp.body))
    return data    
end

_convert_fred_arg(arg::Date) = Dates.format(arg, "yyyy-mm-dd")
_convert_fred_arg(arg) = String(arg)

# List of available keyword arguments here: https://fred.stlouisfed.org/docs/api/fred/series_observations.html
function get_fred_data(fred::FREDConnection, series_id::String; kwargs...)
    data = fred("/fred/series/observations", series_id; kwargs...)
    df = DataFrame(data["observations"])
    df.date = Date.(df.date)
    df.value = replace( tryparse.(Float64, df.value), nothing=>missing)

    select!(df, [:date, :value])

    dictMetadata = fred("/fred/series", series_id)
    for (k, v) in dictMetadata["seriess"][1]
        colmetadata!(df, :value, k, v, style=:note)
    end

    return df
end

get_fred_data(series_id::String; kwargs...) = get_fred_data(FREDConnection(), series_id; kwargs...)


end
