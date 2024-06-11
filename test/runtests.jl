using FRED
using Test

@testset "FRED.jl" begin
    api_key = read("test/secrets/fred_api_key.txt", String)
    valid_series = "GS10"
    invalid_series = "GS10xxxx"
    delete!(ENV,"FRED_API_KEY")

    # Test the FREDConnection struct
    @testset "FREDConnection" begin
        conn = FREDConnection(api_key=api_key)
        @test conn.host == "https://api.stlouisfed.org"
        @test conn.api_key == api_key

        @test_throws KeyError FREDConnection()
    end

    # Test the FREDConnection function with ENV variable
    @testset "FREDConnection function with ENV variable" begin
        ENV["FRED_API_KEY"] = api_key
        conn = FREDConnection()
        @test conn.api_key == api_key
    end

    # Test the FREDConnection function
    @testset "FREDConnection function" begin
        conn = FREDConnection()
        data = conn("/fred/series", valid_series)

        @test data isa Dict
        @test_throws HTTP.Exceptions.StatusError conn("/fred/series/observations", invalid_series)
    end

    # Test the get_fred_data function without keyword arguments
    @testset "get_fred_data" begin
        conn = FREDConnection()
        df = get_fred_data(conn, valid_series)
        @test df isa DataFrame

        df = get_fred_data(valid_series)
        @test df isa DataFrame

        colnames = propertynames(df)
        @test colnames[1] == :date
        @test eltype(df.date) <: FRED.Date
        @test colnames[2] == :value
        @test eltype(df.value) <: Union{Missing, Float64}
        @test length(FRED.colmetadatakeys(df, :value)) > 0
    end

    
end
