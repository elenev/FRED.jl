# FRED

This package provides a Julia interface to the Federal Reserve Economic Data (FRED) API. The FRED API provides access to hundreds of thousands of economic time series, including macroeconomic indicators, interest rates, and other financial data. The FRED API is free to use, but requires an API key, which can be obtained by registering at the [FRED website](https://research.stlouisfed.org/docs/api/api_key.html).

## Installation

The package is not yet registered, but can be installed by running

```sh
pkg> add "https://www.github.com/elenev/FRED.jl"
```
or

```julia
julia> using Pkg
julia> Pkg.add("https://www.github.com/elenev/FRED.jl")
```

## Usage

### Connection
To access FRED, you must provide your API key. The easiest way to do this is to store it in an environment variable called `FRED_API_KEY`. You can also pass it directly to the `FREDConnection` constructor.

```julia
julia> using FRED
julia> conn = FREDConnection(api_key="abcdefj1234")
```

or 

```julia
julia> using FRED
julia> ENV["FRED_API_KEY"] = "abcdefj1234"
julia> conn = FREDConnection()
```

It is strongly recommended NOT to store the API key directly in your code, as this could expose it to others. If you don't want to have a persistent environment variable, consider storing it in a text file that is read by your code (and that is not committed to a public repository).

### Retrieving Data

The `get_fred_data` function retrieves a time series from FRED along with metadata for that variable. The function returns a `DataFrame` with columns `date` and `value`. For example,

```sh
julia> get_fred_data(conn, "GS10")
854×2 DataFrame
 Row │ date        value    
     │ Date        Float64?
─────┼──────────────────────
   1 │ 1953-04-01      2.83
   2 │ 1953-05-01      3.05
  ⋮  │     ⋮          ⋮
 853 │ 2024-04-01      4.54
 854 │ 2024-05-01      4.48
            850 rows omitted
```

retrieves monthly observations of the 10-year Treasury constant maturity rate.

If you saved your API key to the environment variable, you don't need to pass the connection object:

```julia
df = get_fred_data("GS10");
```

Optionally, you can pass any keyword arguments to `get_fred_data` that are accepted by the [FRED API](https://fred.stlouisfed.org/docs/api/fred/series_observations.html). 