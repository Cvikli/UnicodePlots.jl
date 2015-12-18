"""
`Plot(graphics; nargs...)` → `Plot`

Description
============



Usage
======

    Plot(graphics, title = "", xlabel = "", ylabel = "", margin = 3, padding = 1, border = :solid, show_labels = true)

Arguments
==========

- **`graphics`** :

- **`xlabel`** :

- **`ylabel`** :

- **`title`** : Text to display on the top of the plot.

- **`margin`** : Number of empty characters to the left of the whole plot.

- **`padding`** : Space of the left and right of the plot between the labels and the canvas.

- **`border`** : The style of the bounding box of the plot. Supports `:solid`, `:bold`, `:dashed`, `:dotted`, `:ascii`, and `:none`.

- **`show_labels`** : Can be used to hide the labels by setting `labels=false`.

Author(s)
==========

- Christof Stocker (Github: https://github.com/Evizero)

see also
=========

`scatterplot`, `lineplot`, `BarplotGraphics`, `BrailleCanvas`, `BlockCanvas`, `AsciiCanvas`
"""
type Plot{T<:GraphicsArea}
    graphics::T
    title::UTF8String
    xlabel::UTF8String
    ylabel::UTF8String
    margin::Int
    padding::Int
    border::Symbol
    labels_left::Dict{Int,UTF8String}
    colors_left::Dict{Int,Symbol}
    labels_right::Dict{Int,UTF8String}
    colors_right::Dict{Int,Symbol}
    decorations::Dict{Symbol,UTF8String}
    colors_deco::Dict{Symbol,Symbol}
    show_labels::Bool
    autocolor::Int
end

function Plot{T<:GraphicsArea}(
        graphics::T;
        title::AbstractString = "",
        xlabel::AbstractString = "",
        ylabel::AbstractString = "",
        margin::Int = 3,
        padding::Int = 1,
        border::Symbol = :solid,
        labels = true)
    rows = nrows(graphics)
    cols = ncols(graphics)
    labels_left = Dict{Int,UTF8String}()
    colors_left = Dict{Int,Symbol}()
    labels_right = Dict{Int,UTF8String}()
    colors_right = Dict{Int,Symbol}()
    decorations = Dict{Symbol,UTF8String}()
    colors_deco = Dict{Symbol,Symbol}()
    Plot{T}(graphics, title, xlabel, ylabel,
            margin, padding, border,
            labels_left, colors_left, labels_right, colors_right,
            decorations, colors_deco, labels, 0)
end

function Plot{C<:Canvas, F<:AbstractFloat}(
        X::Vector{F}, Y::Vector{F}, ::Type{C} = BrailleCanvas;
        width::Int = 40,
        height::Int = 15,
        margin::Int = 3,
        padding::Int = 1,
        grid::Bool = true,
        title::AbstractString = "",
        border::Symbol = :solid,
        labels::Bool = true,
        xlim::Vector = [0.,0.],
        ylim::Vector = [0.,0.])
    length(xlim) == length(ylim) == 2 || throw(ArgumentError("xlim and ylim must only be vectors of length 2"))
    margin >= 0 || throw(ArgumentError("Margin must be greater than or equal to 0"))
    length(X) == length(Y) || throw(DimensionMismatch("X and Y must be the same length"))
    width = max(width, 5)
    height = max(height, 2)

    min_x, max_x = extend_limits(X, xlim)
    min_y, max_y = extend_limits(Y, ylim)
    origin_x = min_x
    origin_y = min_y
    p_width = max_x - origin_x
    p_height = max_y - origin_y

    canvas = C(width, height,
               origin_x = origin_x, origin_y = origin_y,
               width = p_width, height = p_height)
    new_plot = Plot(canvas, title = title, margin = margin,
                    padding = padding, border = border, labels = labels)

    min_x_str = string(isinteger(min_x) ? round(Int, min_x, RoundNearestTiesUp) : min_x)
    max_x_str = string(isinteger(max_x) ? round(Int, max_x, RoundNearestTiesUp) : max_x)
    min_y_str = string(isinteger(min_y) ? round(Int, min_y, RoundNearestTiesUp) : min_y)
    max_y_str = string(isinteger(max_y) ? round(Int, max_y, RoundNearestTiesUp) : max_y)
    annotate!(new_plot, :l, 1, max_y_str)
    annotate!(new_plot, :l, height, min_y_str)
    annotate!(new_plot, :bl, min_x_str)
    annotate!(new_plot, :br, max_x_str)
    if grid
        if min_y < 0 < max_y
            for i in linspace(min_x, max_x, width * x_pixel_per_char(typeof(canvas)))
                points!(new_plot, i, 0., :white)
            end
        end
        if min_x < 0 < max_x
            for i in linspace(min_y, max_y, height * y_pixel_per_char(typeof(canvas)))
                points!(new_plot, 0., i, :white)
            end
        end
    end
    new_plot
end

function next_color!{T<:GraphicsArea}(plot::Plot{T})
    cur_color = color_cycle[plot.autocolor + 1]
    plot.autocolor = ((plot.autocolor + 1) % length(color_cycle))
    cur_color
end

function title{T<:GraphicsArea}(plot::Plot{T})
    plot.title
end

function title!{T<:GraphicsArea}(plot::Plot{T}, title::AbstractString)
    plot.title = title
    plot
end

function xlabel{T<:GraphicsArea}(plot::Plot{T})
    plot.xlabel
end

function xlabel!{T<:GraphicsArea}(plot::Plot{T}, xlabel::AbstractString)
    plot.xlabel = xlabel
    plot
end

function ylabel{T<:GraphicsArea}(plot::Plot{T})
    plot.ylabel
end

function ylabel!{T<:GraphicsArea}(plot::Plot{T}, ylabel::AbstractString)
    plot.ylabel = ylabel
    plot
end

function annotate!{T<:GraphicsArea}(plot::Plot{T}, where::Symbol, value::AbstractString, color::Symbol=:white)
    where == :t || where == :b || where == :l || where == :r || where == :tl || where == :tr || where == :bl || where == :br || throw(ArgumentError("Unknown location: try one of these :tl :t :tr :bl :b :br"))
    if where == :l || where == :r
        for row = 1:nrows(plot.graphics)
            if where == :l
                if(!haskey(plot.labels_left, row) || plot.labels_left[row] == "")
                    plot.labels_left[row] = value
                    plot.colors_left[row] = color
                    return plot
                end
            elseif where == :r
                if(!haskey(plot.labels_right, row) || plot.labels_right[row] == "")
                    plot.labels_right[row] = value
                    plot.colors_right[row] = color
                    return plot
                end
            end
        end
    else
        plot.decorations[where] = value
        plot.colors_deco[where] = color
        return plot
    end
end

function annotate!{T<:GraphicsArea}(plot::Plot{T}, where::Symbol, value::AbstractString; color::Symbol=:white)
    annotate!(plot, where, value, color)
end

function annotate!{T<:GraphicsArea}(plot::Plot{T}, where::Symbol, row::Int, value::AbstractString, color::Symbol=:white)
    if where == :l
        plot.labels_left[row] = value
        plot.colors_left[row] = color
    elseif where == :r
        plot.labels_right[row] = value
        plot.colors_right[row] = color
    else
        throw(ArgumentError("Unknown location: try one of these :l :r"))
    end
    plot
end

function annotate!{T<:GraphicsArea}(plot::Plot{T}, where::Symbol, row::Int, value::AbstractString; color::Symbol=:white)
    annotate!(plot, where, row, value, color)
end

function lines!{T<:Canvas}(plot::Plot{T}, args...; vars...)
    lines!(plot.graphics, args...; vars...)
    plot
end

function pixel!{T<:Canvas}(plot::Plot{T}, args...; vars...)
    pixel!(plot.graphics, args...; vars...)
    plot
end

function points!{T<:Canvas}(plot::Plot{T}, args...; vars...)
    points!(plot.graphics, args...; vars...)
    plot
end

function print_title(io::IO, padding::AbstractString, title::AbstractString; p_width::Int = 0)
    if title != ""
        offset = round(Int, p_width / 2 - length(title) / 2, RoundNearestTiesUp)
        offset = offset > 0 ? offset: 0
        tpad = repeat(" ", offset)
        print_with_color(:white, io, padding, tpad, title, "\n")
    end
end

function print_border_top(io::IO, padding::AbstractString, length::Int, border::Symbol = :solid)
    b = bordermap[border]
    border == :none || print_with_color(:white, io, padding, b[:tl], repeat(b[:t], length), b[:tr])
end

function print_border_bottom(io::IO, padding::AbstractString, length::Int, border::Symbol = :solid)
    b = bordermap[border]
    border == :none || print_with_color(:white, io, padding, b[:bl], repeat(b[:b], length), b[:br])
end

function Base.show(io::IO, p::Plot)
    b = bordermap[p.border]
    c = p.graphics
    border_length = ncols(c)

    # get length of largest strings to the left and right
    max_len_l = p.show_labels && !isempty(p.labels_left)  ? maximum([length(string(l)) for l in values(p.labels_left)]) : 0
    max_len_r = p.show_labels && !isempty(p.labels_right) ? maximum([length(string(l)) for l in values(p.labels_right)]) : 0
    if p.show_labels && p.ylabel != ""
        max_len_l += length(p.ylabel) + 1
    end

    # offset where the plot (incl border) begins
    plot_offset = max_len_l + p.margin + p.padding

    # padding-string from left to border
    plot_padding = repeat(" ", p.padding)

    # padding-string between labels and border
    border_padding = repeat(" ", plot_offset)

    # plot the title and the top border
    print_title(io, border_padding, p.title, p_width = border_length)
    if p.show_labels
        topleft_str  = get(p.decorations, :tl, "")
        topleft_col  = get(p.colors_deco, :tl, :white)
        topmid_str   = get(p.decorations, :t, "")
        topmid_col   = get(p.colors_deco, :t, :white)
        topright_str = get(p.decorations, :tr, "")
        topright_col = get(p.colors_deco, :tr, :white)
        if topleft_str != "" || topright_str != "" || topmid_str != ""
            topleft_len  = length(topleft_str)
            topmid_len   = length(topmid_str)
            topright_len = length(topright_str)
            print_with_color(topleft_col, io, border_padding, topleft_str)
            cnt = round(Int, border_length / 2 - topmid_len / 2 - topleft_len, RoundNearestTiesUp)
            pad = cnt > 0 ? repeat(" ", cnt) : ""
            print_with_color(topmid_col, io, pad, topmid_str)
            cnt = border_length - topright_len - topleft_len - topmid_len + 2 - cnt
            pad = cnt > 0 ? repeat(" ", cnt) : ""
            print_with_color(topright_col, io, pad, topright_str, "\n")
        end
    end
    print_border_top(io, border_padding, border_length, p.border)
    print(io, repeat(" ", max_len_r), plot_padding, "\n")

    # compute position of ylabel
    ylabRow = round(nrows(c) / 2, RoundNearestTiesUp)

    # plot all rows
    for row in 1:nrows(c)
        # Current labels to left and right of the row and their length
        left_str  = get(p.labels_left,  row, "")
        left_col  = get(p.colors_left,  row, :white)
        right_str = get(p.labels_right, row, "")
        right_col = get(p.colors_right, row, :white)
        left_len  = length(left_str)
        right_len = length(right_str)
        # print left annotations
        print(io, repeat(" ", p.margin))
        if p.show_labels
            if row == ylabRow
                # print ylabel
                print_with_color(:white, io, p.ylabel)
                print(io, repeat(" ", max_len_l - length(p.ylabel) - left_len))
            else
                # print padding to fill ylabel length
                print(io, repeat(" ", max_len_l - left_len))
            end
            # print the left annotation
            print_with_color(left_col, io, left_str)
        end
        # print left border
        print_with_color(:white, io, plot_padding, b[:l])
        # print canvas row
        printrow(io, c, row)
        #print right label and padding
        print_with_color(:white, io, b[:r])
        if p.show_labels
            print(io, plot_padding)
            print_with_color(right_col, io, right_str)
            print(io, repeat(" ", max_len_r - right_len))
        end
        print(io, "\n")
    end

    # draw bottom border and bottom labels
    print_border_bottom(io, border_padding, border_length, p.border)
    print(io, repeat(" ", max_len_r), plot_padding, "\n")
    if p.show_labels
        botleft_str  = get(p.decorations, :bl, "")
        botleft_col  = get(p.colors_deco, :bl, :white)
        botmid_str   = get(p.decorations, :b, "")
        botmid_col   = get(p.colors_deco, :b, :white)
        botright_str = get(p.decorations, :br, "")
        botright_col = get(p.colors_deco, :br, :white)
        if botleft_str != "" || botright_str != "" || botmid_str != ""
            botleft_len  = length(botleft_str)
            botmid_len   = length(botmid_str)
            botright_len = length(botright_str)
            print_with_color(botleft_col, io, border_padding, botleft_str)
            cnt = round(Int, border_length / 2 - botmid_len / 2 - botleft_len, RoundNearestTiesUp)
            pad = cnt > 0 ? repeat(" ", cnt) : ""
            print_with_color(botmid_col, io, pad, botmid_str)
            cnt = border_length - botright_len - botleft_len - botmid_len + 2 - cnt
            pad = cnt > 0 ? repeat(" ", cnt) : ""
            print_with_color(botright_col, io, pad, botright_str, "\n")
        end
        # abuse the print_title function to print the xlabel. maybe refactor this
        print_title(io, border_padding, p.xlabel, p_width = border_length)
    end
end
