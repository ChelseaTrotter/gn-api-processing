# May 29th, 2019
# Author: Chelsea Trotter
# This file contains functions to process the response of gene network API queries. 



using HTTP
# using LazyJSON #using LazyJSON package because JSON package is considerable slower
using DataFrames
using JSON
using DelimitedFiles
using CSV
using BenchmarkTools


function get_api(url)
    response = HTTP.get(url)
    String(response.body)
end

function parse_json(str)
    return JSON.parse(str)
end

function process_csv_file(input::String; delim=',', comments=false)
    io = IOBuffer(input)
    data = readdlm(io, delim, '\n', comments=comments, comment_char='#')
    #processing extra comments marked with '@'
    skip_count = count_extra_comment_lines(data)
    data = data[skip_count:end,:]
    return data
end


function count_extra_comment_lines(array)
    # TODO: find more elegant solution to remove extra comments starting with '@'
    done = false
    iter = 1
    comment_char = '@'
    while !done && iter<length(array)
        if array[iter, 1][1] == comment_char
            iter += 1
            # array[iter, 1][1] = '#'
        else
            done = true
        end
    end
    return iter


end

function json2mat(s::String)
    dict = JSON.parse(s)
    return j2m(dict)
end

function j2m(input::Array{Any,1})
    return vcat(DataFrame.(input)..., cols=:union)
end

function j2m(input::Dict{String,Any})
    return DataFrame(input)
end
